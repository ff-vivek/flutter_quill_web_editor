#!/bin/bash

# Package Deployment Script for Quill Web Editor
# This script packages all required files for CDN deployment
# Usage: ./package_deployment.sh [output_filename]
#
# Version: 1.1.0
# Updated: 2025-12-23

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (root of Flutter project)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_NAME="${1:-quill-editor-deployment}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
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

# ============================================================
# Step 1: Detect project type and find pubspec.yaml
# ============================================================

PUBSPEC_FILE=""
BUILD_DIR=""
PROJECT_TYPE=""

# Check if we're in the package root (has lib/quill_web_editor.dart)
if [ -f "${SCRIPT_DIR}/lib/quill_web_editor.dart" ]; then
    PROJECT_TYPE="package"
    PUBSPEC_FILE="${SCRIPT_DIR}/pubspec.yaml"
    
    # For package, check example/build/web first
    if [ -d "${SCRIPT_DIR}/example/build/web" ]; then
        BUILD_DIR="${SCRIPT_DIR}/example/build/web"
    elif [ -d "${SCRIPT_DIR}/build/web" ]; then
        BUILD_DIR="${SCRIPT_DIR}/build/web"
    fi
    
    echo -e "${BLUE}📋 Project Type: Quill Web Editor Package${NC}"
elif [ -f "${SCRIPT_DIR}/pubspec.yaml" ]; then
    PROJECT_TYPE="flutter_app"
    PUBSPEC_FILE="${SCRIPT_DIR}/pubspec.yaml"
    BUILD_DIR="${SCRIPT_DIR}/build/web"
    echo -e "${BLUE}📋 Project Type: Flutter Application${NC}"
else
    echo -e "${RED}❌ Error: pubspec.yaml not found!${NC}"
    echo ""
    echo "Please run this script from the root of your Flutter project"
    echo "(where pubspec.yaml is located)."
    exit 1
fi

echo -e "${GREEN}✓${NC} pubspec.yaml found: ${PUBSPEC_FILE}"

# ============================================================
# Step 2: Extract version from pubspec.yaml
# ============================================================

VERSION=$(grep "^version:" "${PUBSPEC_FILE}" | sed 's/version: //' | tr -d '[:space:]')
if [ -z "$VERSION" ]; then
    VERSION="unknown"
    echo -e "${YELLOW}⚠ Warning: Could not extract version from pubspec.yaml${NC}"
else
    echo -e "${GREEN}✓${NC} Version: ${VERSION}"
fi

ZIP_FILE="${SCRIPT_DIR}/${OUTPUT_NAME}_v${VERSION}_${TIMESTAMP}.zip"

# ============================================================
# Step 3: Verify build directory exists
# ============================================================

if [ -z "$BUILD_DIR" ] || [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}❌ Error: Build directory not found!${NC}"
    echo ""
    if [ "$PROJECT_TYPE" == "package" ]; then
        echo "For the quill_web_editor package, run:"
        echo "  cd example && flutter build web && cd .."
    else
        echo "Please run 'flutter build web' first:"
        echo "  flutter build web"
    fi
    exit 1
fi

echo -e "${GREEN}✓${NC} Build directory: ${BUILD_DIR}"
echo ""

# ============================================================
# Step 4: Check for required files
# ============================================================

echo "🔍 Checking required files..."

# Core HTML files (always required)
CORE_FILES=(
    "quill_editor.html"
    "quill_viewer.html"
)

# Package assets (required for standalone deployment)
PACKAGE_ASSETS=(
    "assets/packages/quill_web_editor/web/js/commands.js"
    "assets/packages/quill_web_editor/web/js/flutter-bridge.js"
    "assets/packages/quill_web_editor/web/js/quill-setup.js"
    "assets/packages/quill_web_editor/web/js/config.js"
    "assets/packages/quill_web_editor/web/styles/base.css"
    "assets/packages/quill_web_editor/web/styles/quill-theme.css"
)

MISSING_CORE=()
MISSING_ASSETS=()

