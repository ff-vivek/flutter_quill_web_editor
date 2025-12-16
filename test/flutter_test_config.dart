import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test configuration for the Quill Web Editor package.
///
/// This file is automatically detected by Flutter's test framework and runs
/// before any tests. It sets up Google Fonts for the test environment.
///
/// The fonts are bundled in test/fonts/ and registered in pubspec.yaml.
/// This allows the google_fonts package to use them without network access.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable runtime fetching - use bundled fonts from pubspec.yaml
  GoogleFonts.config.allowRuntimeFetching = false;

  return testMain();
}
