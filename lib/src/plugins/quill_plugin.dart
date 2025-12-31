import 'package:flutter/foundation.dart';

/// Represents a custom toolbar item that can be added by plugins.
///
/// Toolbar items can be buttons, dropdowns, or custom widgets that
/// integrate with the Quill editor toolbar.
///
/// ```dart
/// QuillToolbarItem(
///   id: 'my-button',
///   tooltip: 'My Custom Action',
///   icon: 'custom-icon', // CSS class or icon name
///   action: 'myCustomAction',
///   group: ToolbarGroup.format,
/// )
/// ```
class QuillToolbarItem {
  const QuillToolbarItem({
    required this.id,
    required this.tooltip,
    this.icon,
    this.iconWidget,
    this.action,
    this.handler,
    this.group = ToolbarGroup.custom,
    this.order = 100,
    this.dropdown,
    this.enabled = true,
  });

  /// Unique identifier for this toolbar item.
  final String id;

  /// Tooltip text shown on hover.
  final String tooltip;

  /// Icon name or CSS class for the button icon.
  final String? icon;

  /// Optional Flutter widget to use as the icon.
  /// If provided, takes precedence over [icon].
  final dynamic iconWidget;

  /// Action name to execute when clicked.
  /// This will be sent to the JavaScript editor.
  final String? action;

  /// Optional Dart callback handler.
  /// If provided, this is called in addition to the action.
  final VoidCallback? handler;

  /// Which toolbar group this item belongs to.
  final ToolbarGroup group;

  /// Order within the group (lower = earlier).
  final int order;

  /// If non-null, this toolbar item is a dropdown with options.
  final List<QuillDropdownOption>? dropdown;

  /// Whether this toolbar item is enabled.
  final bool enabled;

  /// Converts to a format suitable for JavaScript.
  Map<String, dynamic> toJson() => {
        'id': id,
        'tooltip': tooltip,
        'icon': icon,
        'action': action,
        'group': group.name,
        'order': order,
        'dropdown': dropdown?.map((o) => o.toJson()).toList(),
        'enabled': enabled,
      };

  QuillToolbarItem copyWith({
    String? id,
    String? tooltip,
    String? icon,
    dynamic iconWidget,
    String? action,
    VoidCallback? handler,
    ToolbarGroup? group,
    int? order,
    List<QuillDropdownOption>? dropdown,
    bool? enabled,
  }) {
    return QuillToolbarItem(
      id: id ?? this.id,
      tooltip: tooltip ?? this.tooltip,
      icon: icon ?? this.icon,
      iconWidget: iconWidget ?? this.iconWidget,
      action: action ?? this.action,
      handler: handler ?? this.handler,
      group: group ?? this.group,
      order: order ?? this.order,
      dropdown: dropdown ?? this.dropdown,
      enabled: enabled ?? this.enabled,
    );
  }
}

/// A dropdown option for toolbar dropdowns.
class QuillDropdownOption {
  const QuillDropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.selected = false,
  });

  final String value;
  final String label;
  final String? icon;
  final bool selected;

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'icon': icon,
        'selected': selected,
      };
}

/// Toolbar groups for organizing toolbar items.
enum ToolbarGroup {
  /// Text formatting (bold, italic, etc.)
  format,

  /// Font and size selection
  font,

  /// Paragraph formatting (alignment, lists)
  paragraph,

  /// Insert elements (link, image, video)
  insert,

  /// Tables
  table,

  /// History (undo, redo)
  history,

  /// View controls (zoom, preview)
  view,

  /// Custom plugins group
  custom,
}

/// Represents a custom Quill format that can be registered by plugins.
///
/// Formats define how content is styled or structured in the editor.
///
/// ```dart
/// QuillFormat(
///   name: 'mention',
///   type: FormatType.inline,
///   className: 'ql-mention',
///   cssStyles: {'background-color': '#e8f4fc', 'padding': '0 4px'},
/// )
/// ```
class QuillFormat {
  const QuillFormat({
    required this.name,
    required this.type,
    this.className,
    this.tagName,
    this.cssStyles,
    this.blotDefinition,
  });