# Check core files
for file in "${CORE_FILES[@]}"; do
    if [ ! -f "${BUILD_DIR}/${file}" ]; then
        MISSING_CORE+=("$file")
    fi
done

# Check package assets
for file in "${PACKAGE_ASSETS[@]}"; do
    if [ ! -f "${BUILD_DIR}/${file}" ]; then
        MISSING_ASSETS+=("$file")
    fi
done

if [ ${#MISSING_CORE[@]} -ne 0 ]; then
    echo -e "${RED}❌ Error: Missing core files:${NC}"
    for file in "${MISSING_CORE[@]}"; do
        echo -e "${RED}   - ${file}${NC}"
    done
    exit 1
fi

if [ ${#MISSING_ASSETS[@]} -ne 0 ]; then
    echo -e "${YELLOW}⚠ Warning: Some package assets missing (may be optional):${NC}"
    for file in "${MISSING_ASSETS[@]}"; do
        echo -e "${YELLOW}   - ${file}${NC}"
    done
    echo ""
fi

echo -e "${GREEN}✓${NC} Core files verified"
echo ""

# ============================================================
# Step 5: Create deployment directory structure
# ============================================================

DEPLOY_DIR="${TEMP_DIR}/quill-editor"
mkdir -p "${DEPLOY_DIR}"

echo "📁 Creating deployment structure..."
echo ""

# Copy HTML files
echo "  📄 Copying HTML files..."
cp "${BUILD_DIR}/quill_editor.html" "${DEPLOY_DIR}/"
cp "${BUILD_DIR}/quill_viewer.html" "${DEPLOY_DIR}/"

# Copy JavaScript override files (if they exist)
echo "  📜 Copying JavaScript files..."
mkdir -p "${DEPLOY_DIR}/js"
if [ -d "${BUILD_DIR}/js" ]; then
    JS_FILES=$(find "${BUILD_DIR}/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$JS_FILES" -gt 0 ]; then
        cp "${BUILD_DIR}/js/"*.js "${DEPLOY_DIR}/js/" 2>/dev/null || true
        echo -e "     ${GREEN}✓${NC} Copied ${JS_FILES} JavaScript override files"
    fi
else
    echo -e "     ${YELLOW}⚠${NC} No js/ directory found (optional)"
fi

# Copy custom styles (if they exist)
echo "  🎨 Copying style files..."
mkdir -p "${DEPLOY_DIR}/styles"
if [ -d "${BUILD_DIR}/styles" ]; then
    CSS_FILES=$(find "${BUILD_DIR}/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CSS_FILES" -gt 0 ]; then
        cp "${BUILD_DIR}/styles/"*.css "${DEPLOY_DIR}/styles/" 2>/dev/null || true
        echo -e "     ${GREEN}✓${NC} Copied ${CSS_FILES} custom CSS files"
    fi
else
    echo -e "     ${YELLOW}⚠${NC} No styles/ directory found (optional)"
fi

# Copy package assets (maintaining folder structure)
echo "  📦 Copying package assets..."
if [ -d "${BUILD_DIR}/assets/packages/quill_web_editor/web" ]; then
    mkdir -p "${DEPLOY_DIR}/assets/packages/quill_web_editor/web"
    cp -r "${BUILD_DIR}/assets/packages/quill_web_editor/web/"* "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/" 2>/dev/null || true
    
    PKG_JS=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
    PKG_CSS=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "     ${GREEN}✓${NC} Copied ${PKG_JS} package JS files, ${PKG_CSS} package CSS files"
else
    echo -e "${RED}❌ Error: Package assets directory not found${NC}"
    echo "   Expected: ${BUILD_DIR}/assets/packages/quill_web_editor/web"
    exit 1
fi

# Copy fonts (optional - if they exist)
FONT_COUNT=0
if [ -d "${BUILD_DIR}/assets/assets/fonts" ]; then
    if ls "${BUILD_DIR}/assets/assets/fonts"/*.ttf 1> /dev/null 2>&1; then
        echo "  🔤 Copying font files..."
        mkdir -p "${DEPLOY_DIR}/fonts"
        cp "${BUILD_DIR}/assets/assets/fonts"/*.ttf "${DEPLOY_DIR}/fonts/" 2>/dev/null || true
        FONT_COUNT=$(find "${DEPLOY_DIR}/fonts" -name "*.ttf" 2>/dev/null | wc -l | tr -d ' ')
        echo -e "     ${GREEN}✓${NC} Copied ${FONT_COUNT} font files"
    fi
fi

echo ""

# ============================================================
# Step 6: Create version info file
# ============================================================

echo "  📝 Creating version info..."
cat > "${DEPLOY_DIR}/VERSION.txt" << EOF
Quill Web Editor Deployment Package
====================================
Version: ${VERSION}
Built: $(date)
Project Type: ${PROJECT_TYPE}
Source: ${BUILD_DIR}

Files included:
- quill_editor.html
- quill_viewer.html
- js/ (custom override files)
- styles/ (custom CSS files)
- assets/packages/quill_web_editor/web/ (package assets)
$([ "$FONT_COUNT" -gt 0 ] && echo "- fonts/ (font files)")

For deployment instructions, see:
https://github.com/ff-vivek/flutter_quill_web_editor/blob/main/doc/DEPLOYMENT.md
EOF

echo -e "     ${GREEN}✓${NC} Created VERSION.txt"
echo ""

# ============================================================
# Step 7: Create zip file
# ============================================================

echo "🗜️  Creating zip archive..."
cd "${TEMP_DIR}"
zip -r "${ZIP_FILE}" quill-editor/ -q
cd "${SCRIPT_DIR}"

# Get file size
ZIP_SIZE=$(du -h "${ZIP_FILE}" | cut -f1)

echo -e "${GREEN}✓${NC} Zip file created: ${ZIP_FILE}"
echo -e "${GREEN}✓${NC} Size: ${ZIP_SIZE}"
echo ""

# ============================================================
# Step 8: Display summary
# ============================================================

# Count files
JS_COUNT=$(find "${DEPLOY_DIR}/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
CSS_COUNT=$(find "${DEPLOY_DIR}/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')
PACKAGE_JS_COUNT=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/js" -name "*.js" 2>/dev/null | wc -l | tr -d ' ')
PACKAGE_CSS_COUNT=$(find "${DEPLOY_DIR}/assets/packages/quill_web_editor/web/styles" -name "*.css" 2>/dev/null | wc -l | tr -d ' ')

echo "═══════════════════════════════════════════════════════"
echo -e "${GREEN}📊 Deployment Package Summary${NC}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "  Version:              ${VERSION}"
echo "  HTML files:           2"
echo "  Custom JS files:      ${JS_COUNT}"
echo "  Custom CSS files:     ${CSS_COUNT}"
echo "  Package JS files:     ${PACKAGE_JS_COUNT}"
echo "  Package CSS files:    ${PACKAGE_CSS_COUNT}"
if [ "$FONT_COUNT" -gt 0 ]; then
    echo "  Font files:           ${FONT_COUNT}"
fi
echo ""

# Display structure
echo "📂 Deployment Structure:"
echo ""
if command -v tree &> /dev/null; then
    tree -L 5 "${DEPLOY_DIR}" --noreport
else
    find "${DEPLOY_DIR}" -print | sed -e 's;[^/]*/;  |-- ;g;s;--|;  |;g' | tail -n +2
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Deployment package created successfully!${NC}"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "📁 Output: ${ZIP_FILE}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Extract the zip file to your CDN/hosting location"
echo "  2. Maintain the folder structure as shown above"
echo "  3. Update your Flutter app with the hosted URLs:"
echo ""
echo -e "${YELLOW}     QuillEditorWidget(${NC}"
echo -e "${YELLOW}       editorHtmlPath: 'https://your-cdn.com/quill-editor/quill_editor.html',${NC}"
echo -e "${YELLOW}       viewerHtmlPath: 'https://your-cdn.com/quill-editor/quill_viewer.html',${NC}"
echo -e "${YELLOW}     )${NC}"
echo ""
echo "For detailed instructions, see: doc/DEPLOYMENT.md"
echo ""
