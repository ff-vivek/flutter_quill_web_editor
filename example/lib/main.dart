import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

import 'pages/custom_actions_example_page.dart';
import 'pages/dropdown_insert_example_page.dart';
import 'pages/editor_example_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // CUSTOM FONT REGISTRATION EXAMPLE
  // ============================================
  // This demonstrates the three-priority font loading strategy:
  //
  // Priority 1: Hosted Assets (your CDN/server)
  //   - Use 'hostedFontBaseUrl' + 'hostedFontVariants'
  //   - Best for: custom/proprietary fonts, offline support
  //
  // Priority 2: Google Fonts (optional fallback)
  //   - Use 'googleFontsFamily'
  //   - Best for: fallback if hosted assets fail
  //
  // Priority 3: System Fallback (always works)
  //   - Use 'fallback' (e.g., 'sans-serif', 'Arial, sans-serif')
  //   - Best for: graceful degradation
  //
  // See also:
  // - example/web/styles/mulish-font.css (local @font-face for editor)
  // - example/web/js/config-override.js (adds font to editor dropdown)
  // ============================================
  FontRegistry.instance.registerFont(
    const CustomFontConfig(
      name: 'Mulish',
      value: 'mulish',
      fontFamily: 'Mulish',
      hostedFontBaseUrl: 'https://quill-editor-demo.netlify.app/assets/fonts/',
      hostedFontVariants: [
        // ExtraLight (200)
        FontVariant(
            url: 'Mulish-ExtraLight.ttf', weight: 200, format: 'truetype'),
        FontVariant(
            url: 'Mulish-ExtraLightItalic.ttf',
            weight: 200,
            isItalic: true,
            format: 'truetype'),
        // Light (300)
        FontVariant(url: 'Mulish-Light.ttf', weight: 300, format: 'truetype'),
        FontVariant(
            url: 'Mulish-LightItalic.ttf',
            weight: 300,
            isItalic: true,
            format: 'truetype'),
        // Regular (400)
        FontVariant(url: 'Mulish-Regular.ttf', weight: 400, format: 'truetype'),
        FontVariant(
            url: 'Mulish-Italic.ttf',
            weight: 400,
            isItalic: true,
            format: 'truetype'),
        // Medium (500)
        FontVariant(url: 'Mulish-Medium.ttf', weight: 500, format: 'truetype'),
        FontVariant(
            url: 'Mulish-MediumItalic.ttf',
            weight: 500,
            isItalic: true,
            format: 'truetype'),
        // SemiBold (600)
        FontVariant(
            url: 'Mulish-SemiBold.ttf', weight: 600, format: 'truetype'),
        FontVariant(
            url: 'Mulish-SemiBoldItalic.ttf',
            weight: 600,
            isItalic: true,
            format: 'truetype'),
        // Bold (700)
        FontVariant(url: 'Mulish-Bold.ttf', weight: 700, format: 'truetype'),
        FontVariant(
            url: 'Mulish-BoldItalic.ttf',
            weight: 700,
            isItalic: true,
            format: 'truetype'),
        // ExtraBold (800)
        FontVariant(
            url: 'Mulish-ExtraBold.ttf', weight: 800, format: 'truetype'),
        FontVariant(
            url: 'Mulish-ExtraBoldItalic.ttf',
            weight: 800,
            isItalic: true,
            format: 'truetype'),
        // Black (900)
        FontVariant(url: 'Mulish-Black.ttf', weight: 900, format: 'truetype'),
        FontVariant(
            url: 'Mulish-BlackItalic.ttf',
            weight: 900,
            isItalic: true,
            format: 'truetype'),
      ],
      // Priority 2: Google Fonts fallback (works online)
      googleFontsFamily:
          'Mulish:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900',
      // Priority 3: System fallback
      fallback: 'sans-serif',
    ),
  );

  runApp(const QuillEditorExampleApp());
}

/// Example application demonstrating the Quill Web Editor package.
class QuillEditorExampleApp extends StatelessWidget {
  const QuillEditorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill Web Editor Example',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ExampleHomePage(),
    );
  }
}

/// Home page with navigation to different examples.
class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_document,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quill Web Editor',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an example to explore',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),

                // Example Cards
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _ExampleCard(
                      title: 'Full Editor',
                      description:
                          'Complete editor with all features including formatting, undo/redo, zoom, and HTML preview.',
                      icon: Icons.edit_note,
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const EditorExamplePage(),
                          ),
                        );
                      },
                    ),
                    _ExampleCard(
                      title: 'Dropdown Insert',
                      description:
                          'Insert content from Flutter dropdowns directly into the editor using the controller.',
                      icon: Icons.playlist_add,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const DropdownInsertExamplePage(),
                          ),
                        );
                      },
                    ),
                    _ExampleCard(
                      title: 'Custom Actions',
                      description:
                          'Register and execute user-defined custom actions with callbacks and responses.',
                      icon: Icons.bolt,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                const CustomActionsExamplePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatefulWidget {
  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<_ExampleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? widget.color : Colors.grey.shade200,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.2)
                    : Colors.grey.shade200,
                blurRadius: _isHovered ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: widget.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