  /// Name of the format (e.g., 'mention', 'hashtag').
  final String name;

  /// Type of format (inline, block, embed).
  final FormatType type;

  /// CSS class name for the format.
  final String? className;

  /// HTML tag name to use (e.g., 'span', 'div').
  final String? tagName;

  /// CSS styles to apply.
  final Map<String, String>? cssStyles;

  /// Advanced: Custom Blot definition (JavaScript code).
  /// This will be evaluated in the JavaScript context.
  final String? blotDefinition;

  /// Converts to a format suitable for JavaScript.
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.name,
        'className': className,
        'tagName': tagName,
        'cssStyles': cssStyles,
        'blotDefinition': blotDefinition,
      };
}

/// Types of Quill formats.
enum FormatType {
  /// Inline format (e.g., bold, italic, mention).
  inline,

  /// Block format (e.g., header, list, blockquote).
  block,

  /// Embed format (e.g., image, video, custom embed).
  embed,
}

/// Represents a custom Quill module that can be registered by plugins.
///
/// Modules add functionality to the editor beyond basic formatting.
///
/// ```dart
/// QuillModule(
///   name: 'autoLink',
///   options: {'urlPattern': r'https?://[^\s]+'},
///   initScript: '''
///     // JavaScript initialization code
///     console.log('AutoLink module initialized');
///   ''',
/// )
/// ```
class QuillModule {
  const QuillModule({
    required this.name,
    this.options = const {},
    this.initScript,
    this.dependsOn = const [],
  });

  /// Name of the module.
  final String name;

  /// Configuration options for the module.
  final Map<String, dynamic> options;

  /// JavaScript code to run when initializing this module.
  final String? initScript;

  /// List of module names this module depends on.
  final List<String> dependsOn;

  /// Converts to a format suitable for JavaScript.
  Map<String, dynamic> toJson() => {
        'name': name,
        'options': options,
        'initScript': initScript,
        'dependsOn': dependsOn,
      };
}

/// Represents a custom keyboard binding that can be registered by plugins.
///
/// ```dart
/// QuillKeyBinding(
///   key: 'k',
///   modifiers: [KeyModifier.ctrl],
///   action: 'insertLink',
///   description: 'Insert link',
/// )
/// ```
class QuillKeyBinding {
  const QuillKeyBinding({
    required this.key,
    required this.action,
    this.modifiers = const [],
    this.description,
    this.preventDefault = true,
  });

  /// The key to bind (e.g., 'k', 'Enter', 'Escape').
  final String key;

  /// Modifier keys required.
  final List<KeyModifier> modifiers;

  /// Action to execute when binding is triggered.
  final String action;

  /// Human-readable description of the binding.
  final String? description;

  /// Whether to prevent default browser behavior.
  final bool preventDefault;

  /// Converts to a format suitable for JavaScript.
  Map<String, dynamic> toJson() => {
        'key': key,
        'modifiers': modifiers.map((m) => m.name).toList(),
        'action': action,
        'description': description,
        'preventDefault': preventDefault,
      };
}

/// Keyboard modifiers for key bindings.
enum KeyModifier {
  ctrl,
  alt,
  shift,
  meta, // Command on Mac, Windows key on Windows
}

/// Represents custom CSS to be injected by plugins.
class QuillStylesheet {
  const QuillStylesheet({
    required this.css,
    this.id,
  });

  /// CSS code to inject.
  final String css;

  /// Optional unique ID to prevent duplicate injection.
  final String? id;
}

