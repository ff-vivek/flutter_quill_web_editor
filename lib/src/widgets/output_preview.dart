import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/html_cleaner.dart';

/// Type of output to display in the preview.
enum OutputType {
  /// Raw HTML output.
  html,

  /// Plain text output.
  text,
}

/// A widget that displays the editor output in different formats.
///
/// Supports switching between HTML and plain text views.
class OutputPreview extends StatefulWidget {
  const OutputPreview({
    super.key,
    required this.html,
    this.initialOutputType = OutputType.html,
    this.onOutputTypeChanged,
    this.maxHeight,
  });

  /// The HTML content to display.
  final String html;

  /// Initial output type to display.
  final OutputType initialOutputType;

  /// Callback when output type changes.
  final ValueChanged<OutputType>? onOutputTypeChanged;

  /// Maximum height of the preview. If null, expands to fill parent.
  final double? maxHeight;

  @override
  State<OutputPreview> createState() => _OutputPreviewState();
}

class _OutputPreviewState extends State<OutputPreview> {
  late OutputType _outputType;

  @override
  void initState() {
    super.initState();
    _outputType = widget.initialOutputType;
  }

  void _setOutputType(OutputType type) {
    setState(() => _outputType = type);
    widget.onOutputTypeChanged?.call(type);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Row(
          children: [
            _buildTab('HTML', OutputType.html),
            const SizedBox(width: 8),
            _buildTab('Text', OutputType.text),
          ],
        ),
        const SizedBox(height: 12),
        // Content
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _getContent(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getContent() {
    return switch (_outputType) {
      OutputType.html => widget.html,
      OutputType.text => HtmlCleaner.extractText(widget.html),
    };
  }

  Widget _buildTab(String label, OutputType type) {
    final isSelected = _outputType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setOutputType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : AppColors.background,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

