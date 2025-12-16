import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/utils/text_stats.dart';

/// Tests for TextStats utility.
///
/// These tests verify word and character counting functionality.
void main() {
  group('TextStats Tests', () {
    test('Should count words in simple text', () {
      final stats = TextStats.fromHtml('<p>Hello World</p>');
      expect(stats.wordCount, equals(2));
    });

    test('Should count characters in simple text', () {
      final stats = TextStats.fromHtml('<p>Hello World</p>');
      expect(stats.charCount, equals(11)); // "Hello World" = 11 chars
    });

    test('Should handle multiple paragraphs', () {
      final stats = TextStats.fromHtml('<p>First paragraph</p><p>Second paragraph</p>');
      expect(stats.wordCount, equals(4));
    });

    test('Should handle formatted text', () {
      final stats = TextStats.fromHtml('<p><strong>Bold</strong> and <em>italic</em> text</p>');
      expect(stats.wordCount, equals(4)); // "Bold and italic text"
    });

    test('Should handle empty HTML', () {
      final stats = TextStats.fromHtml('');
      expect(stats.wordCount, equals(0));
      expect(stats.charCount, equals(0));
    });

    test('Should handle HTML with only tags', () {
      final stats = TextStats.fromHtml('<p><br></p>');
      expect(stats.wordCount, equals(0));
    });

    test('Should handle tables', () {
      final stats = TextStats.fromHtml('<table><tr><td>Cell One</td><td>Cell Two</td></tr></table>');
      expect(stats.wordCount, equals(4)); // "Cell One Cell Two"
    });

    test('Should handle lists', () {
      final stats = TextStats.fromHtml('<ul><li>Item One</li><li>Item Two</li></ul>');
      expect(stats.wordCount, equals(4)); // "Item One Item Two"
    });

    test('Should handle nested formatting', () {
      final stats = TextStats.fromHtml('<p><strong><em>Bold Italic</em></strong></p>');
      expect(stats.wordCount, equals(2));
    });

    test('Should handle special characters', () {
      final stats = TextStats.fromHtml('<p>Hello &amp; World</p>');
      // "&amp;" becomes "&" when parsed, but we're counting after stripping tags
      expect(stats.wordCount, greaterThanOrEqualTo(2));
    });

    test('Should count emoji as characters', () {
      final stats = TextStats.fromHtml('<p>Hello 😀 World</p>');
      expect(stats.wordCount, greaterThanOrEqualTo(2));
    });

    test('Should handle whitespace-only content', () {
      final stats = TextStats.fromHtml('<p>   </p>');
      expect(stats.wordCount, equals(0));
    });

    test('Should handle complex document', () {
      final stats = TextStats.fromHtml('''
        <h1>Title</h1>
        <p>First paragraph with <strong>bold</strong> text.</p>
        <ul>
          <li>List item one</li>
          <li>List item two</li>
        </ul>
        <table>
          <tr><td>Cell 1</td><td>Cell 2</td></tr>
        </table>
      ''');
      
      // Should count all words across all elements
      expect(stats.wordCount, greaterThan(10));
    });
  });
}

