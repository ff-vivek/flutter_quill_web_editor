#!/bin/bash

# Package Deployment Script for Quill Web Editor
# This script packages all required files for CDN deployment
# Usage: ./package_deployment.sh [output_filename]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory (root of Flutter project)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build/web"
OUTPUT_NAME="${1:-quill-editor-deployment}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ZIP_FILE="${SCRIPT_DIR}/${OUTPUT_NAME}_${TIMESTAMP}.zip"
TEMP_DIR=$(mktemp -d)

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

echo -e "${GREEN}📦 Quill Web Editor Deployment Packager${NC}"
echo "=========================================="
echo ""

# Check 1: Verify pubspec.yaml exists (ensures we're at Flutter project root)
PUBSPEC_FILE="${SCRIPT_DIR}/pubspec.yaml"
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found!${NC}"
    echo -e "${RED}   Expected: ${PUBSPEC_FILE}${NC}"
    echo ""
    echo "Please run this script from the root of your Flutter project"
    echo "(where pubspec.yaml is located)."
    exit 1
fi

echo -e "${GREEN}✓${NC} pubspec.yaml found"

# Check 2: Verify build folder exists
BUILD_FOLDER="${SCRIPT_DIR}/build"
if [ ! -d "$BUILD_FOLDER" ]; then
    echo -e "${RED}❌ Error: Build folder not found!${NC}"
    echo -e "${RED}   Expected: ${BUILD_FOLDER}${NC}"
    echo ""
    echo "Please run 'flutter build web' first:"
    echo "  flutter build web"
    exit 1
fi

echo -e "${GREEN}✓${NC} Build folder found: ${BUILD_FOLDER}"

# Check 3: Verify build/web directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}❌ Error: Build web directory not found!${NC}"
    echo -e "${RED}   Expected: ${BUILD_DIR}${NC}"
    echo ""
    echo "Please run 'flutter build web' first:"
    echo "  flutter build web"
    exit 1
fi

echo -e "${GREEN}✓${NC} Build web directory found: ${BUILD_DIR}"
echo ""

# Check for required files
REQUIRED_FILES=(
    "quill_editor.html"
    "quill_viewer.html"
    "js/quill-setup-override.js"
    "js/clipboard-override.js"
    "js/config-override.js"
    "js/utils-override.js"
    "styles/mulish-font.css"
    "assets/packages/quill_web_editor/web/js/commands.js"
    "assets/packages/quill_web_editor/web/js/flutter-bridge.js"
    "assets/packages/quill_web_editor/web/styles/base.css"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${BUILD_DIR}/${file}" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    echo -e "${RED}❌ Error: Missing required files:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo -e "${RED}   - ${file}${NC}"
    done
    echo ""
    echo "Please ensure the build is complete and all files are present."
    exit 1
fi

echo -e "${GREEN}✓${NC} All required files found"
echo ""

# Create deployment directory structure
DEPLOY_DIR="${TEMP_DIR}/quill-editor"
mkdir -p "${DEPLOY_DIR}"

echo "📁 Creating deployment structure..."
echo ""

# Copy HTML files
echo "  Copying HTML files..."
cp "${BUILD_DIR}/quill_editor.html" "${DEPLOY_DIR}/"
cp "${BUILD_DIR}/quill_viewer.html" "${DEPLOY_DIR}/"

# Copy JavaScript override files
echo "  Copying JavaScript override files..."
mkdir -p "${DEPLOY_DIR}/js"
if [ -d "${BUILD_DIR}/js" ]; then
    cp "${BUILD_DIR}/js/"*.js "${DEPLOY_DIR}/js/" 2>/dev/null || true
else
    echo -e "${YELLOW}⚠ Warning: js/ directory not found${NC}"
fi

# Copy custom styles
echo "  Copying custom styles..."
mkdir -p "${DEPLOY_DIR}/styles"
if [ -d "${BUILD_DIR}/styles" ]; then
    cp "${BUILD_DIR}/styles/"*.css "${DEPLOY_DIR}/styles/" 2>/dev/null || true
else
    echo -e "${YELLOW}⚠ Warning: styles/ directory not found${NC}"
fi

# Copy package assets (maintaining folder structure)
echo "  Copying package assets..."
mkdir -p "${DEPLOY_DIR}/assets/packages/quill_web_editor/web"
if [ -d "${BUILD_DIR}/assets/packages/quill_web_editor/web" ]; then
    cp -r "${BUILD_DIR}/assets/packages/quill_web_editor/web/"* "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/" 2>/dev/null || true
else
    echo -e "${RED}❌ Error: Package assets directory not found${NC}"
    exit 1
fi

# Copy fonts (optional - if they exist)
if [ -d "${BUILD_DIR}/assets/assets/fonts" ] && ls "${BUILD_DIR}/assets/assets/fonts"/Mulish-*.ttf 1> /dev/null 2>&1; then
    echo "  Copying font files..."
    mkdir -p "${DEPLOY_DIR}/fonts"
    cp "${BUILD_DIR}/assets/assets/fonts"/Mulish-*.ttf "${DEPLOY_DIR}/fonts/" 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}✓${NC} Files copied successfully"
echo ""

# Verify file counts
JS_COUNT=$(find "${DEPLOY_DIR}/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
CSS_COUNT=$(find "${DEPLOY_DIR}/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
PACKAGE_JS_COUNT=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
PACKAGE_CSS_COUNT=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
FONT_COUNT=$(find "${DEPLOY_DIR}/fonts" -name "*.ttf" 2>/dev/null | wc -l | tr -d ' ')

echo "📊 File Summary:"
echo "  HTML files: 2"
echo "  Custom JS files: ${JS_COUNT}"
echo "  Custom CSS files: ${CSS_COUNT}"
echo "  Package JS files: ${PACKAGE_JS_COUNT}"
echo "  Package CSS files: ${PACKAGE_CSS_COUNT}"
if [ "$FONT_COUNT" -gt 0 ]; then
    echo "  Font files: ${FONT_COUNT}"
fi
echo ""

# Create zip file
echo "🗜️  Creating zip archive..."
cd "${TEMP_DIR}"
zip -r "${ZIP_FILE}" quill-editor/ -q
cd "${SCRIPT_DIR}"

# Get file size
ZIP_SIZE=$(du -h "${ZIP_FILE}" | cut -f1)

echo -e "${GREEN}✓${NC} Zip file created: ${ZIP_FILE}"
echo -e "${GREEN}✓${NC} Size: ${ZIP_SIZE}"
echo ""

# Display structure
echo "📂 Deployment Structure:"
echo ""
if command -v tree &> /dev/null; then
    tree -L 4 "${DEPLOY_DIR}"
else
    find "${DEPLOY_DIR}" -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
fi
echo ""

echo -e "${GREEN}✅ Deployment package created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Extract the zip file to your CDN/hosting location"
echo "  2. Maintain the folder structure as shown above"
echo "  3. Update your Flutter app with the hosted URLs:"
echo "     editorHtmlPath: 'https://your-cdn.com/quill-editor/quill_editor.html'"
echo "     viewerHtmlPath: 'https://your-cdn.com/quill-editor/quill_viewer.html'"
echo ""
echo "For detailed instructions, see: docs/DEPLOYMENT.md"

