import 'dart:async';

import 'package:flutter/foundation.dart';

import 'quill_plugin.dart';

/// Registry for managing Quill editor plugins.
///
/// This is a singleton that holds all registered plugins and provides
/// methods for plugin discovery and management.
///
/// ## Registering Plugins
///
/// ```dart
/// void main() {
///   // Register plugins before runApp
///   QuillPluginRegistry.instance
///     ..register(MentionPlugin())
///     ..register(EmojiPlugin())
///     ..register(CodeHighlightPlugin());
///
///   runApp(MyApp());
/// }
/// ```
///
/// ## Auto-discovery Pattern
///
/// Extension packages can register themselves using a top-level function:
///
/// ```dart
/// // In your_plugin package
/// void registerYourPlugin() {
///   QuillPluginRegistry.instance.register(YourPlugin());
/// }
/// ```
///
/// Then users can call this from their main:
/// ```dart
/// import 'package:your_plugin/your_plugin.dart';
///
/// void main() {
///   registerYourPlugin(); // Auto-registers the plugin
///   runApp(MyApp());
/// }
/// ```
class QuillPluginRegistry extends ChangeNotifier {
  QuillPluginRegistry._();

  static final QuillPluginRegistry _instance = QuillPluginRegistry._();

  /// The singleton instance of the plugin registry.
  static QuillPluginRegistry get instance => _instance;

  final Map<String, QuillPlugin> _plugins = {};
  final List<_PluginEventListener> _listeners = [];
  bool _isInitialized = false;

  /// Whether the registry has been initialized.
  bool get isInitialized => _isInitialized;

  /// List of all registered plugins.
  List<QuillPlugin> get plugins => List.unmodifiable(_plugins.values.toList());

  /// List of registered plugin names.
  List<String> get pluginNames => List.unmodifiable(_plugins.keys.toList());

  /// Number of registered plugins.
  int get pluginCount => _plugins.length;

  /// Registers a plugin.
  ///
  /// If a plugin with the same name is already registered, it will be
  /// replaced and the old plugin will receive [onUnregister].
  ///
  /// Returns `true` if registration was successful.
  bool register(QuillPlugin plugin) {
    // Check dependencies
    for (final dep in plugin.dependencies) {
      if (!_plugins.containsKey(dep)) {
        debugPrint(
          'QuillPluginRegistry: Warning - Plugin "${plugin.name}" depends on '
          '"$dep" which is not registered. Register dependencies first.',
        );
      }
    }

    // Unregister existing plugin with same name
    final existing = _plugins[plugin.name];
    if (existing != null) {
      debugPrint(
        'QuillPluginRegistry: Replacing existing plugin "${plugin.name}"',
      );
      existing.onUnregister();
    }

    _plugins[plugin.name] = plugin;

    try {
      plugin.onRegister();
      _notifyPluginEvent(PluginEvent.registered, plugin);
      notifyListeners();
      debugPrint(
        'QuillPluginRegistry: Registered "${plugin.name}" v${plugin.version}',
      );
      return true;
    } catch (e) {
      debugPrint(
        'QuillPluginRegistry: Error registering "${plugin.name}": $e',
      );
      _plugins.remove(plugin.name);
      return false;
    }
  }

  /// Registers multiple plugins at once.
  ///
  /// Plugins are registered in order, so dependencies should come first.
  void registerAll(List<QuillPlugin> plugins) {
    for (final plugin in plugins) {
      register(plugin);
    }
  }

  /// Unregisters a plugin by name.
  ///
  /// Returns the unregistered plugin, or null if not found.
  QuillPlugin? unregister(String name) {
    final plugin = _plugins.remove(name);
    if (plugin != null) {
      try {
        plugin.onUnregister();
      } catch (e) {
        debugPrint(
          'QuillPluginRegistry: Error during unregister of "$name": $e',
        );
      }
      _notifyPluginEvent(PluginEvent.unregistered, plugin);
      notifyListeners();
      debugPrint('QuillPluginRegistry: Unregistered "$name"');
    }
    return plugin;
  }

  /// Unregisters all plugins.
  void clear() {
    for (final plugin in _plugins.values.toList()) {
      try {
        plugin.onUnregister();
      } catch (e) {
        debugPrint(
          'QuillPluginRegistry: Error during unregister of "${plugin.name}": $e',
        );
      }
    }
    _plugins.clear();
    notifyListeners();
    debugPrint('QuillPluginRegistry: Cleared all plugins');
  }

  /// Gets a plugin by name.
  QuillPlugin? getPlugin(String name) => _plugins[name];

  /// Gets a plugin by type.
  T? getPluginByType<T extends QuillPlugin>() {
    for (final plugin in _plugins.values) {
      if (plugin is T) return plugin;
    }
    return null;
  }

  /// Checks if a plugin is registered.
  bool hasPlugin(String name) => _plugins.containsKey(name);

  /// Gets all toolbar items from all plugins.
  List<QuillToolbarItem> get allToolbarItems {
    final items = <QuillToolbarItem>[];
    for (final plugin in _plugins.values) {
      items.addAll(plugin.toolbarItems);
    }
    // Sort by group then by order
    items.sort((a, b) {
      final groupCompare = a.group.index.compareTo(b.group.index);
      if (groupCompare != 0) return groupCompare;
      return a.order.compareTo(b.order);
    });
    return items;
  }

  /// Gets all formats from all plugins.
  List<QuillFormat> get allFormats {
    final formats = <QuillFormat>[];
    for (final plugin in _plugins.values) {
      formats.addAll(plugin.formats);
    }
    return formats;
  }

