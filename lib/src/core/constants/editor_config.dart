/// Editor configuration constants for the Quill Web Editor package.
abstract class EditorConfig {
  /// Default placeholder text
  static const String defaultPlaceholder = 'Start writing your story...';

  /// Throttle duration for content change events (ms)
  static const int contentChangeThrottleMs = 200;

  /// Zoom constraints
  static const double minZoom = 0.5;
  static const double maxZoom = 3.0;
  static const double defaultZoom = 1.0;
  static const double zoomStep = 0.1;

  /// Auto-save debounce duration (ms)
  static const int autoSaveDebounceMs = 500;

  /// Media resize constraints
  static const double minMediaSize = 50.0;

  /// Table constraints
  static const int defaultTableRows = 3;
  static const int defaultTableCols = 3;
  static const int maxTableRows = 20;
  static const int maxTableCols = 10;

  /// Quill CDN URLs
  static const String quillCdnCss =
      'https://cdn.jsdelivr.net/npm/quill@2.0.0/dist/quill.snow.css';
  static const String quillCdnJs =
      'https://cdn.jsdelivr.net/npm/quill@2.0.0/dist/quill.js';
  static const String quillTableBetterCss =
      'https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.css';
  static const String quillTableBetterJs =
      'https://cdn.jsdelivr.net/npm/quill-table-better@1/dist/quill-table-better.js';
  static const String katexCss =
      'https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css';

  /// Editor HTML file paths (relative to web/)
  static const String editorHtmlPath = 'quill_editor.html';
  static const String viewerHtmlPath = 'quill_viewer.html';

  /// CSS classes to remove during HTML export (editor artifacts)
  static const List<String> editorArtifactClasses = [
    'ql-cell-focused',
    'ql-table-selected',
    'ql-cell-selected',
    'ql-table-better-selected-td',
    'ql-table-better-selection-line',
    'ql-table-better-selection-block',
  ];

  /// Data attributes to remove during HTML export
  static const List<String> editorArtifactAttributes = [
    'data-row',
    'data-cell',
    'data-class',
    'data-table-id',
    'contenteditable',
  ];
}

