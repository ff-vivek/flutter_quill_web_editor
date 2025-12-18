import 'package:flutter/material.dart';
import 'package:quill_web_editor/quill_web_editor.dart';

import 'pages/dashboard_page.dart';
import 'services/document_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local database
  await DocumentDbService.initialize();

  runApp(const QuillEditorExampleApp());
}

/// Example application demonstrating the Quill Web Editor package.
class QuillEditorExampleApp extends StatelessWidget {
  const QuillEditorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill Web Editor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}
