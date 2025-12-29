/**
 * Custom Configuration Override
 * =============================
 * 
 * This file extends the package's config.js to add custom configurations.
 * Following Flutter web best practices, we only override what we need to customize.
 * 
 * Customizations:
 * - Added Mulish font to font whitelist
 * - Extended font family mapping to include Mulish
 * 
 * Last updated: 2025-12-17
 */

// Import package configuration
import { 
  FONT_WHITELIST as PACKAGE_FONT_WHITELIST,
  TOOLBAR_OPTIONS as PACKAGE_TOOLBAR_OPTIONS,
  FONT_FAMILY_MAP as PACKAGE_FONT_FAMILY_MAP
} from '/assets/packages/quill_web_editor/web/js/config.js';

// Extend font whitelist with Mulish (add it first so it appears first in dropdown)
export const FONT_WHITELIST = [
  'mulish',  // Custom font added
  ...PACKAGE_FONT_WHITELIST
];

// Extend font family mapping to include Mulish
export const FONT_FAMILY_MAP = {
  ...PACKAGE_FONT_FAMILY_MAP,
  // Mulish mappings
  'mulish': 'mulish',
  'Mulish': 'mulish',
};

// Extend toolbar options with custom font whitelist
export const TOOLBAR_OPTIONS = {
  ...PACKAGE_TOOLBAR_OPTIONS,
  container: PACKAGE_TOOLBAR_OPTIONS.container.map(section => {
    // Replace font section with our extended whitelist
    if (Array.isArray(section) && section.length > 0 && 
        typeof section[0] === 'object' && section[0].font) {
      return [{ 'font': FONT_WHITELIST }];
    }
    return section;
  })
};

