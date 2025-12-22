#!/bin/bash

# Rigorous package publishing script for pub.dev
# This script performs extensive checks before publishing.
#
# PREREQUISITES:
# 1. You must be authenticated with `dart pub token add` or similar.
# 2. For advanced security scanning, install trivy: https://github.com/aquasecurity/trivy
#
# USAGE:
# ./publish.sh

# --- Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e

# Default values
APPLY_FORMATTING=false

# --- Parse Command-Line Arguments ---
for arg in "$@"
do
    case $arg in
        --apply)
        APPLY_FORMATTING=true
        shift # Remove --apply from processing
        ;;
    esac
done


# --- Helper Functions ---
# Pretty printing
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}$1${NC}"
}

warn() {
    echo -e "${YELLOW}$1${NC}"
}

error() {
    echo -e "${RED}$1${NC}"
}

# --- Main Script ---
info "Starting pre-publication checks for your package..."

# 1. Extract Version
PACKAGE_VERSION=$(grep 'version:' pubspec.yaml | awk '{print $2}')
info "Package version found: $PACKAGE_VERSION"
echo

# 2. Clean Project
info "[1/7] Cleaning project workspace..."
flutter clean
echo

# 3. Get Dependencies
info "[2/7] Getting dependencies..."
flutter pub get
echo

# 4. Format Code (Check or Apply)
if [ "$APPLY_FORMATTING" = true ]; then
    info "[3/7] Applying code formatting..."
    dart format .
    info "Formatting applied."
else
    info "[3/7] Checking code formatting..."
    dart format --output=none --set-exit-if-changed .
    info "Formatting is correct."
fi
echo

# 5. Static Analysis
info "[4/7] Running static analysis..."
flutter analyze
info "Analysis complete, no issues found."
echo

# 6. Run Tests
info "[5/7] Running tests..."
flutter test
info "All tests passed."
echo

# 8. Publish Dry Run
info "[6/7] Running publish dry-run..."
dart pub publish --dry-run
info "Dry run successful. The package is ready for publishing."
echo

# 9. Final Confirmation
info "[7/7] All checks passed. Ready to publish version $PACKAGE_VERSION to pub.dev."
warn "This action is irreversible."

read -p "Do you want to proceed with publishing? (y/N) " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    info "User confirmed. Publishing package..."
    dart pub publish
    info "Package published successfully!"
else
    error "Publishing cancelled by user."
    exit 1
fi

exit 0
