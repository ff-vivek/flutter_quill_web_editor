import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/plugins/built_in_plugins.dart';
import 'package:quill_web_editor/src/plugins/quill_plugin.dart';
import 'package:quill_web_editor/src/plugins/quill_plugin_registry.dart';

/// Tests for the Plugin System, including EmojiPlugin and QuillPluginRegistry.
void main() {
  group('EmojiPlugin Tests', () {
    late EmojiPlugin plugin;

    setUp(() {
      plugin = EmojiPlugin();
    });

    test('Should have correct name', () {
      expect(plugin.name, equals('emoji'));
    });

    test('Should have correct version', () {
      expect(plugin.version, equals('1.0.0'));
    });

    test('Should have correct description', () {
      expect(plugin.description, equals('Adds emoji picker to the editor toolbar'));
    });

    test('Should have no dependencies', () {
      expect(plugin.dependencies, isEmpty);
    });

    test('Should provide one toolbar item', () {
      expect(plugin.toolbarItems, hasLength(1));
    });

    test('Should have correct toolbar item properties', () {
      final item = plugin.toolbarItems.first;

      expect(item.id, equals('emoji-picker'));
      expect(item.tooltip, contains('Insert emoji'));
      expect(item.icon, equals('ql-emoji'));
      expect(item.action, equals('showEmojiPicker'));
      expect(item.group, equals(ToolbarGroup.insert));
      expect(item.order, equals(50));
      expect(item.enabled, isTrue);
      expect(item.dropdown, isNull);
    });

    test('Should provide one format', () {
      expect(plugin.formats, hasLength(1));
    });

    test('Should have correct format properties', () {
      final format = plugin.formats.first;

      expect(format.name, equals('emoji'));
      expect(format.type, equals(FormatType.inline));
      expect(format.className, equals('ql-emoji'));
      expect(format.tagName, equals('span'));
      expect(format.cssStyles, isNull);
      expect(format.blotDefinition, isNull);
    });

    test('Should have emoji module', () {
      expect(plugin.modules, hasLength(1));
      expect(plugin.modules.first.name, equals('emoji'));
    });

    test('Should have no key bindings', () {
      expect(plugin.keyBindings, isEmpty);
    });

    test('Should have emoji picker stylesheet', () {
      expect(plugin.stylesheets, hasLength(1));
      expect(plugin.stylesheets.first.id, equals('emoji-picker-styles'));
    });

    test('Should have command handlers for emoji actions', () {
      expect(plugin.commandHandlers, isNotEmpty);
      expect(plugin.commandHandlers.containsKey('showEmojiPicker'), isTrue);
      expect(plugin.commandHandlers.containsKey('insertEmoji'), isTrue);
    });

    test('Should convert to JSON correctly', () {
      final json = plugin.toJson();

      expect(json['name'], equals('emoji'));
      expect(json['version'], equals('1.0.0'));
      expect(json['description'], equals('Adds emoji picker to the editor toolbar'));
      expect(json['dependencies'], isEmpty);
      expect(json['toolbarItems'], hasLength(1));
      expect(json['formats'], hasLength(1));
      expect(json['modules'], hasLength(1));
      expect(json['keyBindings'], isEmpty);
      expect(json['stylesheets'], hasLength(1));
    });

    test('Should have correct toString representation', () {
      expect(plugin.toString(), equals('QuillPlugin(emoji v1.0.0)'));
    });

    test('Should track initialization with mixin', () {
      expect(plugin.isInitialized, isFalse);

      plugin.onRegister();
      expect(plugin.isInitialized, isTrue);

      plugin.onUnregister();
      expect(plugin.isInitialized, isFalse);
    });

    test('Toolbar item should convert to JSON correctly', () {
      final item = plugin.toolbarItems.first;
      final json = item.toJson();

      expect(json['id'], equals('emoji-picker'));
      expect(json['tooltip'], contains('Insert emoji'));
      expect(json['icon'], equals('ql-emoji'));
      expect(json['action'], equals('showEmojiPicker'));
      expect(json['group'], equals('insert'));
      expect(json['order'], equals(50));
      expect(json['enabled'], isTrue);
      expect(json['dropdown'], isNull);
    });

    test('Format should convert to JSON correctly', () {
      final format = plugin.formats.first;
      final json = format.toJson();

      expect(json['name'], equals('emoji'));
      expect(json['type'], equals('inline'));
      expect(json['className'], equals('ql-emoji'));
      expect(json['tagName'], equals('span'));
    });

    test('Should support skin tone option', () {
      final plugin = EmojiPlugin(skinTone: EmojiSkinTone.medium);
      
      expect(plugin.skinTone, equals(EmojiSkinTone.medium));
      expect(plugin.modules.first.options['skinTone'], equals(EmojiSkinTone.medium.index));
    });

    test('Should support recent emojis option', () {
      final recentEmojis = ['😀', '👍', '❤️'];
      final plugin = EmojiPlugin(recentEmojis: recentEmojis);
      
      expect(plugin.recentEmojis, equals(recentEmojis));
      expect(plugin.modules.first.options['recentEmojis'], equals(recentEmojis));
    });
  });

  group('EmojiPlugin insertEmoji Handler Tests', () {
    test('insertEmoji handler should NOT call insertText on controller', () async {
      // This test verifies that the insertEmoji handler does NOT insert text
      // because the emoji is already inserted by JavaScript.
      // Inserting here would cause duplicates!
      
      var insertTextCalled = false;
      final mockController = _MockEmojiController(
        onInsertText: (text) => insertTextCalled = true,
      );

      final plugin = EmojiPlugin();
      final handler = plugin.commandHandlers['insertEmoji']!;

      // Simulate receiving an emoji from JavaScript
      await handler({'emoji': '😀'}, mockController);

      // The handler should NOT call insertText (JS already inserted it)
      expect(insertTextCalled, isFalse);
    });

    test('insertEmoji handler should call onEmojiSelected callback', () async {
      String? selectedEmoji;
      
      final plugin = EmojiPlugin(
        onEmojiSelected: (emoji) => selectedEmoji = emoji,
      );
      final handler = plugin.commandHandlers['insertEmoji']!;

      await handler({'emoji': '🎉'}, null);

      expect(selectedEmoji, equals('🎉'));
    });

    test('insertEmoji handler should handle null emoji gracefully', () async {
      String? selectedEmoji;
      
      final plugin = EmojiPlugin(
        onEmojiSelected: (emoji) => selectedEmoji = emoji,
      );
      final handler = plugin.commandHandlers['insertEmoji']!;

      await handler({}, null);

      expect(selectedEmoji, isNull);
    });

    test('insertEmoji handler should handle null params gracefully', () async {
      String? selectedEmoji;
      
      final plugin = EmojiPlugin(
        onEmojiSelected: (emoji) => selectedEmoji = emoji,
      );
      final handler = plugin.commandHandlers['insertEmoji']!;

      await handler(null, null);

      expect(selectedEmoji, isNull);
    });

    test('showEmojiPicker handler should not throw', () async {
      final plugin = EmojiPlugin();
      final handler = plugin.commandHandlers['showEmojiPicker']!;

      // Should not throw
      await handler({}, null);
    });
  });

  group('QuillToolbarItem Tests', () {
    test('Should create toolbar item with required parameters', () {
      const item = QuillToolbarItem(
        id: 'test-item',
        tooltip: 'Test tooltip',
      );

      expect(item.id, equals('test-item'));
      expect(item.tooltip, equals('Test tooltip'));
      expect(item.icon, isNull);
      expect(item.iconWidget, isNull);
      expect(item.action, isNull);
      expect(item.handler, isNull);
      expect(item.group, equals(ToolbarGroup.custom));
      expect(item.order, equals(100));
      expect(item.dropdown, isNull);
      expect(item.enabled, isTrue);
    });

    test('Should create toolbar item with all parameters', () {
      var handlerCalled = false;

      final item = QuillToolbarItem(
        id: 'full-item',
        tooltip: 'Full tooltip',
        icon: 'ql-test',
        action: 'testAction',
        handler: () => handlerCalled = true,
        group: ToolbarGroup.format,
        order: 25,
        dropdown: const [
          QuillDropdownOption(value: 'a', label: 'Option A'),
          QuillDropdownOption(value: 'b', label: 'Option B'),
        ],
        enabled: false,
      );

      expect(item.id, equals('full-item'));
      expect(item.tooltip, equals('Full tooltip'));
      expect(item.icon, equals('ql-test'));
      expect(item.action, equals('testAction'));
      expect(item.group, equals(ToolbarGroup.format));
      expect(item.order, equals(25));
      expect(item.enabled, isFalse);
      expect(item.dropdown, hasLength(2));

      item.handler?.call();
      expect(handlerCalled, isTrue);
    });

    test('Should copy toolbar item with updated values', () {
      const original = QuillToolbarItem(
        id: 'original',
        tooltip: 'Original',
        icon: 'ql-original',
        order: 10,
      );

      final copied = original.copyWith(
        tooltip: 'Copied',
        order: 20,
      );

      expect(copied.id, equals('original')); // Unchanged
      expect(copied.tooltip, equals('Copied')); // Updated
      expect(copied.icon, equals('ql-original')); // Unchanged
      expect(copied.order, equals(20)); // Updated
    });

    test('Should convert dropdown options to JSON', () {
      const option = QuillDropdownOption(
        value: 'test-value',
        label: 'Test Label',
        icon: 'test-icon',
        selected: true,
      );

      final json = option.toJson();

      expect(json['value'], equals('test-value'));
      expect(json['label'], equals('Test Label'));
      expect(json['icon'], equals('test-icon'));
      expect(json['selected'], isTrue);
    });
  });

  group('QuillFormat Tests', () {
    test('Should create format with required parameters', () {
      const format = QuillFormat(
        name: 'test-format',
        type: FormatType.inline,
      );

      expect(format.name, equals('test-format'));
      expect(format.type, equals(FormatType.inline));
      expect(format.className, isNull);
      expect(format.tagName, isNull);
      expect(format.cssStyles, isNull);
      expect(format.blotDefinition, isNull);
    });

    test('Should create format with all parameters', () {
      const format = QuillFormat(
        name: 'full-format',
        type: FormatType.block,
        className: 'ql-custom',
        tagName: 'div',
        cssStyles: {'color': 'red', 'font-size': '14px'},
        blotDefinition: 'CustomBlot extends Blot {}',
      );

      expect(format.name, equals('full-format'));
      expect(format.type, equals(FormatType.block));
      expect(format.className, equals('ql-custom'));
      expect(format.tagName, equals('div'));
      expect(format.cssStyles, hasLength(2));
      expect(format.cssStyles!['color'], equals('red'));
      expect(format.blotDefinition, isNotEmpty);
    });

    test('Should support all format types', () {
      expect(FormatType.values, contains(FormatType.inline));
      expect(FormatType.values, contains(FormatType.block));
      expect(FormatType.values, contains(FormatType.embed));
    });
  });

  group('QuillModule Tests', () {
    test('Should create module with required parameters', () {
      const module = QuillModule(name: 'test-module');

      expect(module.name, equals('test-module'));
      expect(module.options, isEmpty);
      expect(module.initScript, isNull);
      expect(module.dependsOn, isEmpty);
    });

    test('Should create module with all parameters', () {
      const module = QuillModule(
        name: 'full-module',
        options: {'option1': true, 'option2': 'value'},
        initScript: 'console.log("init");',
        dependsOn: ['other-module'],
      );

      expect(module.name, equals('full-module'));
      expect(module.options['option1'], isTrue);
      expect(module.options['option2'], equals('value'));
      expect(module.initScript, equals('console.log("init");'));
      expect(module.dependsOn, contains('other-module'));
    });

    test('Should convert module to JSON correctly', () {
      const module = QuillModule(
        name: 'json-module',
        options: {'key': 'value'},
        dependsOn: ['dep1', 'dep2'],
      );

      final json = module.toJson();

      expect(json['name'], equals('json-module'));
      expect(json['options'], isA<Map<String, dynamic>>());
      expect(json['dependsOn'], hasLength(2));
    });
  });

  group('QuillKeyBinding Tests', () {
    test('Should create key binding with required parameters', () {
      const binding = QuillKeyBinding(
        key: 's',
        action: 'save',
      );

      expect(binding.key, equals('s'));
      expect(binding.action, equals('save'));
      expect(binding.modifiers, isEmpty);
      expect(binding.description, isNull);
      expect(binding.preventDefault, isTrue);
    });

    test('Should create key binding with all parameters', () {
      const binding = QuillKeyBinding(
        key: 'k',
        action: 'insertLink',
        modifiers: [KeyModifier.ctrl, KeyModifier.shift],
        description: 'Insert link',
        preventDefault: false,
      );

      expect(binding.key, equals('k'));
      expect(binding.action, equals('insertLink'));
      expect(binding.modifiers, hasLength(2));
      expect(binding.modifiers, contains(KeyModifier.ctrl));
      expect(binding.modifiers, contains(KeyModifier.shift));
      expect(binding.description, equals('Insert link'));
      expect(binding.preventDefault, isFalse);
    });

    test('Should support all key modifiers', () {
      expect(KeyModifier.values, contains(KeyModifier.ctrl));
      expect(KeyModifier.values, contains(KeyModifier.alt));
      expect(KeyModifier.values, contains(KeyModifier.shift));
      expect(KeyModifier.values, contains(KeyModifier.meta));
    });

    test('Should convert key binding to JSON correctly', () {
      const binding = QuillKeyBinding(
        key: 'b',
        action: 'bold',
        modifiers: [KeyModifier.ctrl],
        description: 'Toggle bold',
      );

      final json = binding.toJson();

      expect(json['key'], equals('b'));
      expect(json['action'], equals('bold'));
      expect(json['modifiers'], contains('ctrl'));
      expect(json['description'], equals('Toggle bold'));
      expect(json['preventDefault'], isTrue);
    });
  });

  group('QuillStylesheet Tests', () {
    test('Should create stylesheet with required parameters', () {
      const stylesheet = QuillStylesheet(css: '.test { color: red; }');

      expect(stylesheet.css, equals('.test { color: red; }'));
      expect(stylesheet.id, isNull);
    });

    test('Should create stylesheet with ID', () {
      const stylesheet = QuillStylesheet(
        css: '.test { color: blue; }',
        id: 'test-styles',
      );

      expect(stylesheet.css, equals('.test { color: blue; }'));
      expect(stylesheet.id, equals('test-styles'));
    });
  });

  group('QuillPluginRegistry Tests', () {
    late QuillPluginRegistry registry;

    setUp(() {
      // Get the singleton and clear it
      registry = QuillPluginRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('Should be a singleton', () {
      final registry1 = QuillPluginRegistry.instance;
      final registry2 = QuillPluginRegistry.instance;

      expect(registry1, same(registry2));
    });

    test('Should start empty', () {
      expect(registry.plugins, isEmpty);
      expect(registry.pluginNames, isEmpty);
      expect(registry.pluginCount, equals(0));
    });

    test('Should register a plugin', () {
      final plugin = EmojiPlugin();

      final result = registry.register(plugin);

      expect(result, isTrue);
      expect(registry.pluginCount, equals(1));
      expect(registry.hasPlugin('emoji'), isTrue);
      expect(registry.pluginNames, contains('emoji'));
    });

    test('Should register multiple plugins', () {
      registry.registerAll([
        EmojiPlugin(),
        HashtagPlugin(),
      ]);

      expect(registry.pluginCount, equals(2));
      expect(registry.hasPlugin('emoji'), isTrue);
      expect(registry.hasPlugin('hashtag'), isTrue);
    });

    test('Should get plugin by name', () {
      registry.register(EmojiPlugin());

      final plugin = registry.getPlugin('emoji');

      expect(plugin, isNotNull);
      expect(plugin!.name, equals('emoji'));
    });

    test('Should return null for non-existent plugin', () {
      expect(registry.getPlugin('nonexistent'), isNull);
      expect(registry.hasPlugin('nonexistent'), isFalse);
    });

    test('Should get plugin by type', () {
      registry.register(EmojiPlugin());
      registry.register(HashtagPlugin());

      final plugin = registry.getPluginByType<EmojiPlugin>();

      expect(plugin, isNotNull);
      expect(plugin, isA<EmojiPlugin>());
    });

    test('Should unregister a plugin', () {
      registry.register(EmojiPlugin());
      expect(registry.hasPlugin('emoji'), isTrue);

      final removed = registry.unregister('emoji');

      expect(removed, isNotNull);
      expect(removed!.name, equals('emoji'));
      expect(registry.hasPlugin('emoji'), isFalse);
    });

    test('Should return null when unregistering non-existent plugin', () {
      final removed = registry.unregister('nonexistent');

      expect(removed, isNull);
    });

    test('Should clear all plugins', () {
      registry.registerAll([
        EmojiPlugin(),
        HashtagPlugin(),
      ]);
      expect(registry.pluginCount, equals(2));

      registry.clear();

      expect(registry.pluginCount, equals(0));
      expect(registry.plugins, isEmpty);
    });

    test('Should replace plugin with same name', () {
      final plugin1 = _TestPlugin(name: 'test', version: '1.0.0');
      final plugin2 = _TestPlugin(name: 'test', version: '2.0.0');

      registry.register(plugin1);
      registry.register(plugin2);

      expect(registry.pluginCount, equals(1));
      expect(registry.getPlugin('test')?.version, equals('2.0.0'));
    });

    test('Should notify listeners on registration', () {
      var notified = false;
      registry.addListener(() => notified = true);

      registry.register(EmojiPlugin());

      expect(notified, isTrue);
    });

    test('Should notify listeners on unregistration', () {
      registry.register(EmojiPlugin());

      var notified = false;
      registry.addListener(() => notified = true);

      registry.unregister('emoji');

      expect(notified, isTrue);
    });

    test('Should aggregate toolbar items from all plugins', () {
      registry.registerAll([
        EmojiPlugin(),
        HashtagPlugin(),
      ]);

      final items = registry.allToolbarItems;

      expect(items, hasLength(1)); // Only EmojiPlugin has toolbar items
      expect(items.first.id, equals('emoji-picker'));
    });

    test('Should aggregate formats from all plugins', () {
      registry.registerAll([
        EmojiPlugin(),
        HashtagPlugin(),
      ]);

      final formats = registry.allFormats;

      expect(formats, hasLength(2)); // emoji + hashtag formats
    });

    test('Should aggregate stylesheets from all plugins', () {
      registry.register(HashtagPlugin());

      final stylesheets = registry.allStylesheets;

      expect(stylesheets, hasLength(1));
      expect(stylesheets.any((s) => s.id == 'hashtag-styles'), isTrue);
    });

    test('Should sort toolbar items by group and order', () {
      registry.registerAll([
        _TestPlugin(
          name: 'p1',
          toolbarItems: [
            const QuillToolbarItem(
              id: 'item1',
              tooltip: 'Item 1',
              group: ToolbarGroup.insert,
              order: 100,
            ),
          ],
        ),
        _TestPlugin(
          name: 'p2',
          toolbarItems: [
            const QuillToolbarItem(
              id: 'item2',
              tooltip: 'Item 2',
              group: ToolbarGroup.format,
              order: 50,
            ),
          ],
        ),
        _TestPlugin(
          name: 'p3',
          toolbarItems: [
            const QuillToolbarItem(
              id: 'item3',
              tooltip: 'Item 3',
              group: ToolbarGroup.format,
              order: 25,
            ),
          ],
        ),
      ]);

      final items = registry.allToolbarItems;

      // Should be sorted by group first (format < insert), then by order
      expect(items[0].id, equals('item3')); // format, order 25
      expect(items[1].id, equals('item2')); // format, order 50
      expect(items[2].id, equals('item1')); // insert, order 100
    });

    test('Should convert registry to JSON', () {
      registry.register(EmojiPlugin());

      final json = registry.toJson();

      expect(json['plugins'], isA<List<Map<String, dynamic>>>());
      expect(json['toolbarItems'], isA<List<Map<String, dynamic>>>());
      expect(json['formats'], isA<List<Map<String, dynamic>>>());
      expect(json['modules'], isA<List<Map<String, dynamic>>>());
      expect(json['keyBindings'], isA<List<Map<String, dynamic>>>());
      expect(json['stylesheets'], isA<List<Map<String, dynamic>>>());
    });

    test('Should provide debug summary', () {
      registry.register(EmojiPlugin());

      final summary = registry.debugSummary();

      expect(summary, contains('QuillPluginRegistry Summary'));
      expect(summary, contains('Plugins: 1'));
      expect(summary, contains('emoji'));
    });

    test('Should get toolbar items for specific group', () {
      registry.register(EmojiPlugin());

      final insertItems = registry.toolbarItemsForGroup(ToolbarGroup.insert);
      final formatItems = registry.toolbarItemsForGroup(ToolbarGroup.format);

      expect(insertItems, hasLength(1));
      expect(formatItems, isEmpty);
    });

    test('Should get formats of specific type', () {
      registry.registerAll([EmojiPlugin(), HashtagPlugin()]);

      final inlineFormats = registry.formatsOfType(FormatType.inline);
      final blockFormats = registry.formatsOfType(FormatType.block);

      expect(inlineFormats, hasLength(2));
      expect(blockFormats, isEmpty);
    });

    test('Should check if format exists', () {
      registry.register(EmojiPlugin());

      expect(registry.hasFormat('emoji'), isTrue);
      expect(registry.hasFormat('nonexistent'), isFalse);
    });

    test('Should fire plugin events', () {
      PluginEvent? lastEvent;
      QuillPlugin? lastPlugin;

      registry.addPluginEventListener((event, plugin) {
        lastEvent = event;
        lastPlugin = plugin;
      });

      registry.register(EmojiPlugin());
      expect(lastEvent, equals(PluginEvent.registered));
      expect(lastPlugin?.name, equals('emoji'));

      registry.unregister('emoji');
      expect(lastEvent, equals(PluginEvent.unregistered));
    });

    test('Should call onRegister on plugin registration', () {
      final plugin = EmojiPlugin();
      expect(plugin.isInitialized, isFalse);

      registry.register(plugin);

      expect(plugin.isInitialized, isTrue);
    });

    test('Should call onUnregister on plugin removal', () {
      final plugin = EmojiPlugin();
      registry.register(plugin);
      expect(plugin.isInitialized, isTrue);

      registry.unregister('emoji');

      expect(plugin.isInitialized, isFalse);
    });
  });

  group('PluginBundle Tests', () {
    test('Should bundle multiple plugins', () {
      final bundle = PluginBundle(
        bundleName: 'test-bundle',
        bundledPlugins: [
          EmojiPlugin(),
          HashtagPlugin(),
        ],
      );

      expect(bundle.name, equals('test-bundle'));
      expect(bundle.toolbarItems, hasLength(1)); // From EmojiPlugin
      expect(bundle.formats, hasLength(2)); // emoji + hashtag
      expect(bundle.stylesheets, hasLength(2)); // From EmojiPlugin + HashtagPlugin
    });

    test('Should aggregate command handlers from bundled plugins', () {
      final bundle = PluginBundle(
        bundleName: 'handler-bundle',
        bundledPlugins: [
          _TestPlugin(
            name: 'p1',
            commandHandlers: {
              'action1': (_, __) async {},
            },
          ),
          _TestPlugin(
            name: 'p2',
            commandHandlers: {
              'action2': (_, __) async {},
            },
          ),
        ],
      );

      expect(bundle.commandHandlers, hasLength(2));
      expect(bundle.commandHandlers.containsKey('action1'), isTrue);
      expect(bundle.commandHandlers.containsKey('action2'), isTrue);
    });

    test('Should call lifecycle methods on all bundled plugins', () {
      final plugin1 = EmojiPlugin();
      final plugin2 = HashtagPlugin();

      final bundle = PluginBundle(
        bundleName: 'lifecycle-bundle',
        bundledPlugins: [plugin1, plugin2],
      );

      bundle.onRegister();
      expect(plugin1.isInitialized, isTrue);

      bundle.onUnregister();
      expect(plugin1.isInitialized, isFalse);
    });
  });

  group('MentionPlugin Tests', () {
    test('Should create with default trigger char', () {
      final plugin = MentionPlugin();

      expect(plugin.name, equals('mention'));
      expect(plugin.triggerChar, equals('@'));
    });

    test('Should create with custom trigger char', () {
      final plugin = MentionPlugin(triggerChar: '#');

      expect(plugin.triggerChar, equals('#'));
    });

    test('Should have mention format', () {
      final plugin = MentionPlugin();

      expect(plugin.formats, hasLength(1));
      expect(plugin.formats.first.name, equals('mention'));
      expect(plugin.formats.first.type, equals(FormatType.inline));
    });

    test('Should have mention module with trigger char', () {
      final plugin = MentionPlugin(triggerChar: '+');

      expect(plugin.modules, hasLength(1));
      expect(plugin.modules.first.name, equals('mention'));
      expect(plugin.modules.first.options['triggerChar'], equals('+'));
    });

    test('Should have mention stylesheet', () {
      final plugin = MentionPlugin();

      expect(plugin.stylesheets, hasLength(1));
      expect(plugin.stylesheets.first.id, equals('mention-styles'));
      expect(plugin.stylesheets.first.css, contains('.ql-mention'));
    });

    test('Should have triggerMention command handler', () {
      final plugin = MentionPlugin();

      expect(plugin.commandHandlers.containsKey('triggerMention'), isTrue);
    });
  });

  group('HashtagPlugin Tests', () {
    test('Should have hashtag format', () {
      final plugin = HashtagPlugin();

      expect(plugin.formats, hasLength(1));
      expect(plugin.formats.first.name, equals('hashtag'));
      expect(plugin.formats.first.className, equals('ql-hashtag'));
    });

    test('Should have hashtag stylesheet', () {
      final plugin = HashtagPlugin();

      expect(plugin.stylesheets, hasLength(1));
      expect(plugin.stylesheets.first.id, equals('hashtag-styles'));
      expect(plugin.stylesheets.first.css, contains('.ql-hashtag'));
    });
  });

  group('CodeHighlightPlugin Tests', () {
    test('Should create with default theme and languages', () {
      final plugin = CodeHighlightPlugin();

      expect(plugin.theme, equals('github'));
      expect(plugin.languages, contains('javascript'));
      expect(plugin.languages, contains('dart'));
    });

    test('Should create with custom theme and languages', () {
      final plugin = CodeHighlightPlugin(
        theme: 'monokai',
        languages: ['rust', 'go'],
      );

      expect(plugin.theme, equals('monokai'));
      expect(plugin.languages, hasLength(2));
      expect(plugin.languages, contains('rust'));
    });

    test('Should have syntax module', () {
      final plugin = CodeHighlightPlugin();

      expect(plugin.modules, hasLength(1));
      expect(plugin.modules.first.name, equals('syntax'));
      expect(plugin.modules.first.options['theme'], equals('github'));
    });

    test('Should have code language toolbar dropdown', () {
      final plugin = CodeHighlightPlugin();

      expect(plugin.toolbarItems, hasLength(1));
      expect(plugin.toolbarItems.first.dropdown, isNotNull);
      expect(plugin.toolbarItems.first.dropdown, hasLength(5)); // 5 default languages
    });
  });

  group('AutoLinkPlugin Tests', () {
    test('Should create with no patterns', () {
      final plugin = AutoLinkPlugin();

      expect(plugin.modules, hasLength(1));
      expect(plugin.modules.first.name, equals('autoLink'));
      expect(plugin.modules.first.options, isEmpty);
    });

    test('Should create with custom patterns', () {
      final plugin = AutoLinkPlugin(
        urlPattern: r'https?://\S+',
        emailPattern: r'\S+@\S+\.\S+',
      );

      expect(plugin.modules.first.options['urlPattern'], isNotNull);
      expect(plugin.modules.first.options['emailPattern'], isNotNull);
    });
  });

  group('WordCountPlugin Tests', () {
    test('Should create with default options', () {
      final plugin = WordCountPlugin();

      expect(plugin.showWordCount, isTrue);
      expect(plugin.showCharacterCount, isTrue);
      expect(plugin.maxWords, isNull);
      expect(plugin.maxCharacters, isNull);
    });

    test('Should create with limits', () {
      final plugin = WordCountPlugin(
        maxWords: 1000,
        maxCharacters: 5000,
      );

      final options = plugin.modules.first.options;
      expect(options['maxWords'], equals(1000));
      expect(options['maxCharacters'], equals(5000));
    });
  });

  group('Plugin Action Execution Tests', () {
    late QuillPluginRegistry registry;

    setUp(() {
      registry = QuillPluginRegistry.instance;
      registry.clear();
    });

    tearDown(() {
      registry.clear();
    });

    test('Should execute command handler when action is called', () async {
      var handlerCalled = false;
      Map<String, dynamic>? receivedParams;

      final plugin = _TestPlugin(
        name: 'action-test',
        commandHandlers: {
          'testAction': (params, controller) async {
            handlerCalled = true;
            receivedParams = params;
          },
        },
      );

      registry.register(plugin);

      // Execute the action
      await registry.handleAction('testAction', {'key': 'value'}, null);

      expect(handlerCalled, isTrue);
      expect(receivedParams, isNotNull);
      expect(receivedParams!['key'], equals('value'));
    });

    test('Should return false when no handler exists', () async {
      final result = await registry.handleAction('nonexistent', {}, null);
      expect(result, isFalse);
    });

    test('Should return true when handler exists and executes', () async {
      final plugin = _TestPlugin(
        name: 'handler-test',
        commandHandlers: {
          'existingAction': (params, controller) async {},
        },
      );

      registry.register(plugin);

      final result = await registry.handleAction('existingAction', {}, null);
      expect(result, isTrue);
    });

    test('Should pass controller to handler', () async {
      dynamic receivedController;

      final plugin = _TestPlugin(
        name: 'controller-test',
        commandHandlers: {
          'controllerAction': (params, controller) async {
            receivedController = controller;
          },
        },
      );

      registry.register(plugin);

      final mockController = 'mock-controller';
      await registry.handleAction('controllerAction', {}, mockController);

      expect(receivedController, equals(mockController));
    });

    test('Should handle dropdown value parameter', () async {
      String? receivedValue;

      final plugin = _TestPlugin(
        name: 'dropdown-test',
        toolbarItems: [
          const QuillToolbarItem(
            id: 'dropdown-item',
            tooltip: 'Test Dropdown',
            action: 'handleDropdown',
            dropdown: [
              QuillDropdownOption(value: 'option1', label: 'Option 1'),
              QuillDropdownOption(value: 'option2', label: 'Option 2'),
            ],
          ),
        ],
        commandHandlers: {
          'handleDropdown': (params, controller) async {
            receivedValue = params?['value'] as String?;
          },
        },
      );

      registry.register(plugin);

      // Simulate dropdown selection
      await registry.handleAction('handleDropdown', {'value': 'option2'}, null);

      expect(receivedValue, equals('option2'));
    });

    test('Should aggregate handlers from multiple plugins', () async {
      var handler1Called = false;
      var handler2Called = false;

      registry.registerAll([
        _TestPlugin(
          name: 'plugin1',
          commandHandlers: {
            'action1': (_, __) async => handler1Called = true,
          },
        ),
        _TestPlugin(
          name: 'plugin2',
          commandHandlers: {
            'action2': (_, __) async => handler2Called = true,
          },
        ),
      ]);

      await registry.handleAction('action1', {}, null);
      await registry.handleAction('action2', {}, null);

      expect(handler1Called, isTrue);
      expect(handler2Called, isTrue);
    });
  });

  group('Template Insert Plugin Tests', () {
    test('Should have insertTemplate command handler', () {
      final templates = [
        {'id': 'greeting', 'name': 'Greeting', 'content': '<p>Hello!</p>'},
      ];

      final plugin = _TemplatePlugin(templates: templates);

      expect(plugin.commandHandlers.containsKey('insertTemplate'), isTrue);
    });

    test('Should have toolbar item with dropdown', () {
      final templates = [
        {'id': 't1', 'name': 'Template 1', 'content': '<p>1</p>'},
        {'id': 't2', 'name': 'Template 2', 'content': '<p>2</p>'},
      ];

      final plugin = _TemplatePlugin(templates: templates);

      expect(plugin.toolbarItems, hasLength(1));
      expect(plugin.toolbarItems.first.dropdown, hasLength(2));
      expect(plugin.toolbarItems.first.action, equals('insertTemplate'));
    });

    test('Should find template by id', () async {
      String? insertedContent;

      final templates = [
        {'id': 'greeting', 'name': 'Greeting', 'content': '<p>Hello World!</p>'},
        {'id': 'signature', 'name': 'Signature', 'content': '<p>Best regards</p>'},
      ];

      final mockController = _MockController(
        onInsertHtml: (html) => insertedContent = html,
      );

      final plugin = _TemplatePlugin(templates: templates);
      final handler = plugin.commandHandlers['insertTemplate']!;

      await handler({'value': 'greeting'}, mockController);

      expect(insertedContent, equals('<p>Hello World!</p>'));
    });

    test('Should handle templateId parameter as well as value', () async {
      String? insertedContent;

      final templates = [
        {'id': 'sig', 'name': 'Signature', 'content': '<p>Regards</p>'},
      ];

      final mockController = _MockController(
        onInsertHtml: (html) => insertedContent = html,
      );

      final plugin = _TemplatePlugin(templates: templates);
      final handler = plugin.commandHandlers['insertTemplate']!;

      // Using templateId instead of value
      await handler({'templateId': 'sig'}, mockController);

      expect(insertedContent, equals('<p>Regards</p>'));
    });

    test('Should not insert when template not found', () async {
      String? insertedContent;

      final templates = [
        {'id': 'existing', 'name': 'Existing', 'content': '<p>Content</p>'},
      ];

      final mockController = _MockController(
        onInsertHtml: (html) => insertedContent = html,
      );

      final plugin = _TemplatePlugin(templates: templates);
      final handler = plugin.commandHandlers['insertTemplate']!;

      await handler({'value': 'nonexistent'}, mockController);

      expect(insertedContent, isNull);
    });

    test('Should call onInsert callback with template id', () async {
      String? insertedTemplateId;

      final templates = [
        {'id': 'test', 'name': 'Test', 'content': '<p>Test</p>'},
      ];

      final mockController = _MockController(onInsertHtml: (_) {});

      final plugin = _TemplatePlugin(
        templates: templates,
        onInsert: (id) => insertedTemplateId = id,
      );

      final handler = plugin.commandHandlers['insertTemplate']!;
      await handler({'value': 'test'}, mockController);

      expect(insertedTemplateId, equals('test'));
    });

    test('Should not call onInsert when template not found', () async {
      var onInsertCalled = false;

      final templates = [
        {'id': 'existing', 'name': 'Existing', 'content': '<p>Content</p>'},
      ];

      final mockController = _MockController(onInsertHtml: (_) {});

      final plugin = _TemplatePlugin(
        templates: templates,
        onInsert: (id) => onInsertCalled = true,
      );

      final handler = plugin.commandHandlers['insertTemplate']!;
      await handler({'value': 'nonexistent'}, mockController);

      expect(onInsertCalled, isFalse);
    });

    test('Should handle null params gracefully', () async {
      String? insertedContent;

      final templates = [
        {'id': 'test', 'name': 'Test', 'content': '<p>Test</p>'},
      ];

      final mockController = _MockController(
        onInsertHtml: (html) => insertedContent = html,
      );

      final plugin = _TemplatePlugin(templates: templates);
      final handler = plugin.commandHandlers['insertTemplate']!;

      await handler(null, mockController);

      expect(insertedContent, isNull);
    });

    test('Should handle empty params gracefully', () async {
      String? insertedContent;

      final templates = [
        {'id': 'test', 'name': 'Test', 'content': '<p>Test</p>'},
      ];

      final mockController = _MockController(
        onInsertHtml: (html) => insertedContent = html,
      );

      final plugin = _TemplatePlugin(templates: templates);
      final handler = plugin.commandHandlers['insertTemplate']!;

      await handler({}, mockController);

      expect(insertedContent, isNull);
    });
  });

  // ==========================================================================
  // Find and Replace Plugin Tests
  // ==========================================================================
  group('Find and Replace Plugin Tests', () {
    late _TestFindReplacePlugin plugin;

    setUp(() {
      plugin = _TestFindReplacePlugin();
    });

    test('Should have correct name', () {
      expect(plugin.name, equals('find-replace'));
    });

    test('Should have correct version', () {
      expect(plugin.version, equals('1.0.0'));
    });

    test('Should have correct description', () {
      expect(plugin.description, equals('Find and replace text in the editor'));
    });

    test('Should have toolbar item with correct properties', () {
      expect(plugin.toolbarItems, hasLength(1));

      final item = plugin.toolbarItems.first;
      expect(item.id, equals('find-replace'));
      expect(item.tooltip, contains('Find and Replace'));
      expect(item.action, equals('showFindReplace'));
      expect(item.group, equals(ToolbarGroup.view));
    });

    test('Should have keyboard bindings for Ctrl+F and Ctrl+H', () {
      expect(plugin.keyBindings, hasLength(2));

      final ctrlF = plugin.keyBindings.firstWhere((k) => k.key == 'f');
      expect(ctrlF.modifiers, contains(KeyModifier.ctrl));
      expect(ctrlF.action, equals('showFindReplace'));

      final ctrlH = plugin.keyBindings.firstWhere((k) => k.key == 'h');
      expect(ctrlH.modifiers, contains(KeyModifier.ctrl));
      expect(ctrlH.action, equals('showFindReplace'));
    });

    group('Find functionality', () {
      test('Should find simple text matches', () {
        plugin.setSearchText('fox');
        final matches = plugin.findAllMatches(
            'The quick brown fox jumps over the lazy fox');

        expect(matches, hasLength(2));
        expect(matches[0], equals(16)); // First 'fox' position
        expect(matches[1], equals(40)); // Second 'fox' position
      });

      test('Should be case-insensitive by default', () {
        plugin.setSearchText('FOX');
        final matches = plugin.findAllMatches(
            'The quick brown fox jumps over the lazy Fox');

        expect(matches, hasLength(2));
      });

      test('Should respect case-sensitive setting', () {
        plugin.setSearchText('FOX');
        plugin.setCaseSensitive(true);
        final matches = plugin.findAllMatches(
            'The quick brown fox jumps over the lazy Fox');

        expect(matches, isEmpty);
      });

      test('Should find case-sensitive match', () {
        plugin.setSearchText('Fox');
        plugin.setCaseSensitive(true);
        final matches = plugin.findAllMatches(
            'The quick brown fox jumps over the lazy Fox');

        expect(matches, hasLength(1));
        expect(matches[0], equals(40)); // Only 'Fox' at the end
      });

      test('Should respect whole word matching', () {
        plugin.setSearchText('fox');
        plugin.setWholeWord(true);
        final matches = plugin.findAllMatches(
            'The fox and firefox are different');

        expect(matches, hasLength(1)); // Only standalone 'fox', not 'firefox'
        expect(matches[0], equals(4));
      });

      test('Should return empty list for empty search text', () {
        plugin.setSearchText('');
        final matches = plugin.findAllMatches('Some content here');

        expect(matches, isEmpty);
      });

      test('Should return empty list when no matches found', () {
        plugin.setSearchText('elephant');
        final matches = plugin.findAllMatches('The quick brown fox');

        expect(matches, isEmpty);
      });
    });

    group('Navigation functionality', () {
      test('Should navigate to next match', () {
        plugin.setSearchText('fox');
        plugin.findAllMatches('fox and fox and fox');

        expect(plugin.currentMatchIndex, equals(0));

        final next1 = plugin.nextMatch();
        expect(next1, equals(8)); // Second 'fox'
        expect(plugin.currentMatchIndex, equals(1));

        final next2 = plugin.nextMatch();
        expect(next2, equals(16)); // Third 'fox'
        expect(plugin.currentMatchIndex, equals(2));

        // Should wrap around
        final next3 = plugin.nextMatch();
        expect(next3, equals(0)); // Back to first 'fox'
        expect(plugin.currentMatchIndex, equals(0));
      });

      test('Should navigate to previous match', () {
        plugin.setSearchText('fox');
        plugin.findAllMatches('fox and fox and fox');

        // Navigate forward first
        plugin.nextMatch();
        plugin.nextMatch();
        expect(plugin.currentMatchIndex, equals(2));

        // Now go back
        final prev = plugin.previousMatch();
        expect(prev, equals(8));
        expect(plugin.currentMatchIndex, equals(1));
      });

      test('Should wrap around on previous from first match', () {
        plugin.setSearchText('fox');
        plugin.findAllMatches('fox and fox and fox');

        expect(plugin.currentMatchIndex, equals(0));

        final prev = plugin.previousMatch();
        expect(prev, equals(16)); // Should wrap to last 'fox'
        expect(plugin.currentMatchIndex, equals(2));
      });

      test('Should return -1 when no matches', () {
        plugin.setSearchText('elephant');
        plugin.findAllMatches('fox and dog');

        expect(plugin.nextMatch(), equals(-1));
        expect(plugin.previousMatch(), equals(-1));
      });
    });

    group('Replace functionality', () {
      test('Should replace current match', () {
        plugin.setSearchText('fox');
        plugin.setReplaceText('cat');
        plugin.findAllMatches('The fox jumps');

        final result = plugin.replaceCurrentMatch('The fox jumps');

        expect(result, equals('The cat jumps'));
      });

      test('Should replace all matches', () {
        plugin.setSearchText('fox');
        plugin.setReplaceText('cat');
        plugin.setCaseSensitive(true);

        final result =
            plugin.replaceAllMatches('The fox saw another fox');

        expect(result, equals('The cat saw another cat'));
      });

      test('Should not replace when no matches', () {
        plugin.setSearchText('elephant');
        plugin.setReplaceText('cat');
        plugin.findAllMatches('The fox jumps');

        final result = plugin.replaceCurrentMatch('The fox jumps');

        expect(result, equals('The fox jumps'));
      });

      test('Should handle empty replacement', () {
        plugin.setSearchText('fox');
        plugin.setReplaceText('');
        plugin.findAllMatches('The fox jumps');

        final result = plugin.replaceCurrentMatch('The fox jumps');

        expect(result, equals('The  jumps'));
      });

      test('Should handle replacement with longer text', () {
        plugin.setSearchText('fox');
        plugin.setReplaceText('elephant');
        plugin.findAllMatches('The fox jumps');

        final result = plugin.replaceCurrentMatch('The fox jumps');

        expect(result, equals('The elephant jumps'));
      });
    });

    group('State management', () {
      test('Should reset state correctly', () {
        plugin.setSearchText('fox');
        plugin.findAllMatches('fox and fox');
        plugin.nextMatch();

        expect(plugin.matchCount, equals(2));
        expect(plugin.currentMatchIndex, equals(1));

        plugin.reset();

        expect(plugin.matchCount, equals(0));
        expect(plugin.currentMatchIndex, equals(-1));
      });

      test('Should update match count after replacement', () {
        plugin.setSearchText('fox');
        plugin.setReplaceText('cat');

        final content = 'fox and fox and fox';
        plugin.findAllMatches(content);
        expect(plugin.matchCount, equals(3));

        final newContent = plugin.replaceCurrentMatch(content);
        // After replace, findAllMatches is called on new content
        expect(plugin.matchCount, equals(2));
        expect(newContent, equals('cat and fox and fox'));
      });
    });

    group('Plugin integration', () {
      late QuillPluginRegistry registry;

      setUp(() {
        registry = QuillPluginRegistry.instance;
        registry.clear();
      });

      tearDown(() {
        registry.clear();
      });

      test('Should register with QuillPluginRegistry', () {
        final plugin = _TestFindReplacePlugin();

        registry.register(plugin);

        expect(registry.hasPlugin('find-replace'), isTrue);
        expect(registry.pluginCount, equals(1));
      });

      test('Should provide toolbar item to registry', () {
        final plugin = _TestFindReplacePlugin();

        registry.register(plugin);

        expect(registry.allToolbarItems, hasLength(1));
        expect(registry.allToolbarItems.first.id, equals('find-replace'));
      });

      test('Should provide key bindings to registry', () {
        final plugin = _TestFindReplacePlugin();

        registry.register(plugin);

        expect(registry.allKeyBindings, hasLength(2));
      });

      test('Should call onFind callback when set', () {
        String? callbackResult;
        final plugin = _TestFindReplacePlugin(
          onFind: (result) => callbackResult = result,
        );

        plugin.setSearchText('fox');
        plugin.findAllMatches('The quick brown fox');
        plugin.onFind?.call('Found 1 match');

        expect(callbackResult, equals('Found 1 match'));
      });
    });
  });
}

/// Test plugin for testing purposes.
class _TestPlugin extends QuillPlugin {
  _TestPlugin({
    required String name,
    String version = '1.0.0',
    List<QuillToolbarItem>? toolbarItems,
    Map<String, QuillCommandHandler>? commandHandlers,
  })  : _name = name,
        _version = version,
        _toolbarItems = toolbarItems ?? const [],
        _commandHandlers = commandHandlers ?? const {};

  final String _name;
  final String _version;
  final List<QuillToolbarItem> _toolbarItems;
  final Map<String, QuillCommandHandler> _commandHandlers;

  @override
  String get name => _name;

  @override
  String get version => _version;

  @override
  List<QuillToolbarItem> get toolbarItems => _toolbarItems;

  @override
  Map<String, QuillCommandHandler> get commandHandlers => _commandHandlers;
}

/// Template plugin for testing (mirrors the example plugin)
class _TemplatePlugin extends QuillPlugin {
  _TemplatePlugin({
    required this.templates,
    this.onInsert,
  });

  final List<Map<String, String>> templates;
  final void Function(String templateId)? onInsert;

  @override
  String get name => 'template-test';

  @override
  List<QuillToolbarItem> get toolbarItems => [
        QuillToolbarItem(
          id: 'insert-template',
          tooltip: 'Insert Template',
          action: 'insertTemplate',
          dropdown: templates
              .map((t) => QuillDropdownOption(
                    value: t['id']!,
                    label: t['name']!,
                  ))
              .toList(),
        ),
      ];

  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
        'insertTemplate': (params, controller) async {
          final templateId =
              (params?['value'] ?? params?['templateId']) as String?;
          if (templateId == null) return;

          final template = templates.firstWhere(
            (t) => t['id'] == templateId,
            orElse: () => {},
          );

          if (template.isNotEmpty && controller != null) {
            controller.insertHtml(template['content']!);
            onInsert?.call(templateId);
          }
        },
      };
}

/// Mock controller for testing template insertion
class _MockController {
  _MockController({
    this.onInsertHtml,
  });

  final void Function(String html)? onInsertHtml;

  void insertHtml(String html) {
    onInsertHtml?.call(html);
  }
}

/// Mock controller for testing emoji insertion
/// This verifies that insertText is NOT called (would cause duplicates)
class _MockEmojiController {
  _MockEmojiController({
    this.onInsertText,
  });

  final void Function(String text)? onInsertText;

  void insertText(String text) {
    onInsertText?.call(text);
  }
}

// ============================================================
// Find and Replace Plugin Tests
// ============================================================

/// A testable Find and Replace plugin that mirrors the one in plugin_example_page.dart
class _TestFindReplacePlugin extends QuillPlugin with QuillPluginMixin {
  _TestFindReplacePlugin({this.onFind});

  final void Function(String result)? onFind;

  String _searchText = '';
  String _replaceText = '';
  bool _caseSensitive = false;
  bool _wholeWord = false;
  List<int> _matchPositions = [];
  int _currentMatchIndex = -1;

  String get searchText => _searchText;
  String get replaceText => _replaceText;
  bool get caseSensitive => _caseSensitive;
  bool get wholeWord => _wholeWord;
  int get matchCount => _matchPositions.length;
  int get currentMatchIndex => _currentMatchIndex;

  void setSearchText(String text) => _searchText = text;
  void setReplaceText(String text) => _replaceText = text;
  void setCaseSensitive(bool value) => _caseSensitive = value;
  void setWholeWord(bool value) => _wholeWord = value;

  @override
  String get name => 'find-replace';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Find and replace text in the editor';

  @override
  List<QuillToolbarItem> get toolbarItems => [
        QuillToolbarItem(
          id: 'find-replace',
          tooltip: 'Find and Replace (Ctrl+F)',
          icon: 'ql-find-replace',
          action: 'showFindReplace',
          group: ToolbarGroup.view,
          order: 50,
        ),
      ];

  @override
  List<QuillKeyBinding> get keyBindings => [
        const QuillKeyBinding(
          key: 'f',
          modifiers: [KeyModifier.ctrl],
          action: 'showFindReplace',
          description: 'Open Find and Replace',
        ),
        const QuillKeyBinding(
          key: 'h',
          modifiers: [KeyModifier.ctrl],
          action: 'showFindReplace',
          description: 'Open Find and Replace',
        ),
      ];

  /// Finds all occurrences of searchText in the given content.
  List<int> findAllMatches(String content) {
    if (_searchText.isEmpty) {
      _matchPositions = [];
      _currentMatchIndex = -1;
      return [];
    }

    String searchFor = _searchText;
    String searchIn = content;

    if (!_caseSensitive) {
      searchFor = searchFor.toLowerCase();
      searchIn = searchIn.toLowerCase();
    }

    final matches = <int>[];
    int start = 0;

    while (true) {
      final index = searchIn.indexOf(searchFor, start);
      if (index == -1) break;

      if (_wholeWord) {
        final beforeOk = index == 0 || !_isWordChar(searchIn[index - 1]);
        final afterOk = index + searchFor.length >= searchIn.length ||
            !_isWordChar(searchIn[index + searchFor.length]);
        if (beforeOk && afterOk) {
          matches.add(index);
        }
      } else {
        matches.add(index);
      }

      start = index + 1;
    }

    _matchPositions = matches;
    if (matches.isNotEmpty && _currentMatchIndex == -1) {
      _currentMatchIndex = 0;
    } else if (matches.isEmpty) {
      _currentMatchIndex = -1;
    }

    return matches;
  }

  bool _isWordChar(String char) {
    return RegExp(r'\w').hasMatch(char);
  }

  int nextMatch() {
    if (_matchPositions.isEmpty) return -1;
    _currentMatchIndex = (_currentMatchIndex + 1) % _matchPositions.length;
    return _matchPositions[_currentMatchIndex];
  }

  int previousMatch() {
    if (_matchPositions.isEmpty) return -1;
    _currentMatchIndex =
        (_currentMatchIndex - 1 + _matchPositions.length) % _matchPositions.length;
    return _matchPositions[_currentMatchIndex];
  }

  String replaceCurrentMatch(String content) {
    if (_matchPositions.isEmpty || _currentMatchIndex < 0) return content;

    final pos = _matchPositions[_currentMatchIndex];
    final newContent = content.substring(0, pos) +
        _replaceText +
        content.substring(pos + _searchText.length);

    findAllMatches(newContent);
    return newContent;
  }

  String replaceAllMatches(String content) {
    if (_searchText.isEmpty) return content;

    if (_caseSensitive && !_wholeWord) {
      return content.replaceAll(_searchText, _replaceText);
    }

    String result = content;
    final matches = findAllMatches(content);
    for (int i = matches.length - 1; i >= 0; i--) {
      final pos = matches[i];
      result = result.substring(0, pos) +
          _replaceText +
          result.substring(pos + _searchText.length);
    }

    _matchPositions = [];
    _currentMatchIndex = -1;

    return result;
  }

  void reset() {
    _matchPositions = [];
    _currentMatchIndex = -1;
  }
}

