# Gemini Project Helper

This document provides essential information for AI agents like Gemini to understand and work with the `quill_web_editor` project.

## 1. Project Overview

`quill_web_editor` is a powerful, full-featured rich text editor package for Flutter Web. It is powered by [Quill.js](https://quilljs.com/) and provides a rich text editing experience within a Flutter web application.

Key features include:
- Rich text formatting (bold, italic, underline, etc.)
- Table support
- Media embedding (images, videos)
- Custom fonts and sizes
- Smart paste
- Clean HTML export
- Read-only viewer mode

The editor is implemented as a Flutter widget that embeds Quill.js within an iframe. Communication between Flutter and the JavaScript world is handled via a message-passing bridge.

## 2. Tech Stack

- **Frontend Framework:** [Flutter](https://flutter.dev) (for Web)
- **Rich Text Editor:** [Quill.js](https://quilljs.com/) v2.0
- **Language:** [Dart](https://dart.dev)
- **Package Manager:** [pub](https://pub.dev)
- **JavaScript Interop:** `dart:js` and `dart:html` for communication between Dart and JavaScript.

## 3. Project Structure

The project is a Flutter package with an accompanying example application.

```
.
├── lib/                      # Main package source code
│   ├── quill_web_editor.dart # Main export file
│   └── src/
│       ├── core/             # Core logic, constants, and theme
│       ├── services/         # Helper services (e.g., DocumentService)
│       └── widgets/          # Flutter widgets (the editor, UI components)
├── web/                      # The core Quill.js HTML, CSS, and JS files
│   ├── quill_editor.html     # The main editor page loaded in the iframe
│   ├── quill_viewer.html     # The read-only viewer page
│   ├── js/                   # JavaScript files for Quill setup and interop
│   └── styles/               # CSS for the editor
├── example/                  # An example Flutter application demonstrating the package
│   ├── lib/main.dart         # Entry point for the example app
│   └── web/                  # Web-specific files for the example app
├── test/                     # Unit and widget tests for the package
└── pubspec.yaml              # Package definition, dependencies
```

## 4. How to Build and Run

To run the example application:

1.  Navigate to the `example` directory:
    ```bash
    cd example
    ```
2.  Get dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app in Chrome:
    ```bash
    flutter run -d chrome
    ```

## 5. Testing

The project has a suite of tests in the `test/` directory. To run the tests:

```bash
flutter test
```

The tests use pre-downloaded Google Fonts, which are located in `test/fonts/` and configured in `test/flutter_test_config.dart`.

## 6. Deployment

The package is designed to be used as a dependency in other Flutter web projects. The `web/` directory of this package contains the necessary HTML, JS, and CSS files that need to be served alongside the main Flutter application.

The `package_deployment.sh` script automates the process of copying these assets into a consumer project.

For more detailed instructions, see `docs/DEPLOYMENT.md`.

## 7. Coding Style and Conventions

The project follows the standard Dart and Flutter style guides. The specific linting rules are defined in `analysis_options.yaml`.

Key points:
- Prefer `const` for constructors and variables where possible.
- Use `final` for variables that are not reassigned.
- Follow the linter rules enforced by the CI.

## 8. Key Files for Understanding the Project

When trying to understand the project, start with these files:

- **`lib/src/widgets/quill_editor_widget.dart`**: The main Flutter widget that hosts the editor. This is the primary entry point for understanding the Flutter side of the implementation.
- **`web/quill_editor.html`**: The HTML file that is loaded into the iframe. It sets up the Quill.js editor.
- **`web/js/quill-setup.js`**: The JavaScript file that initializes Quill.js and sets up the communication bridge with Flutter.
- **`web/js/flutter-bridge.js`**: The JavaScript file that handles message passing between JavaScript and Dart.
- **`README.md`**: Provides a high-level overview and API reference.
- **`docs/ARCHITECTURE.md`**: For a deeper dive into the architecture.
