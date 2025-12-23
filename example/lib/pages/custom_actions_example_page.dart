import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

/// Example page demonstrating user-defined custom actions with
/// [QuillEditorController].
class CustomActionsExamplePage extends StatefulWidget {
  const CustomActionsExamplePage({super.key});

  @override
  State<CustomActionsExamplePage> createState() =>
      _CustomActionsExamplePageState();
}

class _CustomActionsExamplePageState extends State<CustomActionsExamplePage> {
  final QuillEditorController _editorController = QuillEditorController();

  int _wordCount = 0;
  int _charCount = 0;
  SaveStatus _saveStatus = SaveStatus.saved;
  Timer? _saveTimer;
  String _lastActionResult = '';
  int _executionCount = 0;

  // Selected action from dropdown
  String? _selectedAction;

  // Custom action definitions
  static const Map<String, _ActionDefinition> _actionDefinitions = {
    'insertTimestamp': _ActionDefinition(
      label: 'Insert Timestamp',
      description: 'Inserts the current date and time',
      icon: Icons.schedule,
    ),
    'insertDivider': _ActionDefinition(
      label: 'Insert Divider',
      description: 'Inserts a horizontal rule',
      icon: Icons.horizontal_rule,
    ),
    'insertWarningBox': _ActionDefinition(
      label: 'Insert Warning Box',
      description: 'Inserts a styled warning callout',
      icon: Icons.warning_amber,
    ),
    'insertInfoBox': _ActionDefinition(
      label: 'Insert Info Box',
      description: 'Inserts a styled info callout',
      icon: Icons.info_outline,
    ),
    'insertSuccessBox': _ActionDefinition(
      label: 'Insert Success Box',
      description: 'Inserts a styled success callout',
      icon: Icons.check_circle_outline,
    ),
    'insertCodeBlock': _ActionDefinition(
      label: 'Insert Code Block',
      description: 'Inserts a code block placeholder',
      icon: Icons.code,
    ),
    'insertSignature': _ActionDefinition(
      label: 'Insert Signature',
      description: 'Inserts a signature block',
      icon: Icons.draw,
    ),
  };

  @override
  void initState() {
    super.initState();
    _editorController.addListener(_onControllerChanged);
    _registerAllActions();
  }

