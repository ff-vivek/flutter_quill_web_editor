/**
 * Configuration
 * =============
 * Shared configuration for Quill editor
 */

// Font whitelist for Quill (package defaults)
// Custom fonts can be added via config-override.js in your app
export const FONT_WHITELIST = [
  'sans-serif',
  'roboto',
  'merriweather'
];

// Size whitelist for Quill
export const SIZE_WHITELIST = ['small', false, 'large', 'huge'];

// Font family mapping - maps common fonts to Quill font classes
// Custom mappings can be extended in config-override.js
export const FONT_FAMILY_MAP = {
  // Direct mappings
  'sans-serif': 'sans-serif',
  'roboto': 'roboto',
  'merriweather': 'merriweather',
  // Common sans-serif fonts
  'arial': 'sans-serif',
  'helvetica': 'sans-serif',
  'verdana': 'sans-serif',
  'tahoma': 'sans-serif',
  'trebuchet ms': 'sans-serif',
  // Serif fonts map to Merriweather
  'georgia': 'merriweather',
  'times': 'merriweather',
  'times new roman': 'merriweather',
  'palatino': 'merriweather',
  'garamond': 'merriweather',
  // Monospace fonts (keep as roboto for now)
  'courier': 'roboto',
  'courier new': 'roboto',
  'consolas': 'roboto',
  'monaco': 'roboto',
  'menlo': 'roboto'
};

// Toolbar configuration
export const TOOLBAR_OPTIONS = {
  container: [
    // Text structure - Headers
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    
    // Font family
    [{ 'font': FONT_WHITELIST }],
    
    // Font size
    [{ 'size': ['small', false, 'large', 'huge'] }],
    
    // Text formatting
    ['bold', 'italic', 'underline', 'strike'],
    
    // Subscript / Superscript
    [{ 'script': 'sub' }, { 'script': 'super' }],
    
    // Colors
    [{ 'color': [] }, { 'background': [] }],
    
    // Lists (ordered, bullet, checklist)
    [{ 'list': 'ordered' }, { 'list': 'bullet' }, { 'list': 'check' }],
    
    // Indentation
    [{ 'indent': '-1' }, { 'indent': '+1' }],
    
    // Text alignment
    [{ 'align': [] }],
    
    // Text direction (LTR/RTL)
    [{ 'direction': 'rtl' }],
    
    // Block formats
    ['blockquote', 'code-block'],
    
    // Media and embeds
    ['link', 'image', 'video'],
    
    // Table
    ['table-better'],
    
    // Clear formatting
    ['clean']
  ]
};

// Content change throttle (ms)
export const CONTENT_CHANGE_THROTTLE = 200;

// Media resize constraints
export const MEDIA_MIN_SIZE = 50;
export const TABLE_MIN_WIDTH = 100;

// Zoom constraints
export const ZOOM_MIN = 0.5;
export const ZOOM_MAX = 3.0;

