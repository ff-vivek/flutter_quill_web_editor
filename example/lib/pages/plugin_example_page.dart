import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

// Import the extended GIF plugin from local plugins folder
import '../plugins/gif_plugin.dart';

/// Example page demonstrating the plugin system.
///
/// This page shows how to:
/// - Register built-in plugins
/// - Create custom plugins
/// - Use plugin toolbar items
/// - Handle plugin commands
class PluginExamplePage extends StatefulWidget {
  const PluginExamplePage({super.key});

  @override
  State<PluginExamplePage> createState() => _PluginExamplePageState();
}

class _PluginExamplePageState extends State<PluginExamplePage> {
  final _controller = QuillEditorController();
  bool _editorReady = false;
  String _lastAction = '';
  late final _FindReplacePlugin _findReplacePlugin;

  @override
  void initState() {
    super.initState();
    _findReplacePlugin = _FindReplacePlugin(
      onFind: (result) {
        setState(() => _lastAction = result);
      },
    );
    _registerPlugins();
  }

  void _showFindReplaceDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _FindReplaceDialog(
        controller: _controller,
        plugin: _findReplacePlugin,
      ),
    );
  }

  void _registerPlugins() {
    // Register built-in plugins
    _controller.registerPlugins([
      // Find and Replace plugin
      _findReplacePlugin,

      // Emoji plugin
      EmojiPlugin(),

      // Mention plugin with custom handler
      MentionPlugin(
        triggerChar: '@',
        onMentionTriggered: (query) async {
          // Simulate searching users
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return [
            {'id': '1', 'name': 'John Doe', 'avatar': 'JD'},
            {'id': '2', 'name': 'Jane Smith', 'avatar': 'JS'},
            {'id': '3', 'name': 'Bob Wilson', 'avatar': 'BW'},
          ]
              .where((user) =>
                  user['name']!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
      ),

      // Hashtag plugin
      HashtagPlugin(
        onHashtagClicked: (tag) {
          setState(() => _lastAction = 'Clicked hashtag: $tag');
        },
      ),

      // GIF plugin for inserting animated GIFs from URL
      GifPlugin(
        onGifInserted: (url) {
          setState(() => _lastAction = 'Inserted GIF: $url');
        },
        defaultWidth: 300,
        showPreview: true,
      ),

      // Custom template plugin
      _TemplateInsertPlugin(
        templates: [
          {
            'id': 'greeting',
            'name': 'Greeting',
            'content': '<p>Hello, welcome to our service!</p>'
          },
          {
            'id': 'signature',
            'name': 'Signature',
            'content': '<p><br/><em>Best regards,<br/>The Team</em></p>'
          },
          {
            'id': 'disclaimer',
            'name': 'Disclaimer',
            'content': '<p><small>This is confidential information.</small></p>'
          },
        ],
        onInsert: (templateId) {
          setState(() => _lastAction = 'Inserted template: $templateId');
        },
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin System Example'),
        actions: [
          // Show registered plugins count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Chip(
                label: Text(
                  'Plugins: ${_controller.pluginRegistry.pluginCount}',
                ),
                backgroundColor: Colors.green.shade100,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Plugin info bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registered Plugins',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _controller.pluginRegistry.plugins
                      .map(
                        (p) => Chip(
                          label: Text('${p.name} v${p.version}'),
                          avatar: const Icon(Icons.extension, size: 16),
                        ),
                      )
                      .toList(),
                ),
                if (_lastAction.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Last action: $_lastAction')),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Plugin toolbar items
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text('Plugin Actions: '),
                const SizedBox(width: 8),
                ..._controller.pluginToolbarItems.map(
                  (item) => Tooltip(
                    message: item.tooltip,
                    child: IconButton(
                      icon: (item.iconWidget is Widget)
                          ? item.iconWidget as Widget
                          : const Icon(Icons.extension),
                      onPressed: item.enabled
                          ? () {
                              setState(
                                  () => _lastAction = 'Clicked: ${item.id}');
                              // Handle find-replace specially to show dialog
                              if (item.id == 'find-replace') {
                                _showFindReplaceDialog();
                              } else if (item.action != null) {
                                _controller.executePluginAction(item.id);
                              }
                            }
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Editor
          Expanded(
            child: QuillEditorWidget(
              controller: _controller,
              onReady: () {
                setState(() => _editorReady = true);
              },
              onContentChanged: (html, delta) {
                // Content changed
              },
              initialHtml: '''
                <h2>Plugin System Demo</h2>
                <p>This editor has plugins registered:</p>
                <ul>
                  <li><strong>FindReplacePlugin</strong> - Find and replace text (Ctrl+F)</li>
                  <li><strong>EmojiPlugin</strong> - Adds emoji support</li>
                  <li><strong>MentionPlugin</strong> - Type @ to mention users</li>
                  <li><strong>HashtagPlugin</strong> - Adds #hashtag support</li>
                  <li><strong>TemplatePlugin</strong> - Custom templates</li>
                </ul>
                <p>Try the plugin toolbar buttons above! Use Ctrl+F or click the search icon to find and replace text.</p>
                <p>Here's some sample text to test find and replace:</p>
                <p>The quick brown fox jumps over the lazy dog. The fox is quick and clever. The dog is lazy but friendly.</p>
              ''',
            ),
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _editorReady ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: _editorReady ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(_editorReady ? 'Editor ready' : 'Loading...'),
                  ],
                ),
                Text(
                  '${_controller.pluginRegistry.allToolbarItems.length} toolbar items | '
                  '${_controller.pluginRegistry.allFormats.length} formats | '
                  '${_controller.pluginRegistry.allCommandHandlers.length} handlers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom plugin example - Template Insert Plugin.
///
/// This demonstrates how to create a custom plugin with:
/// - Toolbar items
/// - Command handlers
/// - Custom callbacks
class _TemplateInsertPlugin extends QuillPlugin with QuillPluginMixin {
  _TemplateInsertPlugin({
    required this.templates,
    this.onInsert,
  });

  final List<Map<String, String>> templates;
  final void Function(String templateId)? onInsert;

  @override
  String get name => 'template-insert';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Insert predefined templates into the editor';

  @override
  List<QuillToolbarItem> get toolbarItems => [
        QuillToolbarItem(
          id: 'insert-template',
          tooltip: 'Insert Template',
          icon: 'ql-template',
          action: 'insertTemplate', // Links to command handler
          group: ToolbarGroup.insert,
          order: 100,
          dropdown: templates
              .map(
                (t) => QuillDropdownOption(
                  value: t['id']!,
                  label: t['name']!,
                ),
              )
              .toList(),
        ),
      ];

  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
        'insertTemplate': (params, controller) async {
          // Support both 'value' (from dropdown) and 'templateId' (direct call)
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

/// Find and Replace Plugin.
///
/// Provides find and replace functionality with:
/// - Case-sensitive search
/// - Whole word matching
/// - Replace single or all occurrences
/// - Keyboard shortcuts (Ctrl+F, Ctrl+H)
class _FindReplacePlugin extends QuillPlugin with QuillPluginMixin {
  _FindReplacePlugin({
    this.onFind,
    this.onShowDialog,
  });

  /// Callback when a find/replace action occurs.
  final void Function(String result)? onFind;

  /// Callback to show the find/replace dialog.
  /// This is set by the parent widget to trigger dialog display.
  VoidCallback? onShowDialog;

  /// Current search state.
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
          iconWidget: const Icon(Icons.find_replace, size: 20),
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

      // Check whole word if enabled
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

  /// Move to next match.
  int nextMatch() {
    if (_matchPositions.isEmpty) return -1;
    _currentMatchIndex = (_currentMatchIndex + 1) % _matchPositions.length;
    return _matchPositions[_currentMatchIndex];
  }

  /// Move to previous match.
  int previousMatch() {
    if (_matchPositions.isEmpty) return -1;
    _currentMatchIndex = (_currentMatchIndex - 1 + _matchPositions.length) %
        _matchPositions.length;
    return _matchPositions[_currentMatchIndex];
  }

  /// Replace current match.
  String replaceCurrentMatch(String content) {
    if (_matchPositions.isEmpty || _currentMatchIndex < 0) return content;

    final pos = _matchPositions[_currentMatchIndex];
    final newContent = content.substring(0, pos) +
        _replaceText +
        content.substring(pos + _searchText.length);

    // Recalculate matches
    findAllMatches(newContent);

    return newContent;
  }

  /// Replace all matches.
  String replaceAllMatches(String content) {
    if (_searchText.isEmpty) return content;

    if (_caseSensitive && !_wholeWord) {
      return content.replaceAll(_searchText, _replaceText);
    }

    String result = content;
    // Replace from end to start to preserve positions
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

/// Find and Replace Dialog Widget.
class _FindReplaceDialog extends StatefulWidget {
  const _FindReplaceDialog({
    required this.controller,
    required this.plugin,
  });

  final QuillEditorController controller;
  final _FindReplacePlugin plugin;

  @override
  State<_FindReplaceDialog> createState() => _FindReplaceDialogState();
}

class _FindReplaceDialogState extends State<_FindReplaceDialog> {
  late final TextEditingController _findController;
  late final TextEditingController _replaceController;
  final FocusNode _findFocusNode = FocusNode();

  int _matchCount = 0;
  int _currentMatch = 0;
  String _statusMessage = '';
  bool _caseSensitive = false;
  bool _wholeWord = false;

  @override
  void initState() {
    super.initState();
    _findController = TextEditingController(text: widget.plugin.searchText);
    _replaceController = TextEditingController(text: widget.plugin.replaceText);
    _caseSensitive = widget.plugin.caseSensitive;
    _wholeWord = widget.plugin.wholeWord;

    // Auto-focus find field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  void _performFind() {
    final searchText = _findController.text;
    if (searchText.isEmpty) {
      setState(() {
        _matchCount = 0;
        _currentMatch = 0;
        _statusMessage = '';
      });
      return;
    }

    widget.plugin.setSearchText(searchText);
    widget.plugin.setCaseSensitive(_caseSensitive);
    widget.plugin.setWholeWord(_wholeWord);

    // Get current content from editor (strip HTML tags for matching)
    final html = widget.controller.html;
    final plainText = _stripHtmlTags(html);
    final matches = widget.plugin.findAllMatches(plainText);

    setState(() {
      _matchCount = matches.length;
      _currentMatch = matches.isNotEmpty ? 1 : 0;
      _statusMessage = matches.isEmpty
          ? 'No matches found'
          : 'Found ${matches.length} match${matches.length == 1 ? '' : 'es'}';
    });

    widget.plugin.onFind?.call(_statusMessage);
  }

  /// Strips HTML tags to get plain text for matching.
  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _findNext() {
    if (_matchCount == 0) {
      _performFind();
      return;
    }

    widget.plugin.nextMatch();
    setState(() {
      _currentMatch = widget.plugin.currentMatchIndex + 1;
    });

    // Highlight/scroll to match in editor
    // Note: In a real implementation, we'd send a command to JS to highlight
    widget.plugin.onFind?.call('Match $_currentMatch of $_matchCount');
  }

  void _findPrevious() {
    if (_matchCount == 0) return;

    widget.plugin.previousMatch();
    setState(() {
      _currentMatch = widget.plugin.currentMatchIndex + 1;
    });

    widget.plugin.onFind?.call('Match $_currentMatch of $_matchCount');
  }

  void _replaceCurrent() {
    if (_matchCount == 0) return;

    widget.plugin.setReplaceText(_replaceController.text);

    // For HTML content, we perform replacement directly
    final html = widget.controller.html;
    final newHtml = _replaceInHtml(
      html,
      widget.plugin.searchText,
      widget.plugin.replaceText,
      once: true,
    );
    widget.controller.setHTML(newHtml);

    // Update match count
    _performFind();

    widget.plugin.onFind?.call('Replaced 1 occurrence');
  }

  void _replaceAll() {
    final searchText = _findController.text;
    if (searchText.isEmpty) return;

    widget.plugin.setSearchText(searchText);
    widget.plugin.setReplaceText(_replaceController.text);
    widget.plugin.setCaseSensitive(_caseSensitive);
    widget.plugin.setWholeWord(_wholeWord);

    final html = widget.controller.html;
    final count = _countMatches(html, searchText);

    if (count == 0) {
      setState(() => _statusMessage = 'No matches found');
      return;
    }

    final newHtml = _replaceInHtml(
      html,
      searchText,
      _replaceController.text,
      once: false,
    );
    widget.controller.setHTML(newHtml);

    setState(() {
      _matchCount = 0;
      _currentMatch = 0;
      _statusMessage = 'Replaced $count occurrence${count == 1 ? '' : 's'}';
    });

    widget.plugin.reset();
    widget.plugin.onFind?.call(_statusMessage);
  }

  int _countMatches(String html, String searchText) {
    if (!_caseSensitive) {
      return RegExp(RegExp.escape(searchText), caseSensitive: false)
          .allMatches(html)
          .length;
    }
    return searchText.allMatches(html).length;
  }

  String _replaceInHtml(
    String html,
    String search,
    String replace, {
    required bool once,
  }) {
    // Simple text replacement - preserves HTML structure
    // For whole word matching, use regex
    if (_wholeWord) {
      final pattern = RegExp(
        r'\b' + RegExp.escape(search) + r'\b',
        caseSensitive: _caseSensitive,
      );
      if (once) {
        return html.replaceFirst(pattern, replace);
      }
      return html.replaceAll(pattern, replace);
    }

    if (!_caseSensitive) {
      final pattern = RegExp(RegExp.escape(search), caseSensitive: false);
      if (once) {
        return html.replaceFirst(pattern, replace);
      }
      return html.replaceAll(pattern, replace);
    }

    if (once) {
      return html.replaceFirst(search, replace);
    }
    return html.replaceAll(search, replace);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _findNext();
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
          }
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.find_replace),
            const SizedBox(width: 12),
            const Text('Find and Replace'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Find field
              TextField(
                controller: _findController,
                focusNode: _findFocusNode,
                decoration: InputDecoration(
                  labelText: 'Find',
                  hintText: 'Enter text to find...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward, size: 20),
                        onPressed: _findPrevious,
                        tooltip: 'Previous match',
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward, size: 20),
                        onPressed: _findNext,
                        tooltip: 'Next match',
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => _performFind(),
                onSubmitted: (_) => _findNext(),
              ),
              const SizedBox(height: 16),

              // Replace field
              TextField(
                controller: _replaceController,
                decoration: const InputDecoration(
                  labelText: 'Replace with',
                  hintText: 'Enter replacement text...',
                  prefixIcon: Icon(Icons.find_replace),
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) => widget.plugin.setReplaceText(text),
              ),
              const SizedBox(height: 16),

              // Options
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: _caseSensitive,
                      onChanged: (value) {
                        setState(() => _caseSensitive = value ?? false);
                        _performFind();
                      },
                      title: const Text(
                        'Case sensitive',
                        style: TextStyle(fontSize: 14),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _wholeWord,
                      onChanged: (value) {
                        setState(() => _wholeWord = value ?? false);
                        _performFind();
                      },
                      title: const Text(
                        'Whole word',
                        style: TextStyle(fontSize: 14),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _matchCount > 0
                      ? Colors.green.shade50
                      : (_statusMessage.isNotEmpty
                          ? Colors.orange.shade50
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _matchCount > 0
                          ? Icons.check_circle
                          : (_statusMessage.isNotEmpty
                              ? Icons.info
                              : Icons.search),
                      size: 20,
                      color: _matchCount > 0
                          ? Colors.green
                          : (_statusMessage.isNotEmpty
                              ? Colors.orange
                              : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _matchCount > 0
                            ? 'Match $_currentMatch of $_matchCount'
                            : (_statusMessage.isNotEmpty
                                ? _statusMessage
                                : 'Enter text to search'),
                        style: TextStyle(
                          color: _matchCount > 0
                              ? Colors.green.shade800
                              : (_statusMessage.isNotEmpty
                                  ? Colors.orange.shade800
                                  : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Replace button
          OutlinedButton.icon(
            onPressed: _matchCount > 0 ? _replaceCurrent : null,
            icon: const Icon(Icons.find_replace, size: 18),
            label: const Text('Replace'),
          ),
          // Replace All button
          OutlinedButton.icon(
            onPressed: _findController.text.isNotEmpty ? _replaceAll : null,
            icon: const Icon(Icons.playlist_add_check, size: 18),
            label: const Text('Replace All'),
          ),
          const SizedBox(width: 8),
          // Find button
          FilledButton.icon(
            onPressed: _findNext,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Find Next'),
          ),
        ],
      ),
    );
  }
}
