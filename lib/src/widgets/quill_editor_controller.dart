import 'package:flutter/foundation.dart';

import '../core/constants/editor_config.dart';

/// Callback signature for sending commands to the Quill editor.
typedef SendCommandCallback = void Function(Map<String, dynamic> data);

/// Callback signature for custom action handlers.
///
/// [response] contains the response data from the editor (if any).
typedef CustomActionCallback = void Function(Map<String, dynamic>? response);

/// Represents a user-defined custom action.
///
/// Custom actions can be registered with [QuillEditorController] and
/// executed to perform custom operations on the editor.
class QuillEditorAction {
  /// Creates a custom action.
  ///
  /// [name] - Unique identifier for this action
  /// [parameters] - Optional parameters to send with the action
  /// [onExecute] - Optional callback when action is executed
  /// [onResponse] - Optional callback when response is received
  const QuillEditorAction({
    required this.name,
    this.parameters = const {},
    this.onExecute,
    this.onResponse,
  });

  /// Unique name/identifier for this action.
  final String name;

  /// Parameters to send with the action.
  final Map<String, dynamic> parameters;

  /// Callback invoked when the action is executed.
  final VoidCallback? onExecute;

  /// Callback invoked when a response is received for this action.
  final CustomActionCallback? onResponse;

  /// Creates a copy of this action with updated parameters.
  QuillEditorAction copyWith({
    String? name,
    Map<String, dynamic>? parameters,
    VoidCallback? onExecute,
    CustomActionCallback? onResponse,
  }) {
    return QuillEditorAction(
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      onExecute: onExecute ?? this.onExecute,
      onResponse: onResponse ?? this.onResponse,
    );
  }
}

/// Controller for [QuillEditorWidget].
///
/// Similar to [TextEditingController], this controller provides programmatic
/// control over the Quill editor without needing to use GlobalKey.
///
/// ## Basic Usage
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
///     _controller.dispose();
///     super.dispose();
///   }
///
///   void _insertText() {
///     _controller.insertText('Hello World!');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return QuillEditorWidget(controller: _controller);
///   }
/// }
/// ```
///
/// ## Custom Actions
/// ```dart
/// // Register a custom action
/// _controller.registerAction(
///   QuillEditorAction(
///     name: 'highlightText',
///     parameters: {'color': '#FFFF00'},
///     onExecute: () => print('Highlighting text...'),
///     onResponse: (response) => print('Highlighted: $response'),
///   ),
/// );
///
/// // Execute the action
/// _controller.executeAction('highlightText');
///
/// // Or execute with custom parameters
/// _controller.executeAction('highlightText', parameters: {'color': '#FF0000'});
///
/// // Execute a one-off custom action
/// _controller.executeCustom(
///   action: 'myCustomAction',
///   parameters: {'key': 'value'},
/// );
/// ```
class QuillEditorController extends ChangeNotifier {
  SendCommandCallback? _sendCommand;
  bool _isReady = false;
  double _currentZoom = EditorConfig.defaultZoom;
  String _currentHtml = '';

  /// Registered custom actions.
  final Map<String, QuillEditorAction> _registeredActions = {};

  /// Pending action responses.
  final Map<String, CustomActionCallback> _pendingResponses = {};

  /// Whether the editor is ready to receive commands.
  bool get isReady => _isReady;

  /// Current zoom level (1.0 = 100%).
  double get currentZoom => _currentZoom;

  /// Current HTML content of the editor.
  String get html => _currentHtml;

  /// List of registered action names.
  List<String> get registeredActionNames => _registeredActions.keys.toList();

  // ============================================================
  // Custom Actions API
  // ============================================================

  /// Registers a custom action that can be executed later.
  ///
  /// ```dart
  /// controller.registerAction(
  ///   QuillEditorAction(
  ///     name: 'insertSignature',
  ///     parameters: {'signature': 'Best regards,\nJohn'},
  ///     onExecute: () => print('Inserting signature...'),
  ///   ),
  /// );
  /// ```
  void registerAction(QuillEditorAction action) {
    _registeredActions[action.name] = action;
    notifyListeners();
  }

  /// Registers multiple custom actions at once.
  void registerActions(List<QuillEditorAction> actions) {
    for (final action in actions) {
      _registeredActions[action.name] = action;
    }
    notifyListeners();
  }

  /// Unregisters a custom action by name.
  void unregisterAction(String actionName) {
    _registeredActions.remove(actionName);
    _pendingResponses.remove(actionName);
    notifyListeners();
  }

  /// Clears all registered custom actions.
  void clearActions() {
    _registeredActions.clear();
    _pendingResponses.clear();
    notifyListeners();
  }

  /// Checks if an action is registered.
  bool hasAction(String actionName) =>
      _registeredActions.containsKey(actionName);

  /// Gets a registered action by name.
  QuillEditorAction? getAction(String actionName) =>
      _registeredActions[actionName];

  /// Executes a registered custom action.
  ///
  /// [actionName] - Name of the registered action to execute
  /// [parameters] - Optional parameters to override the action's default parameters
  /// [onResponse] - Optional callback to override the action's default response handler
  ///
  /// Returns `true` if the action was found and executed, `false` otherwise.
  ///
  /// ```dart
  /// // Execute with default parameters
  /// controller.executeAction('insertSignature');
  ///
  /// // Execute with custom parameters
  /// controller.executeAction('insertSignature', parameters: {
  ///   'signature': 'Cheers,\nJane',
  /// });
  /// ```
  bool executeAction(
    String actionName, {
    Map<String, dynamic>? parameters,
    CustomActionCallback? onResponse,
  }) {
    final action = _registeredActions[actionName];
    if (action == null) {
      debugPrint('QuillEditorController: Action "$actionName" not registered');
      return false;
    }

    // Merge parameters
    final mergedParams = {...action.parameters, ...?parameters};

    // Call onExecute callback
    action.onExecute?.call();

    // Register response handler if provided
    final responseHandler = onResponse ?? action.onResponse;
    if (responseHandler != null) {
      _pendingResponses[actionName] = responseHandler;
    }

    // Execute the command
    _executeCommand({
      'action': 'customAction',
      'customActionName': actionName,
      ...mergedParams,
    });

    return true;
  }

