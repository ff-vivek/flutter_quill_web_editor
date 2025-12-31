# Quill Web Editor Plugin System

The plugin system allows you to extend the Quill Web Editor with custom features from other packages. When a user adds a plugin package to their `pubspec.yaml`, that package can automatically integrate its features into the editor.

## Table of Contents

1. [Overview](#overview)
2. [Using Plugins](#using-plugins)
3. [Creating a Plugin](#creating-a-plugin)
4. [Creating a Plugin Package](#creating-a-plugin-package)
5. [Plugin API Reference](#plugin-api-reference)
6. [Built-in Plugins](#built-in-plugins)
7. [Best Practices](#best-practices)

## Overview

The plugin system consists of:

- **QuillPlugin** - Base class for all plugins
- **QuillPluginRegistry** - Singleton that manages plugin registration
- **Plugin Features** - Toolbar items, formats, modules, key bindings, stylesheets

When a plugin is registered, it can contribute:
- Custom toolbar buttons and dropdowns
- Custom text formats (inline, block, embed)
- Custom Quill modules
- Custom keyboard shortcuts
- Custom CSS stylesheets
- Command handlers for custom actions

## Using Plugins

### Installing a Plugin Package

```yaml
# pubspec.yaml
dependencies:
  quill_web_editor: ^1.2.0
  quill_mention_plugin: ^1.0.0  # Example plugin package
```

### Registering Plugins

Register plugins in your `main()` before `runApp()`:

```dart
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';
import 'package:quill_mention_plugin/quill_mention_plugin.dart';

void main() {
  // Register plugins before runApp
  QuillPluginRegistry.instance
    ..register(MentionPlugin())
    ..register(EmojiPlugin())
    ..register(HashtagPlugin());
  
  runApp(MyApp());
}
```

### Using Plugins with Controller

```dart
class _EditorPageState extends State<EditorPage> {
  final _controller = QuillEditorController();

  @override
  void initState() {
    super.initState();
    
    // You can also register plugins via controller
    _controller.registerPlugin(MyCustomPlugin());
    
    // Check if a plugin is available
    if (_controller.hasPlugin('mention')) {
      print('Mention plugin is available!');
    }
    
    // Get plugin toolbar items
    final items = _controller.pluginToolbarItems;
    print('Plugin toolbar items: ${items.length}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditorWidget(
      controller: _controller,
      onContentChanged: (html, delta) {
        print('Content changed');
      },
    );
  }
}
```

## Creating a Plugin

### Basic Plugin

```dart
import 'package:quill_web_editor/quill_web_editor.dart';

class MyPlugin extends QuillPlugin with QuillPluginMixin {
  @override
  String get name => 'my-plugin';
  
  @override
  String get version => '1.0.0';
  
  @override
  String get description => 'My awesome plugin';
}
```

### Plugin with Toolbar Items

```dart
class HighlightPlugin extends QuillPlugin with QuillPluginMixin {
  @override
  String get name => 'highlight';
  
  @override
  List<QuillToolbarItem> get toolbarItems => [
    QuillToolbarItem(
      id: 'highlight-yellow',
      tooltip: 'Highlight Yellow',
      icon: 'ql-highlight-yellow',
      action: 'applyHighlight',
      group: ToolbarGroup.format,
      order: 50,
    ),
    QuillToolbarItem(
      id: 'highlight-picker',
      tooltip: 'Highlight Color',
      icon: 'ql-highlight',
      group: ToolbarGroup.format,
      order: 51,
      dropdown: [
        QuillDropdownOption(value: 'yellow', label: 'Yellow'),
        QuillDropdownOption(value: 'green', label: 'Green'),
        QuillDropdownOption(value: 'blue', label: 'Blue'),
      ],
    ),
  ];
}
```

### Plugin with Custom Formats

```dart
class SpoilerPlugin extends QuillPlugin with QuillPluginMixin {
  @override
  String get name => 'spoiler';
  
  @override
  List<QuillFormat> get formats => [
    QuillFormat(
      name: 'spoiler',
      type: FormatType.inline,
      className: 'ql-spoiler',
      tagName: 'span',
      cssStyles: {
        'background-color': '#000',
        'color': '#000',
      },
    ),
  ];
  
  @override
  List<QuillStylesheet> get stylesheets => [
    QuillStylesheet(
      id: 'spoiler-styles',
      css: '''
        .ql-spoiler {
          background-color: #000;
          color: #000;
          cursor: pointer;
          border-radius: 3px;
          padding: 0 2px;
        }
        .ql-spoiler:hover,
        .ql-spoiler.revealed {
          background-color: transparent;
          color: inherit;
        }
      ''',
    ),
  ];
}
```

### Plugin with Command Handlers

```dart
class InsertTemplatePlugin extends QuillPlugin with QuillPluginMixin {
  final List<Map<String, String>> templates;
  
  InsertTemplatePlugin({required this.templates});
  
  @override
  String get name => 'insert-template';
  
  @override
  List<QuillToolbarItem> get toolbarItems => [
    QuillToolbarItem(
      id: 'insert-template',
      tooltip: 'Insert Template',
      icon: 'ql-template',
      group: ToolbarGroup.insert,
      dropdown: templates.map((t) => QuillDropdownOption(
        value: t['id']!,
        label: t['name']!,
      )).toList(),
    ),
  ];
  
  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
    'insertTemplate': (params, controller) async {
      final templateId = params?['templateId'] as String?;
      final template = templates.firstWhere(
        (t) => t['id'] == templateId,
        orElse: () => {},
      );
      
      if (template.isNotEmpty && controller != null) {
        controller.insertHtml(template['content']!);
      }
    },
  };
}
```

### Plugin with Key Bindings

```dart
class QuickSavePlugin extends QuillPlugin with QuillPluginMixin {
  final Future<void> Function(String html) onSave;
  
  QuickSavePlugin({required this.onSave});
  
  @override
  String get name => 'quick-save';
  
  @override
  List<QuillKeyBinding> get keyBindings => [
    QuillKeyBinding(
      key: 's',
      modifiers: [KeyModifier.ctrl],
      action: 'quickSave',
      description: 'Quick save',
    ),
    QuillKeyBinding(
      key: 's',
      modifiers: [KeyModifier.ctrl, KeyModifier.shift],
      action: 'saveAs',
      description: 'Save as',
    ),
  ];
  
  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
    'quickSave': (params, controller) async {
      if (controller != null) {
        await onSave(controller.html);
      }
    },
  };
}
```

## Creating a Plugin Package

### 1. Create the Package Structure

```
my_quill_plugin/
├── lib/
│   ├── my_quill_plugin.dart      # Main export file
│   └── src/
│       └── my_plugin.dart        # Plugin implementation
├── pubspec.yaml
└── README.md
```

### 2. Define pubspec.yaml

```yaml
name: my_quill_plugin
description: A plugin for quill_web_editor that adds awesome features
version: 1.0.0

environment:
  sdk: ^3.0.0

dependencies:
  quill_web_editor: ^1.2.0
```

### 3. Implement the Plugin

```dart
// lib/src/my_plugin.dart
import 'package:quill_web_editor/quill_web_editor.dart';

class MyPlugin extends QuillPlugin with QuillPluginMixin {
  @override
  String get name => 'my-plugin';
  
  @override
  String get version => '1.0.0';
  
  // ... plugin implementation
}
```

### 4. Create the Main Export File

```dart
// lib/my_quill_plugin.dart
library my_quill_plugin;

import 'package:quill_web_editor/quill_web_editor.dart';
import 'src/my_plugin.dart';

export 'src/my_plugin.dart';

/// Register the plugin with a single call
void registerMyQuillPlugin() {
  QuillPluginRegistry.instance.register(MyPlugin());
}
```

### 5. Document Usage

```markdown
# My Quill Plugin

## Installation

Add to your pubspec.yaml:

\`\`\`yaml
dependencies:
  quill_web_editor: ^1.2.0
  my_quill_plugin: ^1.0.0
\`\`\`

## Usage

\`\`\`dart
import 'package:my_quill_plugin/my_quill_plugin.dart';

void main() {
  registerMyQuillPlugin(); // That's it!
  runApp(MyApp());
}
\`\`\`
```

## Plugin API Reference

### QuillPlugin

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Unique identifier for the plugin |
| `version` | `String` | Plugin version (default: '1.0.0') |
| `description` | `String` | Human-readable description |
| `dependencies` | `List<String>` | Other plugins this depends on |
| `toolbarItems` | `List<QuillToolbarItem>` | Toolbar buttons/dropdowns |
| `formats` | `List<QuillFormat>` | Custom text formats |
| `modules` | `List<QuillModule>` | Custom Quill modules |
| `keyBindings` | `List<QuillKeyBinding>` | Keyboard shortcuts |
| `stylesheets` | `List<QuillStylesheet>` | CSS to inject |
| `commandHandlers` | `Map<String, QuillCommandHandler>` | Action handlers |

### QuillToolbarItem

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier |
| `tooltip` | `String` | Hover tooltip |
| `icon` | `String?` | CSS class or icon name |
| `action` | `String?` | Action to execute |
| `handler` | `VoidCallback?` | Dart callback |
| `group` | `ToolbarGroup` | Toolbar section |
| `order` | `int` | Position in group |
| `dropdown` | `List<QuillDropdownOption>?` | Dropdown options |
| `enabled` | `bool` | Whether enabled |

### ToolbarGroup

- `format` - Text formatting (bold, italic, etc.)
- `font` - Font and size selection
- `paragraph` - Alignment, lists
- `insert` - Links, images, videos
- `table` - Table operations
- `history` - Undo, redo
- `view` - Zoom, preview
- `custom` - Plugin items

### QuillFormat

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Format identifier |
| `type` | `FormatType` | inline, block, or embed |
| `className` | `String?` | CSS class |
| `tagName` | `String?` | HTML tag |
| `cssStyles` | `Map<String, String>?` | Inline styles |
| `blotDefinition` | `String?` | Custom Blot JS code |

### QuillModule

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Module name |
| `options` | `Map<String, dynamic>` | Configuration |
| `initScript` | `String?` | JavaScript init code |
| `dependsOn` | `List<String>` | Required modules |

### QuillKeyBinding

| Property | Type | Description |
|----------|------|-------------|
| `key` | `String` | Key to bind |
| `modifiers` | `List<KeyModifier>` | Ctrl, Alt, Shift, Meta |
| `action` | `String` | Action to execute |
| `description` | `String?` | Human-readable |
| `preventDefault` | `bool` | Prevent default behavior |

### QuillPluginRegistry

| Method | Description |
|--------|-------------|
| `register(plugin)` | Register a plugin |
| `registerAll(plugins)` | Register multiple plugins |
| `unregister(name)` | Remove a plugin |
| `clear()` | Remove all plugins |
| `getPlugin(name)` | Get plugin by name |
| `getPluginByType<T>()` | Get plugin by type |
| `hasPlugin(name)` | Check if registered |
| `allToolbarItems` | Get all toolbar items |
| `allFormats` | Get all formats |
| `allModules` | Get all modules |
| `allKeyBindings` | Get all key bindings |
| `allStylesheets` | Get all stylesheets |
| `allCommandHandlers` | Get all handlers |

## Built-in Plugins

### EmojiPlugin

Adds emoji picker support.

```dart
QuillPluginRegistry.instance.register(EmojiPlugin());
```

### MentionPlugin

Adds @mention support with autocomplete.

```dart
QuillPluginRegistry.instance.register(MentionPlugin(
  triggerChar: '@',
  onMentionTriggered: (query) async {
    return await searchUsers(query);
  },
));
```

### HashtagPlugin

Adds #hashtag support.

```dart
QuillPluginRegistry.instance.register(HashtagPlugin(
  onHashtagClicked: (tag) => print('Clicked: $tag'),
));
```

### CodeHighlightPlugin

Adds syntax highlighting for code blocks.

```dart
QuillPluginRegistry.instance.register(CodeHighlightPlugin(
  theme: 'github',
  languages: ['javascript', 'python', 'dart'],
));
```

### AutoLinkPlugin

Auto-detects and converts URLs to links.

```dart
QuillPluginRegistry.instance.register(AutoLinkPlugin());
```

### WordCountPlugin

Shows word and character count.

```dart
QuillPluginRegistry.instance.register(WordCountPlugin(
  showWordCount: true,
  showCharacterCount: true,
  maxWords: 1000,
));
```

### PluginBundle

Group multiple plugins together:

```dart
final socialPack = PluginBundle(
  bundleName: 'social-pack',
  bundledPlugins: [
    MentionPlugin(),
    HashtagPlugin(),
    EmojiPlugin(),
  ],
);

QuillPluginRegistry.instance.register(socialPack);
```

## Best Practices

### 1. Unique Plugin Names

Use unique, descriptive names to avoid conflicts:

```dart
// Good
@override
String get name => 'acme-company-mention';

// Bad - too generic
@override
String get name => 'mention';
```

### 2. Declare Dependencies

If your plugin requires other plugins:

```dart
@override
List<String> get dependencies => ['some-other-plugin'];
```

### 3. Provide CSS IDs

Prevent duplicate stylesheet injection:

```dart
QuillStylesheet(
  id: 'my-plugin-styles',  // Unique ID
  css: '...',
)
```

### 4. Handle Errors Gracefully

```dart
@override
Map<String, QuillCommandHandler> get commandHandlers => {
  'myAction': (params, controller) async {
    try {
      // Your logic
    } catch (e) {
      debugPrint('MyPlugin error: $e');
      // Fail gracefully
    }
  },
};
```

### 5. Clean Up Resources

```dart
@override
void onUnregister() {
  // Clean up any resources
  _subscription?.cancel();
  super.onUnregister();
}
```

### 6. Version Your Plugin

Follow semantic versioning:

```dart
@override
String get version => '1.2.3';
```

### 7. Document Your Plugin

Provide clear documentation for users:

- Installation instructions
- Configuration options
- Usage examples
- API reference

