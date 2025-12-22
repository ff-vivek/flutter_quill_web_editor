import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

import 'pages/editor_example_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const EditorExamplePage(),
    );
  }
}
