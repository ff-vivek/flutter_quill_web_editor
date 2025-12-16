/**
 * Quill Setup
 * ===========
 * Quill editor initialization and registration
 */

import { FONT_WHITELIST, SIZE_WHITELIST, TOOLBAR_OPTIONS } from './config.js';
import { rgbToHex, mapFontFamily, mapFontSize } from './utils.js';

/**
 * Register custom formats and modules with Quill
 * @param {Object} Quill - Quill constructor
 * @param {Object} QuillTableBetter - Table Better module
 */
export function registerQuillModules(Quill, QuillTableBetter) {
  // Register Table Better module
  Quill.register({
    'modules/table-better': QuillTableBetter
  }, true);

  // Register custom fonts
  const Font = Quill.import('formats/font');
  Font.whitelist = FONT_WHITELIST;
  Quill.register(Font, true);

  // Register custom sizes
  const Size = Quill.import('formats/size');
  Size.whitelist = SIZE_WHITELIST;
  Quill.register(Size, true);
}

/**
 * Create clipboard matchers for paste handling
 * @param {Object} Quill - Quill constructor
 * @returns {Array} Array of clipboard matchers
 */
export function createClipboardMatchers(Quill) {
  const Delta = Quill.import('delta');
  
  return [
    // Match any element with inline styles
    [Node.ELEMENT_NODE, function(node, delta) {
      const style = node.style;
      const formats = {};
      
      // Parse font-family
      if (style.fontFamily) {
        const font = mapFontFamily(style.fontFamily);
        if (font) formats.font = font;
      }
      
      // Parse font-size
      if (style.fontSize) {
        const size = mapFontSize(style.fontSize);
        if (size) formats.size = size;
      }
      
      // Parse color - normalize to hex
      if (style.color) {
        const hexColor = rgbToHex(style.color);
        if (hexColor) formats.color = hexColor;
      }
      
      // Parse background-color - normalize to hex
      if (style.backgroundColor) {
        const hexBg = rgbToHex(style.backgroundColor);
        if (hexBg) formats.background = hexBg;
      }
      
      // Parse font-weight (bold)
      if (style.fontWeight) {
        const weight = style.fontWeight.toString().toLowerCase();
        if (weight === 'bold' || weight === '700' || weight === '600' || weight === '800' || weight === '900') {
          formats.bold = true;
        }
      }
      
      // Parse font-style (italic)
      if (style.fontStyle === 'italic') {
        formats.italic = true;
      }
      
      // Parse text-decoration (underline, strikethrough)
      if (style.textDecoration) {
        const decoration = style.textDecoration.toLowerCase();
        if (decoration.includes('underline')) formats.underline = true;
        if (decoration.includes('line-through')) formats.strike = true;
      }
      
      // Parse text-align
      if (style.textAlign && style.textAlign !== 'start' && style.textAlign !== 'left') {
        formats.align = style.textAlign;
      }
      
      // Apply formats to all ops in the delta
      if (Object.keys(formats).length > 0) {
        return delta.compose(new Delta().retain(delta.length(), formats));
      }
      
      return delta;
    }],
    
    // Match <font> tags (legacy HTML)
    ['FONT', function(node, delta) {
      const formats = {};
      
      // Handle color attribute - normalize to hex
      if (node.color) {
        let color = node.color;
        if (!color.startsWith('#') && !color.startsWith('rgb')) {
          if (/^[0-9a-fA-F]{6}$/.test(color)) {
            color = '#' + color;
          }
        }
        formats.color = color;
      }
      
      // Handle face attribute (font family)
      if (node.face) {
        const font = mapFontFamily(node.face);
        if (font) formats.font = font;
      }
      
      // Handle size attribute (1-7)
      if (node.size) {
        const size = parseInt(node.size);
        if (size <= 2) formats.size = 'small';
        else if (size >= 5) formats.size = 'large';
        else if (size >= 6) formats.size = 'huge';
      }
      
      if (Object.keys(formats).length > 0) {
        return delta.compose(new Delta().retain(delta.length(), formats));
      }
      return delta;
    }],
    
    // Match <span> with class-based fonts
    ['SPAN', function(node, delta) {
      const formats = {};
      const className = node.className || '';
      
      // Check for ql-font-* classes
      const fontMatch = className.match(/ql-font-(\S+)/);
      if (fontMatch) {
        formats.font = fontMatch[1];
      }
      
      // Check for ql-size-* classes
      const sizeMatch = className.match(/ql-size-(\S+)/);
      if (sizeMatch) {
        formats.size = sizeMatch[1];
      }
      
      if (Object.keys(formats).length > 0) {
        return delta.compose(new Delta().retain(delta.length(), formats));
      }
      return delta;
    }],
    
    // Match <td> table cells with fonts/formatting
    ['TD', createCellMatcher(Quill)],
    
    // Match <th> table headers with fonts/formatting
    ['TH', createCellMatcher(Quill)]
  ];
}

/**
 * Create a cell matcher for TD/TH elements
 * @param {Object} Quill - Quill constructor
 * @returns {Function} Matcher function
 */
function createCellMatcher(Quill) {
  const Delta = Quill.import('delta');
  
  return function(node, delta) {
    const formats = {};
    const className = node.className || '';
    const style = node.style;
    
    // Check for ql-font-* classes
    const fontMatch = className.match(/ql-font-(\S+)/);
    if (fontMatch) {
      formats.font = fontMatch[1];
    }
    
    // Check for ql-size-* classes
    const sizeMatch = className.match(/ql-size-(\S+)/);
    if (sizeMatch) {
      formats.size = sizeMatch[1];
    }
    
    // Parse inline font-family
    if (style.fontFamily) {
      const font = mapFontFamily(style.fontFamily);
      if (font) formats.font = font;
    }
    
    // Parse inline font-size
    if (style.fontSize) {
      const size = mapFontSize(style.fontSize);
      if (size) formats.size = size;
    }
    
    // Parse inline color
    if (style.color) {
      const hexColor = rgbToHex(style.color);
      if (hexColor) formats.color = hexColor;
    }
    
    // Parse inline background color
    if (style.backgroundColor) {
      const hexBg = rgbToHex(style.backgroundColor);
      if (hexBg) formats.background = hexBg;
    }
    
    if (Object.keys(formats).length > 0) {
      return delta.compose(new Delta().retain(delta.length(), formats));
    }
    return delta;
  };
}

/**
 * Initialize Quill editor with all modules and configurations
 * @param {Object} Quill - Quill constructor
 * @param {Object} QuillTableBetter - Table Better module
 * @param {string} selector - Editor container selector
 * @returns {Object} Quill editor instance
 */
export function initializeQuill(Quill, QuillTableBetter, selector = '#editor') {
  // Register modules
  registerQuillModules(Quill, QuillTableBetter);
  
  // Create clipboard matchers
  const clipboardMatchers = createClipboardMatchers(Quill);
  
  // Initialize Quill
  const editor = new Quill(selector, {
    theme: 'snow',
    placeholder: 'Start writing your story...',
    modules: {
      toolbar: TOOLBAR_OPTIONS,
      table: false,
      'table-better': {
        language: 'en_US',
        menus: ['column', 'row', 'merge', 'table', 'cell', 'wrap', 'copy', 'delete'],
        toolbarTable: true
      },
      keyboard: {
        bindings: QuillTableBetter.keyboardBindings
      },
      clipboard: {
        matchers: clipboardMatchers
      },
      history: {
        delay: 1000,
        maxStack: 100,
        userOnly: true
      }
    }
  });
  
  return editor;
}

