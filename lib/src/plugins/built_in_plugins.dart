import 'quill_plugin.dart';

/// A plugin that adds emoji support to the editor.
///
/// Provides three ways to insert emojis:
/// 1. **Toolbar button** - Opens emoji picker popup
/// 2. **Native shortcut** - macOS: Cmd+Ctrl+Space, Windows: Win+.
/// 3. **Colon shortcut** - Type :emoji_name: for autocomplete
///
/// ## Usage
/// ```dart
/// QuillPluginRegistry.instance.register(EmojiPlugin());
/// ```
///
/// ## With callbacks
/// ```dart
/// QuillPluginRegistry.instance.register(EmojiPlugin(
///   onEmojiSelected: (emoji) => print('Selected: $emoji'),
///   recentEmojis: ['😀', '👍', '❤️'],
/// ));
/// ```
class EmojiPlugin extends QuillPlugin with QuillPluginMixin {
  EmojiPlugin({
    this.onEmojiSelected,
    this.recentEmojis,
    this.skinTone = EmojiSkinTone.neutral,
  });

  /// Callback when an emoji is selected.
  final void Function(String emoji)? onEmojiSelected;

  /// List of recently used emojis to show first.
  final List<String>? recentEmojis;

  /// Default skin tone for applicable emojis.
  final EmojiSkinTone skinTone;

  @override
  String get name => 'emoji';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Adds emoji picker to the editor toolbar';

  @override
  List<QuillToolbarItem> get toolbarItems => [
        const QuillToolbarItem(
          id: 'emoji-picker',
          tooltip: 'Insert emoji (or use Cmd+Ctrl+Space on macOS)',
          icon: 'ql-emoji',
          action: 'showEmojiPicker',
          group: ToolbarGroup.insert,
          order: 50,
        ),
      ];

  @override
  List<QuillFormat> get formats => [
        const QuillFormat(
          name: 'emoji',
          type: FormatType.inline,
          className: 'ql-emoji',
          tagName: 'span',
        ),
      ];

  @override
  List<QuillStylesheet> get stylesheets => [
        const QuillStylesheet(
          id: 'emoji-picker-styles',
          css: '''
            /* Emoji picker popup */
            .ql-emoji-picker {
              position: absolute;
              z-index: 1000;
              background: #fff;
              border: 1px solid #e0e0e0;
              border-radius: 12px;
              box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
              padding: 12px;
              max-width: 320px;
              max-height: 400px;
              overflow: hidden;
              display: flex;
              flex-direction: column;
            }
            
            .ql-emoji-picker-header {
              display: flex;
              gap: 4px;
              padding-bottom: 8px;
              border-bottom: 1px solid #e0e0e0;
              margin-bottom: 8px;
              overflow-x: auto;
            }
            
            .ql-emoji-category-btn {
              padding: 6px 8px;
              border: none;
              background: none;
              border-radius: 6px;
              cursor: pointer;
              font-size: 18px;
              opacity: 0.6;
              transition: all 0.15s;
            }
            
            .ql-emoji-category-btn:hover,
            .ql-emoji-category-btn.active {
              background: #f0f0f0;
              opacity: 1;
            }
            
            .ql-emoji-grid {
              display: grid;
              grid-template-columns: repeat(8, 1fr);
              gap: 2px;
              overflow-y: auto;
              max-height: 280px;
              padding: 4px;
            }
            
            .ql-emoji-item {
              padding: 6px;
              border: none;
              background: none;
              border-radius: 6px;
              cursor: pointer;
              font-size: 22px;
              line-height: 1;
              transition: all 0.1s;
              text-align: center;
            }
            
            .ql-emoji-item:hover {
              background: #f0f0f0;
              transform: scale(1.2);
            }
            
            .ql-emoji-search {
              width: 100%;
              padding: 8px 12px;
              border: 1px solid #e0e0e0;
              border-radius: 8px;
              font-size: 14px;
              margin-bottom: 8px;
              outline: none;
            }
            
            .ql-emoji-search:focus {
              border-color: #c45d35;
            }
            
            /* Native emoji hint */
            .ql-emoji-native-hint {
              font-size: 11px;
              color: #888;
              text-align: center;
              padding-top: 8px;
              border-top: 1px solid #e0e0e0;
              margin-top: 8px;
            }
          ''',
        ),
      ];

  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
        'showEmojiPicker': (params, controller) async {
          // The actual emoji picker is shown via JavaScript
          // This handler is called when the picker button is clicked
          // No action needed here - JS handles showing the picker
        },
        'insertEmoji': (params, controller) async {
          // NOTE: The emoji is already inserted by JavaScript directly into Quill
          // This handler is only for Flutter-side callbacks (e.g., analytics, logging)
          // DO NOT insert again here - that would cause duplicates!
          final emoji = params?['emoji'] as String?;
          if (emoji != null) {
            onEmojiSelected?.call(emoji);
          }
        },
      };

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'emoji',
          options: {
            'recentEmojis': recentEmojis ?? [],
            'skinTone': skinTone.index,
          },
        ),
      ];
}

