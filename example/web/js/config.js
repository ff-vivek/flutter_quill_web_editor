/**
 * Configuration
 * =============
 * Shared configuration for Quill editor
 */

// Font whitelist for Quill
export const FONT_WHITELIST = [
  'roboto', 
  'open-sans', 
  'lato', 
  'montserrat', 
  'source-code', 
  'crimson', 
  'dm-sans'
];

// Size whitelist for Quill
export const SIZE_WHITELIST = ['small', false, 'large', 'huge'];

// Font family mapping - maps common fonts to Quill font classes
export const FONT_FAMILY_MAP = {
  // Direct mappings
  'roboto': 'roboto',
  'open sans': 'open-sans',
  'opensans': 'open-sans',
  'lato': 'lato',
  'montserrat': 'montserrat',
  'source code pro': 'source-code',
  'sourcecodepro': 'source-code',
  'crimson pro': 'crimson',
  'crimsonpro': 'crimson',
  'crimson text': 'crimson',
  'dm sans': 'dm-sans',
  'dmsans': 'dm-sans',
  // Common fonts to map
  'arial': 'roboto',
  'helvetica': 'roboto',
  'verdana': 'open-sans',
  'tahoma': 'open-sans',
  'trebuchet ms': 'montserrat',
  'georgia': 'crimson',
  'times': 'crimson',
  'times new roman': 'crimson',
  'courier': 'source-code',
  'courier new': 'source-code',
  'consolas': 'source-code',
  'monaco': 'source-code',
  'menlo': 'source-code'
};

// Toolbar configuration
export const TOOLBAR_OPTIONS = {
  container: [
    // Text structure - Headers
    [{ 'header': [1, 2, 3, 4, 5, 6, false] }],
    
    // Font family
    [{ 'font': ['', ...FONT_WHITELIST] }],
    
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

