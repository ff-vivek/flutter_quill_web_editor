// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/editor_config.dart';
import '../core/utils/export_styles.dart';
import 'zoom_controls.dart';

/// A dialog that displays an HTML preview of the editor content.
///
/// Supports zoom controls and renders content with proper Quill styling.
class HtmlPreviewDialog extends StatelessWidget {
  const HtmlPreviewDialog({
    super.key,
    required this.html,
    this.title = 'HTML Preview',
    this.defaultFont,
  });

  /// The HTML content to preview.
  final String html;

  /// Dialog title.
  final String title;

  /// Default font for the preview (e.g., 'mulish', 'roboto').
  final String? defaultFont;

  /// Shows the preview dialog.
  ///
  /// [defaultFont] - Optional default font value (e.g., 'mulish', 'roboto').
  static Future<void> show(
    BuildContext context,
    String html, {
    String? defaultFont,
  }) {
    return showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
        child: HtmlPreviewDialog(html: html, defaultFont: defaultFont),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _HtmlPreviewDialogContent(
      html: html,
      title: title,
      defaultFont: defaultFont,
    );
  }
}

class _HtmlPreviewDialogContent extends StatefulWidget {
  const _HtmlPreviewDialogContent({
    required this.html,
    required this.title,
    this.defaultFont,
  });

  final String html;
  final String title;
  final String? defaultFont;

  @override
  State<_HtmlPreviewDialogContent> createState() =>
      _HtmlPreviewDialogContentState();
}

class _HtmlPreviewDialogContentState extends State<_HtmlPreviewDialogContent> {
  final GlobalKey<_HtmlPreviewWidgetState> _previewKey = GlobalKey();
  double _currentZoom = 1.0;

  void _zoomIn() {
    _previewKey.currentState?.zoomIn();
    setState(() {
      _currentZoom = _previewKey.currentState?.currentZoom ?? _currentZoom;
    });
  }

  void _zoomOut() {
    _previewKey.currentState?.zoomOut();
    setState(() {
      _currentZoom = _previewKey.currentState?.currentZoom ?? _currentZoom;
    });
  }

  void _resetZoom() {
    _previewKey.currentState?.resetZoom();
    setState(() {
      _currentZoom = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.preview_outlined,
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
                  ZoomControls(
                    zoomLevel: _currentZoom,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onReset: _resetZoom,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Preview content
            Expanded(
              child: _HtmlPreviewWidget(
                key: _previewKey,
                html: widget.html,
                defaultFont: widget.defaultFont,
                onZoomChanged: (zoom) {
                  setState(() => _currentZoom = zoom);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display HTML preview in an iframe.
class _HtmlPreviewWidget extends StatefulWidget {
  const _HtmlPreviewWidget({
    super.key,
    required this.html,
    this.defaultFont,
    this.onZoomChanged,
  });

  final String html;
  final String? defaultFont;
  final void Function(double zoom)? onZoomChanged;

  @override
  State<_HtmlPreviewWidget> createState() => _HtmlPreviewWidgetState();
}

class _HtmlPreviewWidgetState extends State<_HtmlPreviewWidget> {
  html.IFrameElement? _iframe;
  static int _viewIdCounter = 0;
  late int _viewId;
  double _currentZoom = 1.0;

  double get currentZoom => _currentZoom;

  @override
  void initState() {
    super.initState();
    _viewId = ++_viewIdCounter;
    _registerViewFactory();
  }

  void _registerViewFactory() {
    final escapedHtml = widget.html
        .replaceAll("'", "\\'")
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '');

    // Build the viewer class with optional default font
    final viewerClass =
        widget.defaultFont != null && widget.defaultFont!.isNotEmpty
            ? 'ql-editor ql-font-${widget.defaultFont}'
            : 'ql-editor';

    final previewHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  ${ExportStyles.externalStylesheets.map((url) => '<link href="$url" rel="stylesheet">').join('\n  ')}
  <style>
    ${ExportStyles.fullCss}
    
    /* Prevent FOUC - hide content until fonts load */
    body {
      opacity: 0;
      transition: opacity 0.15s ease-in;
    }
    body.fonts-loaded {
      opacity: 1;
    }
    
    .ql-editor {
      transform-origin: top left;
      transition: transform 0.15s ease-out;
    }
  </style>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      (document.fonts?.ready || Promise.resolve()).then(function() {
        document.body.classList.add('fonts-loaded');
      });
    });
  </script>
</head>
<body>
  <div id="viewer" class="$viewerClass"></div>
  <script>
    function cleanHtmlForPreview(html) {
      const parser = new DOMParser();
      const doc = parser.parseFromString('<div>' + html + '</div>', 'text/html');
      const container = doc.body.firstChild;
      
      const selectionClasses = [
        'ql-cell-focused', 'ql-table-selected', 'ql-cell-selected',
        'ql-table-better-selected-td', 'ql-table-better-selection-line',
        'ql-table-better-selection-block'
      ];
      
      container.querySelectorAll('*').forEach(function(el) {
        selectionClasses.forEach(function(cls) { el.classList.remove(cls); });
        el.removeAttribute('data-row');
        el.removeAttribute('data-cell');
        el.removeAttribute('data-class');
        el.removeAttribute('data-table-id');
        el.removeAttribute('contenteditable');
      });
      
      container.querySelectorAll('temporary, [class*="ql-table-better-tool"]').forEach(function(el) {
        el.remove();
      });
      
      return container.innerHTML;
    }
    
    var initialHtml = '$escapedHtml';
    document.getElementById('viewer').innerHTML = cleanHtmlForPreview(initialHtml);
    
    window.addEventListener('message', function(event) {
      try {
        const data = JSON.parse(event.data);
        if (data.type === 'command' && data.action === 'setZoom') {
          const zoomLevel = Math.max(${EditorConfig.minZoom}, Math.min(${EditorConfig.maxZoom}, data.zoom));
          const viewer = document.getElementById('viewer');
          if (viewer) {
            viewer.style.transform = 'scale(' + zoomLevel + ')';
            viewer.style.width = (100 / zoomLevel) + '%';
          }
        }
      } catch (e) {}
    });
  </script>
</body>
</html>
''';

    final blob = html.Blob([previewHtml], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'html-preview-$_viewId',
      (int viewId) {
        _iframe = html.IFrameElement()
          ..src = url
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%';
        return _iframe!;
      },
    );
  }

  void zoomIn() {
    _currentZoom = (_currentZoom + EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _sendZoomCommand(_currentZoom);
    widget.onZoomChanged?.call(_currentZoom);
  }

  void zoomOut() {
    _currentZoom = (_currentZoom - EditorConfig.zoomStep)
        .clamp(EditorConfig.minZoom, EditorConfig.maxZoom);
    _sendZoomCommand(_currentZoom);
    widget.onZoomChanged?.call(_currentZoom);
  }

  void resetZoom() {
    _currentZoom = 1.0;
    _sendZoomCommand(_currentZoom);
    widget.onZoomChanged?.call(_currentZoom);
  }

  void _sendZoomCommand(double zoom) {
    if (_iframe == null) return;
    final jsonString = '{"type":"command","action":"setZoom","zoom":$zoom}';
    _iframe?.contentWindow?.postMessage(jsonString, '*');
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: 'html-preview-$_viewId');
  }
}