  /// Gets all modules from all plugins.
  List<QuillModule> get allModules {
    final modules = <QuillModule>[];
    for (final plugin in _plugins.values) {
      modules.addAll(plugin.modules);
    }
    return modules;
  }

  /// Gets all key bindings from all plugins.
  List<QuillKeyBinding> get allKeyBindings {
    final bindings = <QuillKeyBinding>[];
    for (final plugin in _plugins.values) {
      bindings.addAll(plugin.keyBindings);
    }
    return bindings;
  }

  /// Gets all stylesheets from all plugins.
  List<QuillStylesheet> get allStylesheets {
    final sheets = <QuillStylesheet>[];
    for (final plugin in _plugins.values) {
      sheets.addAll(plugin.stylesheets);
    }
    return sheets;
  }

  /// Gets all command handlers from all plugins.
  Map<String, QuillCommandHandler> get allCommandHandlers {
    final handlers = <String, QuillCommandHandler>{};
    for (final plugin in _plugins.values) {
      handlers.addAll(plugin.commandHandlers);
    }
    return handlers;
  }

  /// Converts all plugin configurations to JSON for JavaScript.
  Map<String, dynamic> toJson() => {
        'plugins': _plugins.values.map((p) => p.toJson()).toList(),
        'toolbarItems': allToolbarItems.map((t) => t.toJson()).toList(),
        'formats': allFormats.map((f) => f.toJson()).toList(),
        'modules': allModules.map((m) => m.toJson()).toList(),
        'keyBindings': allKeyBindings.map((k) => k.toJson()).toList(),
        'stylesheets': allStylesheets.map((s) => {'css': s.css, 'id': s.id}).toList(),
      };

  /// Notifies all plugins that the editor is ready.
  void notifyEditorReady(dynamic controller) {
    _isInitialized = true;
    for (final plugin in _plugins.values) {
      try {
        plugin.onEditorReady(controller);
      } catch (e) {
        debugPrint(
          'QuillPluginRegistry: Error in onEditorReady for "${plugin.name}": $e',
        );
      }
    }
  }

  /// Adds a listener for plugin events.
  void addPluginEventListener(
    void Function(PluginEvent event, QuillPlugin plugin) listener,
  ) {
    _listeners.add(_PluginEventListener(listener));
  }

  /// Removes a plugin event listener.
  void removePluginEventListener(
    void Function(PluginEvent event, QuillPlugin plugin) listener,
  ) {
    _listeners.removeWhere((l) => l.callback == listener);
  }

  void _notifyPluginEvent(PluginEvent event, QuillPlugin plugin) {
    for (final listener in _listeners) {
      try {
        listener.callback(event, plugin);
      } catch (e) {
        debugPrint('QuillPluginRegistry: Error in event listener: $e');
      }
    }
  }

  /// Handles an incoming custom action, delegating to the appropriate plugin.
  ///
  /// Returns `true` if a handler was found and executed.
  Future<bool> handleAction(
    String actionName,
    Map<String, dynamic>? params,
    dynamic controller,
  ) async {
    final handlers = allCommandHandlers;
    final handler = handlers[actionName];
    if (handler != null) {
      try {
        await handler(params, controller);
        return true;
      } catch (e) {
        debugPrint(
          'QuillPluginRegistry: Error handling action "$actionName": $e',
        );
      }
    }
    return false;
  }

  @override
  void dispose() {
    clear();
    _listeners.clear();
    super.dispose();
  }
}

/// Plugin lifecycle events.
enum PluginEvent {
  /// Plugin was registered.
  registered,

  /// Plugin was unregistered.
  unregistered,
}

class _PluginEventListener {
  _PluginEventListener(this.callback);
  final void Function(PluginEvent event, QuillPlugin plugin) callback;
}

/// Extension methods for convenient plugin access.
extension QuillPluginRegistryExtension on QuillPluginRegistry {
  /// Gets toolbar items for a specific group.
  List<QuillToolbarItem> toolbarItemsForGroup(ToolbarGroup group) {
    return allToolbarItems.where((item) => item.group == group).toList();
  }

  /// Gets formats of a specific type.
  List<QuillFormat> formatsOfType(FormatType type) {
    return allFormats.where((format) => format.type == type).toList();
  }

  /// Checks if any plugin provides a specific format.
  bool hasFormat(String formatName) {
    return allFormats.any((format) => format.name == formatName);
  }

  /// Checks if any plugin handles a specific action.
  bool hasHandler(String actionName) {
    return allCommandHandlers.containsKey(actionName);
  }

  /// Gets a summary of registered plugins for debugging.
  String debugSummary() {
    final buffer = StringBuffer()
      ..writeln('QuillPluginRegistry Summary:')
      ..writeln('  Plugins: $pluginCount');

    for (final plugin in plugins) {
      buffer.writeln('    - ${plugin.name} v${plugin.version}');
      if (plugin.toolbarItems.isNotEmpty) {
        buffer.writeln(
          '      Toolbar items: ${plugin.toolbarItems.length}',
        );
      }
      if (plugin.formats.isNotEmpty) {
        buffer.writeln('      Formats: ${plugin.formats.length}');
      }
      if (plugin.modules.isNotEmpty) {
        buffer.writeln('      Modules: ${plugin.modules.length}');
      }
      if (plugin.keyBindings.isNotEmpty) {
        buffer.writeln('      Key bindings: ${plugin.keyBindings.length}');
      }
      if (plugin.commandHandlers.isNotEmpty) {
        buffer.writeln('      Handlers: ${plugin.commandHandlers.length}');
      }
    }

    return buffer.toString();
  }
}

