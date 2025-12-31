import 'dart:collection';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

import '../core/constants/editor_config.dart';
import 'quill_editor_controller.dart';

/// A Quill.js rich text editor widget for Flutter Web.
///
/// This widget embeds a Quill.js editor via an iframe and provides
/// bidirectional communication between Flutter and the JavaScript editor.
///
/// ## Simple Usage (No Controller)
/// When you don't need programmatic access, just use the callbacks:
/// ```dart
/// QuillEditorWidget(
///   onContentChanged: (html, delta) {
///     print('Content changed: $html');
///   },
/// )
/// ```
///
/// ## Using with Controller
/// When you need programmatic control, provide your own controller.
/// You are responsible for disposing it:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> {
///   final _controller = QuillEditorController();
///
///   @override
///   void dispose() {
///     _controller.dispose();  // You manage the lifecycle
///     super.dispose();
///   }
///
///   void _insertText() {
///     _controller.insertText('Hello World!');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return QuillEditorWidget(
///       controller: _controller,
///       onContentChanged: (html, delta) {
///         print('Content changed: $html');
///       },
///     );
///   }
/// }
/// ```
///
/// ## Using with GlobalKey (Legacy)
/// ```dart
/// final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();
///
/// QuillEditorWidget(
///   key: _editorKey,
///   onContentChanged: (html, delta) {
///     print('Content changed: $html');
///   },
/// )
///
/// // Access methods via key
/// _editorKey.currentState?.insertText('Hello');
/// ```
class QuillEditorWidget extends StatefulWidget {
  const QuillEditorWidget({
    super.key,
    this.controller,
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
    this.defaultEditorFont,
  });

  /// Controller for programmatic access to the editor.
  ///
  /// If not provided, an internal controller is created and managed
  /// automatically by the widget (similar to how `TextField` works).
  ///
  /// When you provide a controller, you are responsible for disposing it:
  /// ```dart
  /// class _MyWidgetState extends State<MyWidget> {
  ///   final _controller = QuillEditorController();
  ///
  ///   @override
  ///   void dispose() {
  ///     _controller.dispose();
  ///     super.dispose();
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return QuillEditorWidget(controller: _controller);
  ///   }
  /// }
  /// ```
  final QuillEditorController? controller;

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

  /// Default font for the editor content.
  ///
  /// This sets the default font that will be applied to new text and
  /// the editor's base font. Use the font value (e.g., 'roboto', 'mulish').
  ///
  /// Example:
  /// ```dart
  /// QuillEditorWidget(
  ///   defaultEditorFont: 'mulish',
  /// )
  /// ```
  final String? defaultEditorFont;

  @override
  State<QuillEditorWidget> createState() => QuillEditorWidgetState();
}

/// State for [QuillEditorWidget].
///
/// Provides methods for programmatic control of the editor.
/// Prefer using [QuillEditorController] for a cleaner API.
class QuillEditorWidgetState extends State<QuillEditorWidget> {
  html.IFrameElement? _iframe;
  static int _viewIdCounter = 0;
  late int _viewId;
  bool _hasInitializedContent = false;
  bool _isReady = false;
  bool _isProcessingQueue = false;
  bool _isDisposed = false;
  double _currentZoom = EditorConfig.defaultZoom;

  /// Internal controller created when no external controller is provided.
  /// This follows the same pattern as TextField's internal TextEditingController.
  QuillEditorController? _internalController;

  /// Returns the effective controller (external or internal).
  /// Creates an internal controller lazily if needed.
  QuillEditorController get _effectiveController =>
      widget.controller ?? (_internalController ??= QuillEditorController());

  /// Command queue for storing commands when editor is not ready.
  /// Uses a Queue (FIFO) to maintain command order.
  final Queue<Map<String, dynamic>> _commandQueue =
      Queue<Map<String, dynamic>>();

  /// Maximum number of commands to queue before dropping old ones.
  static const int _maxQueueSize = 100;

  /// Current zoom level (1.0 = 100%).
  double get currentZoom => _currentZoom;

  /// Whether the editor is ready to receive commands.
  bool get isReady => _isReady;

  /// Number of commands currently queued.
  int get queuedCommandCount => _commandQueue.length;

  @override
  void initState() {
    super.initState();
    _viewId = ++_viewIdCounter;
    _registerViewFactory();
    _attachController();
  }