  void _registerAllActions() {
    // Insert Timestamp
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertTimestamp',
        onExecute: () => debugPrint('Executing: insertTimestamp'),
        onResponse: (response) => _handleActionResponse('Timestamp', response),
      ),
    );

    // Insert Divider
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertDivider',
        parameters: {'style': 'solid'},
        onExecute: () => debugPrint('Executing: insertDivider'),
        onResponse: (response) => _handleActionResponse('Divider', response),
      ),
    );

    // Insert Warning Box
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertWarningBox',
        parameters: {'type': 'warning', 'icon': '⚠️'},
        onExecute: () => debugPrint('Executing: insertWarningBox'),
        onResponse: (response) =>
            _handleActionResponse('Warning Box', response),
      ),
    );

    // Insert Info Box
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertInfoBox',
        parameters: {'type': 'info', 'icon': 'ℹ️'},
        onExecute: () => debugPrint('Executing: insertInfoBox'),
        onResponse: (response) => _handleActionResponse('Info Box', response),
      ),
    );

    // Insert Success Box
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertSuccessBox',
        parameters: {'type': 'success', 'icon': '✅'},
        onExecute: () => debugPrint('Executing: insertSuccessBox'),
        onResponse: (response) =>
            _handleActionResponse('Success Box', response),
      ),
    );

    // Insert Code Block
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertCodeBlock',
        parameters: {'language': 'dart'},
        onExecute: () => debugPrint('Executing: insertCodeBlock'),
        onResponse: (response) => _handleActionResponse('Code Block', response),
      ),
    );

    // Insert Signature
    _editorController.registerAction(
      QuillEditorAction(
        name: 'insertSignature',
        parameters: {'name': 'User', 'title': 'Developer'},
        onExecute: () => debugPrint('Executing: insertSignature'),
        onResponse: (response) => _handleActionResponse('Signature', response),
      ),
    );
  }

  void _handleActionResponse(
      String actionLabel, Map<String, dynamic>? response) {
    setState(() {
      _executionCount++;
      _lastActionResult =
          '$actionLabel executed successfully (#$_executionCount)';
    });
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onContentChanged(String html, dynamic delta) {
    setState(() => _saveStatus = SaveStatus.unsaved);

    final stats = TextStats.fromHtml(html);
    setState(() {
      _wordCount = stats.wordCount;
      _charCount = stats.charCount;
    });

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _saveStatus = SaveStatus.saving);
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _saveStatus = SaveStatus.saved);
        });
      }
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _editorController.removeListener(_onControllerChanged);
    _editorController.dispose();
    super.dispose();
  }

  void _executeSelectedAction() {
    if (_selectedAction == null) {
      _showSnackBar('Please select an action first');
      return;
    }

    // Execute the registered action
    final success = _editorController.executeAction(_selectedAction!);

    if (success) {
      // Also perform the actual content insertion
      _performActionContent(_selectedAction!);
      _showSnackBar(
          'Action executed: ${_actionDefinitions[_selectedAction]?.label}');
    }
  }

  void _performActionContent(String actionName) {
    switch (actionName) {
      case 'insertTimestamp':
        final now = DateTime.now();
        final formatted = '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
            '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}';
        _editorController.insertText('\n📅 $formatted\n');
        break;

      case 'insertDivider':
        // Quill doesn't handle <hr> well, so we use a styled text divider
        _editorController.insertText('\n──────────────────────────────────\n');
        break;

      case 'insertWarningBox':
        // Use blockquote which Quill supports natively
        _editorController.insertHtml(
          '<blockquote><strong>⚠️ Warning:</strong> Enter your warning message here.</blockquote>',
        );
        break;

      case 'insertInfoBox':
        _editorController.insertHtml(
          '<blockquote><strong>ℹ️ Info:</strong> Enter your information here.</blockquote>',
        );
        break;

      case 'insertSuccessBox':
        _editorController.insertHtml(
          '<blockquote><strong>✅ Success:</strong> Enter your success message here.</blockquote>',
        );
        break;

      case 'insertCodeBlock':
        // Use Quill's code-block format
        _editorController.insertHtml(
          '<pre class="ql-syntax">// Your code here\nvoid main() {\n  print(\'Hello, World!\');\n}</pre>',
        );
        break;

      case 'insertSignature':
        final now = DateTime.now();
        _editorController.insertText(
          '\n──────────────────────────────────\n'
          'Best regards,\n'
          'The Development Team\n'
          '${now.year}-${_pad(now.month)}-${_pad(now.day)}\n',
        );
        break;
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void _executeOneOffAction() {
    // Demonstrate executeCustom for one-off actions
    _editorController.executeCustom(
      action: 'quickNote',
      parameters: {'type': 'note', 'priority': 'high'},
      onResponse: (response) {
        setState(() {
          _executionCount++;
          _lastActionResult = 'Quick Note action executed (#$_executionCount)';
        });
      },
    );

    _editorController.insertHtml('''
<div style="background-color: #e2e3e5; border-left: 4px solid #6c757d; padding: 12px; margin: 12px 0; border-radius: 4px;">
  <strong>📝 Note:</strong> Quick note inserted via one-off action.
</div>
''');
    _showSnackBar('One-off action executed');
  }

  void _clearEditor() {
    _editorController.clear();
    setState(() {
      _wordCount = 0;
      _charCount = 0;
      _lastActionResult = '';
    });
    _showSnackBar('Editor cleared');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            const Text('Custom Actions'),
          ],
        ),
        actions: [
          if (_editorController.isReady) _buildReadyBadge(),
          SaveStatusIndicator(status: _saveStatus),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearEditor,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Editor',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Panel
          SizedBox(
            width: 400,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),

                    // Registered Actions Section
                    _buildSectionLabel('Execute Registered Action'),
                    const SizedBox(height: 12),
                    _buildActionDropdown(),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: 'Execute Action',
                      icon: Icons.play_arrow,
                      color: Colors.teal,
                      onPressed: _editorController.isReady
                          ? _executeSelectedAction
                          : null,
                    ),

                    const SizedBox(height: 28),

                    // One-off Action Section
                    _buildSectionLabel('One-Off Action'),
                    const SizedBox(height: 8),
                    Text(
                      'Execute a custom action without registering it first.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: 'Execute One-Off Action',
                      icon: Icons.flash_on,
                      color: Colors.orange,
                      onPressed: _editorController.isReady
                          ? _executeOneOffAction
                          : null,
                    ),

                    // Last Action Result
                    if (_lastActionResult.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildResultCard(),
                    ],

                    const SizedBox(height: 28),

                    // Registered Actions List
                    _buildRegisteredActionsCard(),

                    const SizedBox(height: 20),

                    // Stats
                    _buildStatsCard(),
                  ],
                ),
              ),
            ),
          ),

          // Editor
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              decoration: AppTheme.editorContainerDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuillEditorWidget(
                  controller: _editorController,
                  onContentChanged: _onContentChanged,
                  initialHtml:
                      '<p>Select and execute custom actions from the panel...</p>',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            'Ready',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Text(
              'Custom Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Register and execute user-defined actions on the editor.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildActionDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.teal.shade50.withValues(alpha: 0.3),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedAction,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Select an action',
        ),
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        items: _actionDefinitions.entries.map((entry) {
          final def = entry.value;
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(def.icon, size: 18, color: Colors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(def.label, overflow: TextOverflow.ellipsis),
                      Text(
                        def.description,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedAction = v),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(backgroundColor: color),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.teal.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _lastActionResult,
              style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredActionsCard() {
    final actionNames = _editorController.registeredActionNames;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'REGISTERED ACTIONS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${actionNames.length}',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: actionNames
                .map((name) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _actionDefinitions[name]?.icon ?? Icons.play_arrow,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Words', _wordCount.toString()),
          Container(width: 1, height: 32, color: Colors.grey.shade300),
          _buildStatItem('Characters', _charCount.toString()),
          Container(width: 1, height: 32, color: Colors.grey.shade300),
          _buildStatItem('Executions', _executionCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ActionDefinition {
  const _ActionDefinition({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}
