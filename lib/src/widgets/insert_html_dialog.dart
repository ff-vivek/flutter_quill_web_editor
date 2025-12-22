import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../core/constants/app_colors.dart';

/// Result from the insert HTML dialog.
class InsertHtmlResult {
  const InsertHtmlResult({
    required this.html,
    required this.replaceContent,
  });

  /// The HTML content to insert.
  final String html;

  /// Whether to replace existing content.
  final bool replaceContent;
}

/// A dialog for inserting HTML content into the editor.
class InsertHtmlDialog extends StatefulWidget {
  const InsertHtmlDialog({
    super.key,
    this.title = 'Insert HTML',
    this.placeholder = '<p>Your HTML content here...</p>',
    this.insertButtonLabel = 'Insert',
    this.cancelButtonLabel = 'Cancel',
    this.replaceCheckboxLabel = 'Replace existing content',
  });

  /// Dialog title.
  final String title;

  /// Placeholder text for the textarea.
  final String placeholder;

  /// Label for the insert button.
  final String insertButtonLabel;

  /// Label for the cancel button.
  final String cancelButtonLabel;

  /// Label for the replace content checkbox.
  final String replaceCheckboxLabel;

  /// Shows the dialog and returns the result.
  static Future<InsertHtmlResult?> show(
    BuildContext context, {
    String title = 'Insert HTML',
  }) {
    return showDialog<InsertHtmlResult>(
      context: context,
      builder: (context) => PointerInterceptor(
        child: InsertHtmlDialog(title: title),
      ),
    );
  }

  @override
  State<InsertHtmlDialog> createState() => _InsertHtmlDialogState();
}

class _InsertHtmlDialogState extends State<InsertHtmlDialog> {
  final _textController = TextEditingController();
  bool _replaceContent = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleInsert() {
    final html = _textController.text.trim();
    if (html.isEmpty) return;

    Navigator.pop(
      context,
      InsertHtmlResult(
        html: html,
        replaceContent: _replaceContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.code,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Label
            const Text(
              'Paste your HTML code below:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Text area
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Replace content checkbox
            Row(
              children: [
                Checkbox(
                  value: _replaceContent,
                  onChanged: (value) {
                    setState(() => _replaceContent = value ?? false);
                  },
                  activeColor: AppColors.accent,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _replaceContent = !_replaceContent);
                  },
                  child: Text(
                    widget.replaceCheckboxLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(widget.cancelButtonLabel),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _handleInsert,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(widget.insertButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