/// Base interface for all Quill editor plugins.
///
/// Plugins can extend the editor with custom:
/// - Toolbar items
/// - Formats (inline, block, embed)
/// - Modules
/// - Key bindings
/// - Stylesheets
/// - Command handlers
///
/// ## Creating a Plugin
///
/// ```dart
/// class MentionPlugin extends QuillPlugin {
///   @override
///   String get name => 'mention';
///
///   @override
///   String get version => '1.0.0';
///
///   @override
///   List<QuillFormat> get formats => [
///     QuillFormat(
///       name: 'mention',
///       type: FormatType.inline,
///       className: 'ql-mention',
///     ),
///   ];
///
///   @override
///   List<QuillToolbarItem> get toolbarItems => [
///     QuillToolbarItem(
///       id: 'mention',
///       tooltip: 'Mention someone',
///       icon: '@',
///       action: 'insertMention',
///     ),
///   ];
///
///   @override
///   Map<String, QuillCommandHandler> get commandHandlers => {
///     'insertMention': (params, controller) async {
///       // Show mention picker and insert
///       final user = await showMentionPicker();
///       if (user != null) {
///         controller.executeCustom(
///           action: 'insertMention',
///           parameters: {'user': user.toJson()},
///         );
///       }
///     },
///   };
/// }
/// ```
///
/// ## Registering a Plugin
///
/// ```dart
/// void main() {
///   // Register plugin before runApp
///   QuillPluginRegistry.instance.register(MentionPlugin());
///
///   runApp(MyApp());
/// }
/// ```
abstract class QuillPlugin {
  /// Unique name of this plugin.
  String get name;

  /// Version of this plugin.
  String get version => '1.0.0';

  /// Human-readable description of the plugin.
  String get description => '';

  /// List of other plugin names this plugin depends on.
  List<String> get dependencies => const [];

  /// Toolbar items provided by this plugin.
  List<QuillToolbarItem> get toolbarItems => const [];

  /// Custom formats provided by this plugin.
  List<QuillFormat> get formats => const [];

  /// Custom modules provided by this plugin.
  List<QuillModule> get modules => const [];

  /// Custom key bindings provided by this plugin.
  List<QuillKeyBinding> get keyBindings => const [];

  /// Custom stylesheets to inject.
  List<QuillStylesheet> get stylesheets => const [];

  /// Command handlers for custom actions.
  ///
  /// Keys are action names, values are handler functions.
  /// Handlers receive parameters and a controller reference.
  Map<String, QuillCommandHandler> get commandHandlers => const {};

  /// Called when the plugin is registered.
  /// Override to perform initialization.
  void onRegister() {}

  /// Called when the editor is initialized and ready.
  /// Override to perform editor-specific setup.
  void onEditorReady(dynamic controller) {}

  /// Called when the plugin is unregistered.
  /// Override to perform cleanup.
  void onUnregister() {}

  /// Converts plugin configuration to JSON for JavaScript.
  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'description': description,
        'dependencies': dependencies,
        'toolbarItems': toolbarItems.map((t) => t.toJson()).toList(),
        'formats': formats.map((f) => f.toJson()).toList(),
        'modules': modules.map((m) => m.toJson()).toList(),
        'keyBindings': keyBindings.map((k) => k.toJson()).toList(),
        'stylesheets':
            stylesheets.map((s) => {'css': s.css, 'id': s.id}).toList(),
      };

  @override
  String toString() => 'QuillPlugin($name v$version)';
}

/// Handler function type for custom commands.
///
/// [params] - Parameters passed with the command
/// [controller] - Reference to the QuillEditorController
typedef QuillCommandHandler = Future<void> Function(
  Map<String, dynamic>? params,
  dynamic controller,
);

/// A mixin that provides common plugin functionality.
mixin QuillPluginMixin on QuillPlugin {
  bool _isInitialized = false;

  /// Whether this plugin has been initialized.
  bool get isInitialized => _isInitialized;

  @override
  void onRegister() {
    _isInitialized = true;
    debugPrint('QuillPlugin: Registered ${toString()}');
  }

  @override
  void onUnregister() {
    _isInitialized = false;
    debugPrint('QuillPlugin: Unregistered ${toString()}');
  }
}
