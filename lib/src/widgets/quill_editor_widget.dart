import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

import '../core/constants/editor_config.dart';

/// A Quill.js rich text editor widget for Flutter Web.
///
/// This widget embeds a Quill.js editor via an iframe and provides
/// bidirectional communication between Flutter and the JavaScript editor.
///
/// Example usage:
/// ```dart
/// QuillEditorWidget(
///   onContentChanged: (html, delta) {
///     print('Content changed: $html');
///   },
///   initialHtml: '<p>Hello World</p>',
/// )
/// ```
class QuillEditorWidget extends StatefulWidget {
  const QuillEditorWidget({
    super.key,
    this.width,
    this.height,
    this.onContentChanged,
    this.onReady,
    this.readOnly = false,
    this.initialHtml,
    this.initialDelta,
    this.placeholder,
    this.editorHtmlPath,
    this.viewerHtmlPath,
  });

  /// Width of the editor. If null, expands to fill parent.
  final double? width;

  /// Height of the editor. If null, expands to fill parent.
  final double? height;

  /// Callback when editor content changes.
  ///
  /// Provides both HTML string and Quill Delta object.
  final void Function(String html, dynamic delta)? onContentChanged;

  /// Callback when the editor is ready.
  final VoidCallback? onReady;

  /// Whether the editor is read-only (viewer mode).
  final bool readOnly;

  /// Initial HTML content to load.
  final String? initialHtml;

  /// Initial Delta content to load (JSON).
  final dynamic initialDelta;

  /// Placeholder text when editor is empty.
  final String? placeholder;

  /// Path to the editor HTML file. Defaults to [EditorConfig.editorHtmlPath].
  final String? editorHtmlPath;

  /// Path to the viewer HTML file. Defaults to [EditorConfig.viewerHtmlPath].
  final String? viewerHtmlPath;

  @override
  State<QuillEditorWidget> createState() => QuillEditorWidgetState();
}

/// State for [QuillEditorWidget].
///
/// Provides methods for programmatic control of the editor.
class QuillEditorWidgetState extends State<QuillEditorWidget> {
  html.IFrameElement? _iframe;
  static int _viewIdCounter = 0;
  late int _viewId;
  bool _hasInitializedContent = false;
  bool _isReady = false;
  double _currentZoom = EditorConfig.defaultZoom;

  /// Current zoom level (1.0 = 100%).
  double get currentZoom => _currentZoom;

  /// Whether the editor is ready to receive commands.
  bool get isReady => _isReady;

  @override
  void initState() {
    super.initState();
    _viewId = ++_viewIdCounter;
    _registerViewFactory();
  }

  void _registerViewFactory() {
    final editorPath = widget.readOnly
        ? (widget.viewerHtmlPath ?? EditorConfig.viewerHtmlPath)
        : (widget.editorHtmlPath ?? EditorConfig.editorHtmlPath);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'quill-editor-$_viewId',
      (int viewId) {
        _iframe = html.IFrameElement()
          ..src = editorPath
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%';

        _iframe!.onLoad.listen((_) {
          _isReady = true;
          _initializeContent();
          widget.onReady?.call();
        });

        html.window.addEventListener('message', _handleMessage);

        return _iframe!;
      },
    );
  }

  void _handleMessage(html.Event event) {
    final messageEvent = event as html.MessageEvent;
    if (messageEvent.data == null) return;

    try {
      final messageData = messageEvent.data is String
          ? messageEvent.data as String
          : messageEvent.data.toString();

      final data = jsonDecode(messageData);

      if (data['type'] == 'contentChange') {
        widget.onContentChanged?.call(
          (data['html'] as String?) ?? '',
          data['delta'],
        );
      } else if (data['type'] == 'ready') {
        _isReady = true;
        widget.onReady?.call();
      }
    } catch (e) {
      debugPrint('QuillEditorWidget: Message parse error: $e');
    }
  }

  void _initializeContent() {
    if (_hasInitializedContent) return;
    _hasInitializedContent = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.initialDelta != null) {
        setContents(widget.initialDelta);
      } else if (widget.initialHtml != null && widget.initialHtml!.isNotEmpty) {
        setHTML(widget.initialHtml!);
      }
    });
  }

  /// Insert text at the current cursor position.
  void insertText(String text) {
    _sendCommand({
      'action': 'insertText',
      'text': text,
    });
  }

  /// Set the editor contents from a Delta object.
  void setContents(dynamic delta) {
    _sendCommand({
      'action': 'setContents',
      'delta': delta,
    });
  }

  /// Set the editor contents from HTML string.
  ///
  /// If [replace] is true (default), replaces all content.
  /// If [replace] is false, inserts at cursor position.
  void setHTML(String html, {bool replace = true}) {
    _sendCommand({
      'action': 'setHTML',
      'html': html,
      'replace': replace,
    });
  }

  /// Insert HTML at cursor position.
  ///
  /// If [replace] is true, replaces all existing content first.
  void insertHtml(String html, {bool replace = false}) {
    _sendCommand({
      'action': 'insertHtml',
      'html': html,
      'replace': replace,
    });
  }

  /// Request the current editor contents.
  ///
  /// Response will come through onContentChanged callback.
  void getContents() {
    _sendCommand({
      'action': 'getContents',
    });
  }

  /// Clear all editor content.
  void clear() {
    _sendCommand({
      'action': 'clear',
    });
  }

  /// Focus the editor.
  void focus() {
    _sendCommand({
      'action': 'focus',
    });
  }

  /// Undo the last operation.
  void undo() {
    _sendCommand({
      'action': 'undo',
    });
  }

  /// Redo the last undone operation.
  void redo() {
    _sendCommand({
      'action': 'redo',
    });
  }

  /// Apply formatting to the current selection or cursor position.
  ///
  /// [format] - The format name (e.g., 'bold', 'italic', 'color', 'font', 'size')
  /// [value] - The format value (e.g., true for bold, '#ff0000' for color)
  void format(String format, dynamic value) {
    _sendCommand({
      'action': 'format',
      'format': format,
      'value': value,
    });
  }

  /// Insert a table at the cursor position.
  ///
  /// [rows] - Number of rows
  /// [cols] - Number of columns
  void insertTable(int rows, int cols) {
    _sendCommand({
      'action': 'insertTable',
      'rows': rows,
      'cols': cols,
    });
  }

  /// Zoom in the editor (increase by [EditorConfig.zoomStep]).
  void zoomIn() {
    _currentZoom = (_currentZoom + EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _sendCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
  }

  /// Zoom out the editor (decrease by [EditorConfig.zoomStep]).
  void zoomOut() {
    _currentZoom = (_currentZoom - EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _sendCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
  }

  /// Reset zoom to 100%.
  void resetZoom() {
    _currentZoom = EditorConfig.defaultZoom;
    _sendCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
  }

  /// Set zoom to specific level (clamped to min/max).
  void setZoom(double level) {
    _currentZoom = level.clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _sendCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
  }

  void _sendCommand(Map<String, dynamic> data) {
    if (!_isReady || _iframe == null) {
      debugPrint('QuillEditorWidget: Not ready yet, queuing command');
      Future.delayed(const Duration(milliseconds: 200), () {
        _sendCommand(data);
      });
      return;
    }

    data['source'] = 'flutter';
    data['type'] = 'command';
    final jsonString = jsonEncode(data);
    debugPrint('QuillEditorWidget: Sending command: ${data['action']}');
    _iframe?.contentWindow?.postMessage(jsonString, '*');
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _handleMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: HtmlElementView(viewType: 'quill-editor-$_viewId'),
    );
  }
}