  /// Executes a one-off custom action without registering it.
  ///
  /// Use this for quick custom commands that don't need to be reused.
  ///
  /// ```dart
  /// controller.executeCustom(
  ///   action: 'scrollToTop',
  ///   parameters: {'smooth': true},
  ///   onResponse: (response) => print('Scrolled: $response'),
  /// );
  /// ```
  void executeCustom({
    required String action,
    Map<String, dynamic>? parameters,
    CustomActionCallback? onResponse,
  }) {
    if (onResponse != null) {
      _pendingResponses[action] = onResponse;
    }

    _executeCommand({
      'action': 'customAction',
      'customActionName': action,
      ...?parameters,
    });
  }

  /// Handles a response for a custom action.
  /// This is called internally by [QuillEditorWidget].
  void handleActionResponse(String actionName, Map<String, dynamic>? response) {
    final handler = _pendingResponses.remove(actionName);
    handler?.call(response);
  }

  // ============================================================
  // Built-in Actions
  // ============================================================

  /// Attaches this controller to a widget's command sender.
  /// This is called internally by [QuillEditorWidget].
  // ignore: use_setters_to_change_properties
  void attach(SendCommandCallback sendCommand) => _sendCommand = sendCommand;

  /// Detaches this controller from the widget.
  /// This is called internally by [QuillEditorWidget].
  void detach() {
    _sendCommand = null;
    _isReady = false;
    // Note: We don't call dispose() here because the controller may be reused.
    // dispose() is called separately when the controller is no longer needed.
  }

  /// Marks the editor as ready.
  /// This is called internally by [QuillEditorWidget].
  void markReady() {
    _isReady = true;
    notifyListeners();
  }

  /// Updates the current HTML content.
  /// This is called internally by [QuillEditorWidget].
  void updateHtml(String html) {
    _currentHtml = html;
    notifyListeners();
  }

  /// Insert text at the current cursor position.
  void insertText(String text) {
    _executeCommand({
      'action': 'insertText',
      'text': text,
    });
  }

  /// Set the editor contents from a Delta object.
  void setContents(dynamic delta) {
    _executeCommand({
      'action': 'setContents',
      'delta': delta,
    });
  }

  /// Set the editor contents from HTML string.
  ///
  /// If [replace] is true (default), replaces all content.
  /// If [replace] is false, inserts at cursor position.
  void setHTML(String html, {bool replace = true}) {
    _executeCommand({
      'action': 'setHTML',
      'html': html,
      'replace': replace,
    });
  }

  /// Insert HTML at cursor position.
  ///
  /// If [replace] is true, replaces all existing content first.
  void insertHtml(String html, {bool replace = false}) {
    _executeCommand({
      'action': 'insertHtml',
      'html': html,
      'replace': replace,
    });
  }

  /// Request the current editor contents.
  ///
  /// Response will come through onContentChanged callback.
  void getContents() {
    _executeCommand({
      'action': 'getContents',
    });
  }

  /// Clear all editor content.
  void clear() {
    _executeCommand({
      'action': 'clear',
    });
    _currentHtml = '';
    notifyListeners();
  }

  /// Focus the editor.
  void focus() {
    _executeCommand({
      'action': 'focus',
    });
  }

  /// Undo the last operation.
  void undo() {
    _executeCommand({
      'action': 'undo',
    });
  }

  /// Redo the last undone operation.
  void redo() {
    _executeCommand({
      'action': 'redo',
    });
  }

  /// Apply formatting to the current selection or cursor position.
  ///
  /// [format] - The format name (e.g., 'bold', 'italic', 'color', 'font', 'size')
  /// [value] - The format value (e.g., true for bold, '#ff0000' for color)
  void format(String format, dynamic value) {
    _executeCommand({
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
    _executeCommand({
      'action': 'insertTable',
      'rows': rows,
      'cols': cols,
    });
  }

  /// Zoom in the editor (increase by [EditorConfig.zoomStep]).
  void zoomIn() {
    _currentZoom = (_currentZoom + EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _executeCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
    notifyListeners();
  }

  /// Zoom out the editor (decrease by [EditorConfig.zoomStep]).
  void zoomOut() {
    _currentZoom = (_currentZoom - EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _executeCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
    notifyListeners();
  }

  /// Reset zoom to 100%.
  void resetZoom() {
    _currentZoom = EditorConfig.defaultZoom;
    _executeCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
    notifyListeners();
  }

  /// Set zoom to specific level (clamped to min/max).
  void setZoom(double level) {
    _currentZoom = level.clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _executeCommand({
      'action': 'setZoom',
      'zoom': _currentZoom,
    });
    notifyListeners();
  }

  void _executeCommand(Map<String, dynamic> data) {
    if (_sendCommand == null) {
      debugPrint('QuillEditorController: Not attached to widget');
      return;
    }
    _sendCommand!(data);
  }

  @override
  void dispose() {
    _registeredActions.clear();
    _pendingResponses.clear();
    detach();
    super.dispose();
  }
}
