import 'package:quill_web_editor/quill_web_editor.dart';

/// A plugin that adds GIF insertion support to the editor.
///
/// This is an **extended plugin example** demonstrating how to create
/// custom plugins with JavaScript components.
///
/// ## Features
/// - Toolbar button to insert GIFs from URL
/// - URL input dialog with preview
/// - Size presets (Small, Medium, Large, Original)
/// - Automatic URL validation
/// - Loading state and error handling
///
/// ## Usage
/// ```dart
/// _controller.registerPlugins([
///   GifPlugin(
///     onGifInserted: (url) => print('Inserted GIF: $url'),
///     defaultWidth: 300,
///   ),
/// ]);
/// ```
///
/// ## With all options
/// ```dart
/// GifPlugin(
///   onGifInserted: (url) => analytics.logEvent('gif_inserted', {'url': url}),
///   maxWidth: 400,       // Maximum allowed width
///   maxHeight: 300,      // Maximum allowed height
///   defaultWidth: 300,   // Default width for inserted GIFs
///   showPreview: true,   // Show preview before inserting
/// )
/// ```
///
/// ## JavaScript Component
/// This plugin requires the `gif-picker.js` JavaScript module to be
/// available in the web/js/ folder and properly initialized.
class GifPlugin extends QuillPlugin with QuillPluginMixin {
  GifPlugin({
    this.onGifInserted,
    this.maxWidth,
    this.maxHeight,
    this.defaultWidth = 300,
    this.showPreview = true,
  });

  /// Callback when a GIF is inserted.
  /// Receives the URL of the inserted GIF.
  final void Function(String url)? onGifInserted;

  /// Maximum width for inserted GIFs (in pixels).
  /// If null, no maximum is enforced.
  final int? maxWidth;

  /// Maximum height for inserted GIFs (in pixels).
  /// If null, no maximum is enforced.
  final int? maxHeight;

  /// Default width for inserted GIFs (in pixels).
  /// Defaults to 300.
  final int defaultWidth;

  /// Whether to show a preview before inserting.
  /// Defaults to true.
  final bool showPreview;

  @override
  String get name => 'gif';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Adds GIF insertion support to the editor toolbar';

  @override
  List<QuillToolbarItem> get toolbarItems => [
        const QuillToolbarItem(
          id: 'gif-picker',
          tooltip: 'Insert GIF from URL',
          icon: 'ql-gif',
          action: 'showGifPicker',
          group: ToolbarGroup.insert,
          order: 55,
        ),
      ];