/// Emoji skin tone options.
enum EmojiSkinTone {
  neutral,
  light,
  mediumLight,
  medium,
  mediumDark,
  dark,
}

/// A plugin that adds mention support (@username).
///
/// ```dart
/// QuillPluginRegistry.instance.register(MentionPlugin(
///   onMentionTriggered: (query) async {
///     // Search users and return results
///     return searchUsers(query);
///   },
/// ));
/// ```
class MentionPlugin extends QuillPlugin with QuillPluginMixin {
  MentionPlugin({
    this.triggerChar = '@',
    this.onMentionTriggered,
  });

  /// Character that triggers mention suggestions.
  final String triggerChar;

  /// Callback when mention is triggered, should return matching users.
  final Future<List<Map<String, dynamic>>> Function(String query)?
      onMentionTriggered;

  @override
  String get name => 'mention';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Adds @mention support to the editor';

  @override
  List<QuillFormat> get formats => [
        const QuillFormat(
          name: 'mention',
          type: FormatType.inline,
          className: 'ql-mention',
          tagName: 'span',
          cssStyles: {
            'background-color': '#e8f4fc',
            'border-radius': '3px',
            'padding': '0 4px',
          },
        ),
      ];

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'mention',
          options: {
            'triggerChar': triggerChar,
          },
        ),
      ];

  @override
  List<QuillKeyBinding> get keyBindings => [
        QuillKeyBinding(
          key: triggerChar,
          action: 'triggerMention',
          description: 'Trigger mention autocomplete',
          modifiers: [],
          preventDefault: false,
        ),
      ];

  @override
  List<QuillStylesheet> get stylesheets => [
        const QuillStylesheet(
          id: 'mention-styles',
          css: '''
            .ql-mention {
              background-color: #e8f4fc;
              border-radius: 3px;
              padding: 0 4px;
              color: #1a73e8;
              cursor: pointer;
            }
            .ql-mention:hover {
              background-color: #d2e7f9;
            }
          ''',
        ),
      ];

  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
        'triggerMention': (params, controller) async {
          final query = params?['query'] as String? ?? '';
          if (onMentionTriggered != null) {
            final results = await onMentionTriggered!(query);
            // Send results back to editor
            if (controller != null) {
              controller.executeCustom(
                action: 'showMentionSuggestions',
                parameters: {'suggestions': results},
              );
            }
          }
        },
      };
}

/// A plugin that adds hashtag support (#topic).
class HashtagPlugin extends QuillPlugin with QuillPluginMixin {
  HashtagPlugin({
    this.onHashtagClicked,
  });

  /// Callback when a hashtag is clicked.
  final void Function(String hashtag)? onHashtagClicked;

  @override
  String get name => 'hashtag';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Adds #hashtag support to the editor';

  @override
  List<QuillFormat> get formats => [
        const QuillFormat(
          name: 'hashtag',
          type: FormatType.inline,
          className: 'ql-hashtag',
          tagName: 'span',
          cssStyles: {
            'color': '#1a73e8',
            'cursor': 'pointer',
          },
        ),
      ];

  @override
  List<QuillStylesheet> get stylesheets => [
        const QuillStylesheet(
          id: 'hashtag-styles',
          css: '''
            .ql-hashtag {
              color: #1a73e8;
              cursor: pointer;
            }
            .ql-hashtag:hover {
              text-decoration: underline;
            }
          ''',
        ),
      ];
}

/// A plugin that adds code syntax highlighting.
class CodeHighlightPlugin extends QuillPlugin with QuillPluginMixin {
  CodeHighlightPlugin({
    this.theme = 'github',
    this.languages = const ['javascript', 'python', 'dart', 'java', 'cpp'],
  });

