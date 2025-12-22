import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

/// Example page demonstrating the Quill Web Editor package.
class EditorExamplePage extends StatefulWidget {
  const EditorExamplePage({super.key});

  @override
  State<EditorExamplePage> createState() => _EditorExamplePageState();
}

class _EditorExamplePageState extends State<EditorExamplePage> {
  final GlobalKey<QuillEditorWidgetState> _editorKey = GlobalKey();

  String _currentHtml = '';
  int _wordCount = 0;
  int _charCount = 0;
  double _zoomLevel = 1.0;
  SaveStatus _saveStatus = SaveStatus.saved;
  Timer? _saveTimer;

  /// Sample content to demonstrate the editor.
  static const String _sampleHtml = '''
<h1>Welcome to Quill Editor</h1>
<p>This is a <strong>rich text editor</strong> powered by <a href="https://quilljs.com">Quill.js</a> and integrated into Flutter.</p>
<h2>Features</h2>
<ul>
  <li>Rich text formatting (bold, italic, underline)</li>
  <li>Headers and paragraphs</li>
  <li>Lists (ordered and unordered)</li>
  <li>Links and images</li>
  <li>Tables with full editing support</li>
  <li>Undo/Redo support ↩️</li>
  <li>Emoji picker 😀</li>
  <li>Markdown shortcuts</li>
</ul>
<blockquote>Try the undo (Ctrl+Z) and redo (Ctrl+Y) buttons above!</blockquote>
''';

  void _onContentChanged(String html, dynamic delta) {
    setState(() {
      _currentHtml = html;
      _saveStatus = SaveStatus.unsaved;
    });

    // Update stats
    final stats = TextStats.fromHtml(html);
    setState(() {
      _wordCount = stats.wordCount;
      _charCount = stats.charCount;
    });

    // Debounced auto-save simulation
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _saveStatus = SaveStatus.saving);
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _saveStatus = SaveStatus.saved);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  void _loadSampleContent() {
    _editorKey.currentState?.setHTML(_sampleHtml);
    _showSnackBar('Sample content loaded');
  }

  void _clearEditor() {
    showDialog<void>(
      context: context,
      builder: (context) => PointerInterceptor(
        child: AlertDialog(
          title: const Text('Clear Editor'),
          content: const Text('Are you sure you want to clear all content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editorKey.currentState?.clear();
                setState(() {
                  _currentHtml = '';
                  _wordCount = 0;
                  _charCount = 0;
                });
                _showSnackBar('Editor cleared');
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadHtml() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to download');
      return;
    }
    DocumentService.downloadHtml(_currentHtml);
    _showSnackBar('Document downloaded');
  }

  void _generateAndPrintHtml() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to generate');
      return;
    }
    final htmlDocument = DocumentService.generateHtmlDocument(
      _currentHtml,
      cleanHtml: true,
      title: 'Quill Editor Document',
    );
    final separator = '=' * 80;

    debugPrint(separator);

    debugPrint('Generated HTML Document:');

    debugPrint(separator);

    debugPrint(htmlDocument);

    debugPrint(separator);
    _showSnackBar('HTML document printed to console');
  }

  void _showPreview() {
    if (_currentHtml.isEmpty) {
      _showSnackBar('No content to preview');
      return;
    }
    HtmlPreviewDialog.show(context, _currentHtml);
  }

  void _showInsertHtmlDialog() async {
    final result = await InsertHtmlDialog.show(context);
    if (result != null) {
      _editorKey.currentState?.insertHtml(
        result.html,
        replace: result.replaceContent,
      );
      _showSnackBar('HTML inserted successfully');
    }
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
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_note,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Quill Editor'),
          ],
        ),
        actions: [
          // Undo/Redo buttons
          IconButton(
            onPressed: () => _editorKey.currentState?.undo(),
            icon: const Icon(Icons.undo),
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            onPressed: () => _editorKey.currentState?.redo(),
            icon: const Icon(Icons.redo),
            tooltip: 'Redo (Ctrl+Y)',
          ),
          const SizedBox(width: 8),
          // Zoom controls
          ZoomControls(
            zoomLevel: _zoomLevel,
            onZoomIn: () {
              _editorKey.currentState?.zoomIn();
              setState(() {
                _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0);
              });
            },
            onZoomOut: () {
              _editorKey.currentState?.zoomOut();
              setState(() {
                _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0);
              });
            },
            onReset: () {
              _editorKey.currentState?.resetZoom();
              setState(() => _zoomLevel = 1.0);
            },
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _showInsertHtmlDialog,
            icon: const Icon(Icons.code),
            label: const Text('Insert HTML'),
          ),
          TextButton.icon(
            onPressed: _loadSampleContent,
            icon: const Icon(Icons.file_download_outlined),
            label: const Text('Sample'),
          ),
          TextButton.icon(
            onPressed: _showPreview,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Preview'),
          ),
          Tooltip(
            message: 'Generate and print HTML document to console',
            child: TextButton.icon(
              onPressed: _generateAndPrintHtml,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print HTML'),
            ),
          ),
          TextButton.icon(
            onPressed: _clearEditor,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 8),
          SaveStatusIndicator(status: _saveStatus),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _downloadHtml,
            icon: const Icon(Icons.save_alt),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Editor
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: AppTheme.editorContainerDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: QuillEditorWidget(
                  key: _editorKey,
                  onContentChanged: _onContentChanged,
                  initialHtml: _sampleHtml,
                ),
              ),
            ),
          ),
          // Sidebar
          SizedBox(
            width: 320,
            child: Container(
              margin: const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              child: Column(
                children: [
                  // Stats Card
                  AppCard(
                    title: 'Document Info',
                    child: StatCardRow(
                      stats: [
                        (
                          label: 'Words',
                          value: _wordCount.toString(),
                          icon: null
                        ),
                        (
                          label: 'Characters',
                          value: _charCount.toString(),
                          icon: null
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Output Preview Card
                  Expanded(
                    child: Container(
                      decoration: AppTheme.cardDecoration,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OUTPUT PREVIEW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: OutputPreview(html: _currentHtml),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