  @override
  List<QuillStylesheet> get stylesheets => [
        const QuillStylesheet(
          id: 'gif-picker-styles',
          css: '''
            /* GIF icon in toolbar */
            .ql-gif::before {
              content: 'GIF';
              font-size: 10px;
              font-weight: bold;
              color: #c45d35;
              border: 1.5px solid #c45d35;
              border-radius: 3px;
              padding: 1px 3px;
              line-height: 1;
            }
            
            .ql-gif:hover::before {
              background: #c45d35;
              color: white;
            }
            
            /* GIF picker dialog overlay */
            .ql-gif-overlay {
              position: fixed;
              top: 0;
              left: 0;
              right: 0;
              bottom: 0;
              background: rgba(0, 0, 0, 0.5);
              display: flex;
              align-items: center;
              justify-content: center;
              z-index: 10000;
              backdrop-filter: blur(2px);
            }
            
            /* GIF picker dialog */
            .ql-gif-picker {
              background: #fff;
              border-radius: 16px;
              box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
              padding: 24px;
              width: 90%;
              max-width: 480px;
              max-height: 80vh;
              overflow: hidden;
              display: flex;
              flex-direction: column;
              animation: gifPickerSlideIn 0.2s ease-out;
            }
            
            @keyframes gifPickerSlideIn {
              from {
                opacity: 0;
                transform: scale(0.95) translateY(-10px);
              }
              to {
                opacity: 1;
                transform: scale(1) translateY(0);
              }
            }
            
            .ql-gif-picker-header {
              display: flex;
              align-items: center;
              justify-content: space-between;
              margin-bottom: 20px;
            }
            
            .ql-gif-picker-title {
              font-size: 18px;
              font-weight: 600;
              color: #333;
              margin: 0;
              display: flex;
              align-items: center;
              gap: 8px;
            }
            
            .ql-gif-picker-title::before {
              content: 'GIF';
              font-size: 12px;
              font-weight: bold;
              color: white;
              background: linear-gradient(135deg, #c45d35, #e67e22);
              border-radius: 4px;
              padding: 2px 6px;
            }
            
            .ql-gif-picker-close {
              background: none;
              border: none;
              font-size: 24px;
              cursor: pointer;
              color: #999;
              padding: 4px;
              line-height: 1;
              border-radius: 6px;
              transition: all 0.15s;
            }
            
            .ql-gif-picker-close:hover {
              background: #f0f0f0;
              color: #333;
            }
            
            .ql-gif-url-input-container {
              position: relative;
              margin-bottom: 16px;
            }
            
            .ql-gif-url-input {
              width: 100%;
              padding: 14px 16px;
              padding-right: 80px;
              border: 2px solid #e0e0e0;
              border-radius: 12px;
              font-size: 14px;
              outline: none;
              transition: all 0.2s;
              box-sizing: border-box;
            }
            
            .ql-gif-url-input:focus {
              border-color: #c45d35;
              box-shadow: 0 0 0 3px rgba(196, 93, 53, 0.1);
            }
            
            .ql-gif-url-input::placeholder {
              color: #aaa;
            }
            
            .ql-gif-paste-btn {
              position: absolute;
              right: 8px;
              top: 50%;
              transform: translateY(-50%);
              background: #f5f5f5;
              border: none;
              padding: 8px 12px;
              border-radius: 8px;
              font-size: 12px;
              cursor: pointer;
              color: #666;
              transition: all 0.15s;
            }
            
            .ql-gif-paste-btn:hover {
              background: #e8e8e8;
              color: #333;
            }
            
            /* Preview section */
            .ql-gif-preview-container {
              flex: 1;
              min-height: 150px;
              max-height: 300px;
              background: #f8f8f8;
              border-radius: 12px;
              display: flex;
              align-items: center;
              justify-content: center;
              margin-bottom: 16px;
              overflow: hidden;
              border: 2px dashed #e0e0e0;
            }
            
            .ql-gif-preview-container.has-preview {
              border-style: solid;
              border-color: #c45d35;
              background: #fff;
            }
            
            .ql-gif-preview-placeholder {
              text-align: center;
              color: #999;
            }
            
            .ql-gif-preview-placeholder svg {
              width: 48px;
              height: 48px;
              margin-bottom: 8px;
              opacity: 0.5;
            }
            
            .ql-gif-preview-img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
              border-radius: 8px;
            }
            
            .ql-gif-loading {
              display: flex;
              flex-direction: column;
              align-items: center;
              gap: 12px;
              color: #666;
            }
            
            .ql-gif-loading-spinner {
              width: 32px;
              height: 32px;
              border: 3px solid #e0e0e0;
              border-top-color: #c45d35;
              border-radius: 50%;
              animation: gifSpin 0.8s linear infinite;
            }
            
            @keyframes gifSpin {
              to { transform: rotate(360deg); }
            }
            
            .ql-gif-error {
              color: #e74c3c;
              text-align: center;
              padding: 16px;
            }
            
            .ql-gif-error svg {
              width: 32px;
              height: 32px;
              margin-bottom: 8px;
            }
            
            /* Action buttons */
            .ql-gif-actions {
              display: flex;
              gap: 12px;
              justify-content: flex-end;
            }
            
            .ql-gif-btn {
              padding: 12px 24px;
              border-radius: 10px;
              font-size: 14px;
              font-weight: 500;
              cursor: pointer;
              transition: all 0.15s;
              border: none;
            }
            
            .ql-gif-btn-cancel {
              background: #f0f0f0;
              color: #666;
            }
            
            .ql-gif-btn-cancel:hover {
              background: #e0e0e0;
              color: #333;
            }
            
            .ql-gif-btn-insert {
              background: linear-gradient(135deg, #c45d35, #e67e22);
              color: white;
            }
            
            .ql-gif-btn-insert:hover {
              transform: translateY(-1px);
              box-shadow: 0 4px 12px rgba(196, 93, 53, 0.3);
            }
            
            .ql-gif-btn-insert:disabled {
              background: #ccc;
              cursor: not-allowed;
              transform: none;
              box-shadow: none;
            }
            
            /* Size options */
            .ql-gif-size-options {
              display: flex;
              gap: 8px;
              margin-bottom: 16px;
              flex-wrap: wrap;
            }
            
            .ql-gif-size-option {
              padding: 6px 12px;
              border: 1px solid #e0e0e0;
              border-radius: 6px;
              font-size: 12px;
              cursor: pointer;
              background: white;
              color: #666;
              transition: all 0.15s;
            }
            
            .ql-gif-size-option:hover,
            .ql-gif-size-option.selected {
              border-color: #c45d35;
              color: #c45d35;
              background: rgba(196, 93, 53, 0.05);
            }
            
            .ql-gif-size-option.selected {
              font-weight: 500;
            }
          ''',
        ),
      ];

  @override
  Map<String, QuillCommandHandler> get commandHandlers => {
        'showGifPicker': (params, controller) async {
          // The actual GIF picker is shown via JavaScript
          // This handler is called when the picker button is clicked
          // No action needed here - JS handles showing the picker
        },
        'insertGif': (params, controller) async {
          // NOTE: The GIF is already inserted by JavaScript directly into Quill
          // This handler is only for Flutter-side callbacks (e.g., analytics, logging)
          // DO NOT insert again here - that would cause duplicates!
          final url = params?['url'] as String?;
          if (url != null) {
            onGifInserted?.call(url);
          }
        },
      };

  @override
  List<QuillModule> get modules => [
        QuillModule(
          name: 'gif',
          options: {
            'maxWidth': maxWidth,
            'maxHeight': maxHeight,
            'defaultWidth': defaultWidth,
            'showPreview': showPreview,
          },
        ),
      ];
}

