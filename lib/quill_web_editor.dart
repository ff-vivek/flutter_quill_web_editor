/// Quill Web Editor - A rich text editor package for Flutter Web.
///
/// This package provides a Quill.js-based rich text editor with full
/// Flutter integration, including:
///
/// - Rich text editing with formatting toolbar
/// - Table support with quill-table-better
/// - Custom fonts and sizes
/// - Image, video, and media embedding
/// - HTML import/export
/// - Preview functionality
/// - Zoom controls
/// - **Plugin system for extensibility**
///
/// ## Getting Started (Using Controller - Recommended)
///
/// ```dart
/// import 'package:quill_web_editor/quill_web_editor.dart';
///
/// class MyEditor extends StatefulWidget {
///   @override
///   State<MyEditor> createState() => _MyEditorState();
/// }
///
/// class _MyEditorState extends State<MyEditor> {
///   final _controller = QuillEditorController();
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   void _insertText() {
///     _controller.insertText('Hello World!');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return QuillEditorWidget(
///       controller: _controller,
///       onContentChanged: (html, delta) {
///         print('Content: $html');
///       },
///       initialHtml: '<p>Hello World!</p>',
///     );
///   }
/// }
/// ```
///
/// ## Plugin System
///
/// Extend the editor with plugins from other packages:
///
/// ```dart
/// import 'package:quill_web_editor/quill_web_editor.dart';
/// import 'package:some_quill_plugin/some_quill_plugin.dart';
///
/// void main() {
///   // Register plugins before runApp
///   QuillPluginRegistry.instance.register(SomePlugin());
///
///   runApp(MyApp());
/// }
/// ```
///
/// Create your own plugin:
///
/// ```dart
/// class MyPlugin extends QuillPlugin {
///   @override
///   String get name => 'my-plugin';
///
///   @override
///   List<QuillToolbarItem> get toolbarItems => [...];
///
///   @override
///   List<QuillFormat> get formats => [...];
/// }
/// ```
///
/// ## Features
///
/// ### Core Components
/// - [QuillEditorController] - Controller for programmatic editor access
/// - [QuillEditorWidget] - Main editor widget
/// - [QuillEditorWidgetState] - Editor state (legacy GlobalKey access)
///
/// ### Plugin System
/// - [QuillPlugin] - Base class for creating plugins
/// - [QuillPluginRegistry] - Singleton for managing plugins
/// - [QuillToolbarItem] - Custom toolbar buttons/dropdowns
/// - [QuillFormat] - Custom text formats
/// - [QuillModule] - Custom Quill modules
/// - [QuillKeyBinding] - Custom keyboard shortcuts
/// - [QuillStylesheet] - Custom CSS injection
/// - [PluginBundle] - Group multiple plugins together
///
/// ### Built-in Plugins
/// - [EmojiPlugin] - Emoji picker
/// - [MentionPlugin] - @mention support
/// - [HashtagPlugin] - #hashtag support
/// - [CodeHighlightPlugin] - Syntax highlighting
/// - [AutoLinkPlugin] - Auto-detect URLs
/// - [WordCountPlugin] - Word/character count
///
/// ### UI Components
/// - [SaveStatusIndicator] - Shows save status (saved/saving/unsaved)
/// - [ZoomControls] - Zoom in/out controls
/// - [OutputPreview] - HTML/text output preview
/// - [StatCard] - Document statistics display
/// - [AppCard] - Styled card component
/// - [HtmlPreviewDialog] - Full-screen HTML preview
/// - [InsertHtmlDialog] - HTML insertion dialog
///
/// ### Services
/// - [DocumentService] - Download, copy, print operations
///
/// ### Utilities
/// - [HtmlCleaner] - Clean HTML for export
/// - [TextStats] - Calculate word/character counts
/// - [ExportStyles] - CSS for exported HTML
/// - [FontRegistry] - Register custom fonts for export
/// - [CustomFontConfig] - Configuration for custom fonts with priority loading
/// - [FontVariant] - Individual font file configuration (weight, style, URL)
///
/// ### Constants
/// - [AppColors] - Color palette
/// - [AppFonts] - Font configurations
/// - [EditorConfig] - Editor settings
///
/// ### Theme
/// - [AppTheme] - Theme configuration
library quill_web_editor;

// Core
export 'src/core/constants/app_colors.dart';
export 'src/core/constants/app_fonts.dart';
export 'src/core/constants/editor_config.dart';
export 'src/core/theme/app_theme.dart';
export 'src/core/utils/export_styles.dart';
export 'src/core/utils/font_registry.dart';
export 'src/core/utils/html_cleaner.dart';
export 'src/core/utils/text_stats.dart';

// Plugins
export 'src/plugins/built_in_plugins.dart';
export 'src/plugins/quill_plugin.dart';
export 'src/plugins/quill_plugin_registry.dart';

// Services
export 'src/services/document_service.dart';
export 'src/widgets/app_card.dart';
export 'src/widgets/html_preview_dialog.dart';
export 'src/widgets/insert_html_dialog.dart';
export 'src/widgets/output_preview.dart';

// Widgets
export 'src/widgets/quill_editor_controller.dart';
export 'src/widgets/quill_editor_widget.dart';
export 'src/widgets/save_status_indicator.dart';
export 'src/widgets/stat_card.dart';
export 'src/widgets/zoom_controls.dart';
