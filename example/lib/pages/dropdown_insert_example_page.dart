import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

/// Example page demonstrating inserting dropdown values into Quill editor
/// using [QuillEditorController] for state management.
class DropdownInsertExamplePage extends StatefulWidget {
  const DropdownInsertExamplePage({super.key});

  @override
  State<DropdownInsertExamplePage> createState() =>
      _DropdownInsertExamplePageState();
}

class _DropdownInsertExamplePageState extends State<DropdownInsertExamplePage> {
  final QuillEditorController _editorController = QuillEditorController();

  int _wordCount = 0;
  int _charCount = 0;
  SaveStatus _saveStatus = SaveStatus.saved;
  Timer? _saveTimer;

  // Dropdown selections
  String? _selectedTemplate;
  String? _selectedVariable;

  // Template options
  static const Map<String, String> _templateOptions = {
    'greeting': 'Hello, welcome to our service!',
    'thankyou': 'Thank you for your business.',
    'signature': 'Best regards,\nThe Team',
    'disclaimer':
        'This document is confidential and intended solely for the addressee.',
    'contact':
        'For any queries, please contact us at support@example.com or call +1-800-123-4567.',
  };

  // Variable placeholders
  static const Map<String, String> _variableOptions = {
    'customer_name': '{{CUSTOMER_NAME}}',
    'order_id': '{{ORDER_ID}}',
    'date': '{{DATE}}',
    'amount': '{{AMOUNT}}',
    'product_name': '{{PRODUCT_NAME}}',
    'company_name': '{{COMPANY_NAME}}',
  };

  @override
  void initState() {
    super.initState();
    _editorController.addListener(_onControllerChanged);
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

  void _insertTemplate() {
    if (_selectedTemplate == null) {
      _showSnackBar('Please select a template first');
      return;
    }
    final text = _templateOptions[_selectedTemplate];
    if (text != null) {
      _editorController.insertText(text);
      _showSnackBar('Template inserted: ${_formatLabel(_selectedTemplate!)}');
    }
  }

  void _insertVariable() {
    if (_selectedVariable == null) {
      _showSnackBar('Please select a variable first');
      return;
    }
    final text = _variableOptions[_selectedVariable];
    if (text != null) {
      _editorController.insertText(text);
      _showSnackBar('Variable inserted: ${_formatLabel(_selectedVariable!)}');
    }
  }

  void _clearEditor() {
    _editorController.clear();
    setState(() {
      _wordCount = 0;
      _charCount = 0;
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

  String _formatLabel(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.playlist_add, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            const Text('Dropdown Insert'),
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
          // Left Panel - Controls
          SizedBox(
            width: 360,
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Template Section
                  _buildSectionLabel('Templates'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    value: _selectedTemplate,
                    hint: 'Select a template',
                    items: _templateOptions.keys.toList(),
                    onChanged: (v) => setState(() => _selectedTemplate = v),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Insert Template',
                    icon: Icons.add,
                    onPressed:
                        _editorController.isReady ? _insertTemplate : null,
                  ),

                  const SizedBox(height: 32),

                  // Variable Section
                  _buildSectionLabel('Variables'),
                  const SizedBox(height: 12),
                  _buildVariableDropdown(),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Insert Variable',
                    icon: Icons.code,
                    onPressed:
                        _editorController.isReady ? _insertVariable : null,
                  ),

                  const Spacer(),

                  // Info
                  _buildInfoCard(
                    'Using QuillEditorController to insert dropdown values',
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  _buildStatsCard(),
                ],
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
                      '<p>Start typing or use the dropdowns to insert content...</p>',
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
            Icon(Icons.arrow_drop_down_circle_outlined,
                color: AppColors.accent, size: 28),
            const SizedBox(width: 12),
            Text(
              'Insert Content',
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
          'Select values from dropdowns and insert them into the editor.',
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: hint,
        ),
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        items: items.map((key) {
          return DropdownMenuItem<String>(
            value: key,
            child: Text(_formatLabel(key), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildVariableDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedVariable,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: 'Select a variable',
        ),
        icon: const Icon(Icons.keyboard_arrow_down),
        isExpanded: true,
        items: _variableOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_formatLabel(entry.key),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedVariable = v),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildInfoCard(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: AppColors.accent),
            ),
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
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