  @override
  void didUpdateWidget(QuillEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      // Detach old controller
      if (oldWidget.controller != null) {
        oldWidget.controller!.detach();
      } else {
        // Old widget used internal controller, detach it
        _internalController?.detach();
      }

      // If switching from internal to external controller, dispose internal
      if (oldWidget.controller == null && widget.controller != null) {
        _internalController?.dispose();
        _internalController = null;
      }

      _attachController();
    }
  }

  void _attachController() {
    _effectiveController.attach(_sendCommand);
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
          _effectiveController.markReady();
          _initializeContent();
          widget.onReady?.call();
          // Process any commands that were queued before editor was ready
          _processCommandQueue();
        });

        html.window.addEventListener('message', _handleMessage);

        return _iframe!;
      },
    );
  }

  void _handleMessage(html.Event event) {
    // Ignore messages if widget has been disposed
    if (_isDisposed) return;

    final messageEvent = event as html.MessageEvent;
    if (messageEvent.data == null) return;

    try {
      final messageData = messageEvent.data is String
          ? messageEvent.data as String
          : messageEvent.data.toString();

      final data = jsonDecode(messageData);

      // Double-check disposal state after async operations
      if (_isDisposed) return;

      if (data['type'] == 'contentChange') {
        final htmlContent = (data['html'] as String?) ?? '';
        _effectiveController.updateHtml(htmlContent);
        widget.onContentChanged?.call(htmlContent, data['delta']);
      } else if (data['type'] == 'ready') {
        _isReady = true;
        _effectiveController.markReady();
        widget.onReady?.call();
        // Process any commands that were queued before editor was ready
        _processCommandQueue();
      } else if (data['type'] == 'customActionResponse') {
        // Handle custom action responses
        final actionName = data['actionName'] as String?;
        if (actionName != null) {
          final response = data['response'] as Map<String, dynamic>?;
          _effectiveController.handleActionResponse(actionName, response);
        }
      } else if (data['type'] == 'pluginAction') {
        // Handle plugin action from JavaScript
        final actionName = data['actionName'] as String?;
        if (actionName != null) {
          final params = data['params'] as Map<String, dynamic>?;
          _effectiveController.handlePluginAction(actionName, params);
        }
      } else if (data['type'] == 'pluginToolbarClick') {
        // Handle plugin toolbar item click
        final itemId = data['itemId'] as String?;
        if (itemId != null) {
          final params = data['params'] as Map<String, dynamic>?;
          _effectiveController.executePluginAction(itemId, params: params);
        }
      }
    } catch (e) {
      // Only log errors if not disposed (disposed errors are expected)
      if (!_isDisposed) {
        debugPrint('QuillEditorWidget: Message parse error: $e');
      }
    }
  }

  void _initializeContent() {
    if (_hasInitializedContent) return;
    _hasInitializedContent = true;

    // Set default font IMMEDIATELY (no delay needed for styling)
    if (widget.defaultEditorFont != null &&
        widget.defaultEditorFont!.isNotEmpty) {
      setDefaultFont(widget.defaultEditorFont!);
    }

    // Small delay for content to allow editor to fully initialize
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.initialDelta != null) {
        setContents(widget.initialDelta);
      } else if (widget.initialHtml != null && widget.initialHtml!.isNotEmpty) {
        setHTML(widget.initialHtml!);
      }
    });
  }

  /// Set the default font for the editor.
  ///
  /// This font will be applied to new content and as the base font.
  void setDefaultFont(String fontValue) {
    _sendCommand({
      'action': 'setDefaultFont',
      'font': fontValue,
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

  /// Queues a command if the editor is not ready, or sends it immediately.
  void _sendCommand(Map<String, dynamic> data) {
    if (!_isReady || _iframe == null) {
      _enqueueCommand(data);
      return;
    }

    _dispatchCommand(data);
  }

  /// Adds a command to the queue.
  void _enqueueCommand(Map<String, dynamic> data) {
    // Prevent queue from growing indefinitely
    if (_commandQueue.length >= _maxQueueSize) {
      final dropped = _commandQueue.removeFirst();
      debugPrint(
        'QuillEditorWidget: Queue full, dropping oldest command: ${dropped['action']}',
      );
    }

    _commandQueue.addLast(Map<String, dynamic>.from(data));
    debugPrint(
      'QuillEditorWidget: Command queued: ${data['action']} '
      '(queue size: ${_commandQueue.length})',
    );
  }

  /// Processes all queued commands in FIFO order.
  void _processCommandQueue() {
    if (_isDisposed) return;
    if (_isProcessingQueue || _commandQueue.isEmpty) return;
    if (!_isReady || _iframe == null) return;

    _isProcessingQueue = true;
    debugPrint(
      'QuillEditorWidget: Processing ${_commandQueue.length} queued commands',
    );

    // Process all queued commands
    while (_commandQueue.isNotEmpty &&
        _isReady &&
        _iframe != null &&
        !_isDisposed) {
      final command = _commandQueue.removeFirst();
      _dispatchCommand(command);
    }

    _isProcessingQueue = false;
  }

  /// Dispatches a command to the iframe.
  void _dispatchCommand(Map<String, dynamic> data) {
    if (_iframe?.contentWindow == null) {
      debugPrint('QuillEditorWidget: Cannot dispatch - iframe not available');
      return;
    }

    data['source'] = 'flutter';
    data['type'] = 'command';
    final jsonString = jsonEncode(data);
    debugPrint('QuillEditorWidget: Sending command: ${data['action']}');
    _iframe!.contentWindow!.postMessage(jsonString, '*');
  }

  @override
  void dispose() {
    // Mark as disposed first to prevent message handler from using controller
    _isDisposed = true;

    // Clear any pending commands
    if (_commandQueue.isNotEmpty) {
      debugPrint(
        'QuillEditorWidget: Disposing with ${_commandQueue.length} queued commands',
      );
      _commandQueue.clear();
    }

    // Remove message listener before detaching controller
    html.window.removeEventListener('message', _handleMessage);

    // Dispose internal controller (we own it) or detach external controller
    if (_internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    } else {
      // External controller: just detach, owner is responsible for disposing
      widget.controller?.detach();
    }

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
