/// Plugin system for extending Quill Web Editor.
///
/// This module provides:
/// - [QuillPlugin] - Base class for creating plugins
/// - [QuillPluginRegistry] - Singleton for managing plugins
/// - Built-in plugins for common features
///
/// ## Creating a Plugin Package
///
/// To create a plugin package that integrates with quill_web_editor:
///
/// 1. Create a new Dart package
/// 2. Add quill_web_editor as a dependency
/// 3. Create your plugin class extending [QuillPlugin]
/// 4. Export a registration function
///
/// ```dart
/// // In your my_quill_plugin/lib/my_quill_plugin.dart
/// library my_quill_plugin;
///
/// import 'package:quill_web_editor/quill_web_editor.dart';
///
/// class MyPlugin extends QuillPlugin with QuillPluginMixin {
///   @override
///   String get name => 'my-plugin';
///
///   @override
///   List<QuillToolbarItem> get toolbarItems => [...];
/// }
///
/// /// Call this to register the plugin
/// void registerMyPlugin() {
///   QuillPluginRegistry.instance.register(MyPlugin());
/// }
/// ```
///
/// 5. Users can then use your plugin:
///
/// ```dart
/// import 'package:quill_web_editor/quill_web_editor.dart';
/// import 'package:my_quill_plugin/my_quill_plugin.dart';
///
/// void main() {
///   registerMyPlugin();
///   runApp(MyApp());
/// }
/// ```
library plugins;

export 'built_in_plugins.dart';
export 'quill_plugin.dart';
export 'quill_plugin_registry.dart';

