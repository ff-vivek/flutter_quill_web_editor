# Deployment Package Script

This script packages all required files for CDN deployment of the Quill Web Editor.

## Prerequisites

1. Build the example app first:
   ```bash
   cd example
   flutter build web
   cd ..
   ```

2. Ensure you're at the root of the Flutter project (where `pubspec.yaml` is located)

## Usage

### Basic Usage

```bash
./package_deployment.sh
```

This will create a zip file named `quill-editor-deployment_YYYYMMDD_HHMMSS.zip` in the project root.

### Custom Output Name

```bash
./package_deployment.sh my-custom-name
```

This will create `my-custom-name_YYYYMMDD_HHMMSS.zip`.

## What It Does

The script:

1. ✅ Validates that `example/build/web` directory exists
2. ✅ Checks for all required files
3. ✅ Creates a deployment package with the correct folder structure:
   ```
   quill-editor/
   ├── quill_editor.html
   ├── quill_viewer.html
   ├── js/
   │   ├── quill-setup-override.js
   │   ├── clipboard-override.js
   │   ├── config-override.js
   │   └── utils-override.js
   ├── styles/
   │   └── mulish-font.css
   ├── assets/
   │   └── packages/
   │       └── quill_web_editor/
   │           └── web/
   │               ├── js/        # 10 package JS files
   │               └── styles/    # 7 package CSS files
   └── fonts/                     # Optional (if fonts exist)
       └── Mulish-*.ttf
   ```
4. ✅ Creates a zip archive
5. ✅ Displays file summary and structure

## Error Handling

The script will exit with an error if:

- ❌ Build directory (`example/build/web`) doesn't exist
- ❌ Required files are missing
- ❌ File copy operations fail

## Output

The script creates a timestamped zip file containing all deployment files with the correct folder structure. You can extract this zip file directly to your CDN/hosting location.

## Example Output

```
📦 Quill Web Editor Deployment Packager
==========================================

✓ Build directory found: /path/to/example/build/web

✓ All required files found

📁 Creating deployment structure...

  Copying HTML files...
  Copying JavaScript override files...
  Copying custom styles...
  Copying package assets...
  Copying font files...

✓ Files copied successfully

📊 File Summary:
  HTML files: 2
  Custom JS files: 4
  Custom CSS files: 1
  Package JS files: 10
  Package CSS files: 7
  Font files: 18

🗜️  Creating zip archive...

✓ Zip file created: quill-editor-deployment_20250117_143022.zip
✓ Size: 2.3M

✅ Deployment package created successfully!
```

## Next Steps

After creating the package:

1. Extract the zip file to your CDN/hosting location
2. Maintain the exact folder structure
3. Update your Flutter app with hosted URLs:
   ```dart
   QuillEditorWidget(
     editorHtmlPath: 'https://your-cdn.com/quill-editor/quill_editor.html',
     viewerHtmlPath: 'https://your-cdn.com/quill-editor/quill_viewer.html',
   )
   ```

For detailed deployment instructions, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).