  /// Highlight.js theme to use.
  final String theme;

  /// List of supported languages.
  final List<String> languages;

  @override
  String get name => 'code-highlight';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Adds syntax highlighting to code blocks';

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'syntax',
          options: {
            'theme': theme,
            'languages': languages,
          },
        ),
      ];

  @override
  List<QuillToolbarItem> get toolbarItems => [
        QuillToolbarItem(
          id: 'code-language',
          tooltip: 'Code language',
          icon: 'ql-code-language',
          group: ToolbarGroup.format,
          order: 90,
          dropdown: languages
              .map(
                (lang) => QuillDropdownOption(
                  value: lang,
                  label: lang.toUpperCase(),
                ),
              )
              .toList(),
        ),
      ];
}

/// A plugin that adds auto-link detection.
class AutoLinkPlugin extends QuillPlugin with QuillPluginMixin {
  AutoLinkPlugin({
    this.urlPattern,
    this.emailPattern,
  });

  /// Custom URL pattern (regex).
  final String? urlPattern;

  /// Custom email pattern (regex).
  final String? emailPattern;

  @override
  String get name => 'auto-link';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Automatically converts URLs to links';

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'autoLink',
          options: {
            if (urlPattern != null) 'urlPattern': urlPattern,
            if (emailPattern != null) 'emailPattern': emailPattern,
          },
        ),
      ];
}

/// A plugin that adds word count display.
class WordCountPlugin extends QuillPlugin with QuillPluginMixin {
  WordCountPlugin({
    this.showCharacterCount = true,
    this.showWordCount = true,
    this.maxWords,
    this.maxCharacters,
  });

  final bool showCharacterCount;
  final bool showWordCount;
  final int? maxWords;
  final int? maxCharacters;

  @override
  String get name => 'word-count';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Shows word and character count';

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'wordCount',
          options: {
            'showCharacterCount': showCharacterCount,
            'showWordCount': showWordCount,
            if (maxWords != null) 'maxWords': maxWords,
            if (maxCharacters != null) 'maxCharacters': maxCharacters,
          },
        ),
      ];
}

/// A composite plugin that bundles multiple plugins together.
///
/// Use this to create plugin packs:
/// ```dart
/// final socialPack = PluginBundle(
///   name: 'social-pack',
///   plugins: [
///     MentionPlugin(),
///     HashtagPlugin(),
///     EmojiPlugin(),
///   ],
/// );
///
/// QuillPluginRegistry.instance.register(socialPack);
/// ```
class PluginBundle extends QuillPlugin {
  PluginBundle({
    required this.bundleName,
    required this.bundledPlugins,
    this.bundleVersion = '1.0.0',
    this.bundleDescription = '',
  });

  final String bundleName;
  final String bundleVersion;
  final String bundleDescription;
  final List<QuillPlugin> bundledPlugins;

  @override
  String get name => bundleName;

  @override
  String get version => bundleVersion;

  @override
  String get description => bundleDescription;

  @override
  List<String> get dependencies =>
      bundledPlugins.expand((p) => p.dependencies).toList();

  @override
  List<QuillToolbarItem> get toolbarItems =>
      bundledPlugins.expand((p) => p.toolbarItems).toList();

  @override
  List<QuillFormat> get formats =>
      bundledPlugins.expand((p) => p.formats).toList();

  @override
  List<QuillModule> get modules =>
      bundledPlugins.expand((p) => p.modules).toList();

  @override
  List<QuillKeyBinding> get keyBindings =>
      bundledPlugins.expand((p) => p.keyBindings).toList();

  @override
  List<QuillStylesheet> get stylesheets =>
      bundledPlugins.expand((p) => p.stylesheets).toList();

  @override
  Map<String, QuillCommandHandler> get commandHandlers {
    final handlers = <String, QuillCommandHandler>{};
    for (final plugin in bundledPlugins) {
      handlers.addAll(plugin.commandHandlers);
    }
    return handlers;
  }

  @override
  void onRegister() {
    for (final plugin in bundledPlugins) {
      plugin.onRegister();
    }
  }

  @override
  void onEditorReady(dynamic controller) {
    for (final plugin in bundledPlugins) {
      plugin.onEditorReady(controller);
    }
  }

  @override
  void onUnregister() {
    for (final plugin in bundledPlugins) {
      plugin.onUnregister();
    }
  }
}
