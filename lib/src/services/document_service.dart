import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import '../core/utils/export_styles.dart';
import '../core/utils/html_cleaner.dart';

/// Service for document operations like saving and exporting.
class DocumentService {
  /// Generates a complete HTML document from content.
  ///
  /// [content] - The HTML content to generate document from.
  /// [cleanHtml] - Whether to clean editor artifacts from HTML (defaults to true).
  /// [title] - Optional title for the HTML document.
  /// Returns the complete HTML document as a string.
  static String generateHtmlDocument(
    String content, {
    bool cleanHtml = true,
    String? title,
  }) {
    // Clean HTML if requested
    final cleanedContent =
        cleanHtml ? HtmlCleaner.cleanForExport(content) : content;

    // Generate full HTML document with styles
    return ExportStyles.generateHtmlDocument(cleanedContent, title: title);
  }

  /// Downloads the HTML content as a file.
  ///
  /// [content] - The HTML content to download.
  /// [filename] - The name of the file (defaults to 'document.html').
  /// [cleanHtml] - Whether to clean editor artifacts from HTML (defaults to true).
  static void downloadHtml(
    String content, {
    String filename = 'document.html',
    bool cleanHtml = true,
  }) {
    // Generate full HTML document
    final fullHtml = generateHtmlDocument(content, cleanHtml: cleanHtml);

    // Create blob and download
    final bytes = utf8.encode(fullHtml);
    final blob = html.Blob([bytes], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Downloads plain text content as a file.
  ///
  /// [content] - The text content to download.
  /// [filename] - The name of the file (defaults to 'document.txt').
  static void downloadText(
    String content, {
    String filename = 'document.txt',
  }) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Copies text to the clipboard.
  ///
  /// Returns true if successful.
  static Future<bool> copyToClipboard(String text) async {
    try {
      await html.window.navigator.clipboard?.writeText(text);
      return true;
    } catch (e) {
      // Fallback method
      final textArea = html.TextAreaElement()
        ..value = text
        ..style.position = 'fixed'
        ..style.left = '-9999px';
      html.document.body?.append(textArea);
      textArea.select();
      final success = html.document.execCommand('copy');
      textArea.remove();
      return success;
    }
  }

  /// Reads text from the clipboard.
  static Future<String?> readFromClipboard() async {
    try {
      return await html.window.navigator.clipboard?.readText();
    } catch (e) {
      return null;
    }
  }

  /// Prints the HTML content.
  ///
  /// Opens a new window with the content and triggers the print dialog.
  static void printHtml(String content) {
    final fullHtml = generateHtmlDocument(content, cleanHtml: true);

    // Create blob URL and open in new window for printing
    final bytes = utf8.encode(fullHtml);
    final blob = html.Blob([bytes], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Open print window - user can print from the new tab
    html.window.open(url, '_blank');

    // Note: Auto-print requires user interaction in modern browsers
    // The user can print from the opened window using Ctrl+P/Cmd+P
  }

  /// Saves content to local storage.
  ///
  /// [key] - The storage key.
  /// [content] - The content to save.
  static void saveToLocalStorage(String key, String content) {
    html.window.localStorage[key] = content;
  }

  /// Loads content from local storage.
  ///
  /// [key] - The storage key.
  /// Returns null if not found.
  static String? loadFromLocalStorage(String key) {
    return html.window.localStorage[key];
  }

  /// Removes content from local storage.
  ///
  /// [key] - The storage key.
  static void removeFromLocalStorage(String key) {
    html.window.localStorage.remove(key);
  }

  /// Checks if local storage has content for the given key.
  static bool hasLocalStorage(String key) {
    return html.window.localStorage.containsKey(key);
  }
}
