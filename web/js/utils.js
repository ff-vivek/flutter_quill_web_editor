/**
 * Utility Functions
 * =================
 * Shared utilities for Quill editor
 */

import { FONT_FAMILY_MAP } from './config.js';

/**
 * Convert RGB/RGBA color to hex format
 * @param {string} rgb - RGB or RGBA color string
 * @returns {string|null} Hex color or null
 */
export function rgbToHex(rgb) {
  if (!rgb) return null;
  if (rgb.startsWith('#')) return rgb;
  
  const match = rgb.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
  if (match) {
    const r = parseInt(match[1]).toString(16).padStart(2, '0');
    const g = parseInt(match[2]).toString(16).padStart(2, '0');
    const b = parseInt(match[3]).toString(16).padStart(2, '0');
    return '#' + r + g + b;
  }
  return rgb;
}

/**
 * Normalize color to hex format for consistency
 * Handles named colors, rgb, rgba, and hex
 * @param {string} color - Color string in any format
 * @returns {string|null} Hex color or null
 */
export function normalizeColor(color) {
  if (!color) return null;
  color = color.trim();
  
  // Already hex
  if (color.startsWith('#')) return color;
  
  // Named colors - let browser convert
  const tempEl = document.createElement('div');
  tempEl.style.color = color;
  document.body.appendChild(tempEl);
  const computed = getComputedStyle(tempEl).color;
  document.body.removeChild(tempEl);
  
  return rgbToHex(computed);
}

/**
 * Map font family string to Quill font class
 * @param {string} fontFamily - CSS font-family value
 * @returns {string|false} Quill font class name or false for default
 */
export function mapFontFamily(fontFamily) {
  if (!fontFamily) return false;
  
  // Clean and normalize font family
  const fonts = fontFamily.toLowerCase()
    .split(',')
    .map(f => f.trim().replace(/['"]/g, ''));
  
  // Try to match each font in the stack
  for (const font of fonts) {
    if (FONT_FAMILY_MAP[font]) {
      return FONT_FAMILY_MAP[font];
    }
    // Try partial match
    for (const [key, value] of Object.entries(FONT_FAMILY_MAP)) {
      if (font.includes(key) || key.includes(font)) {
        return value;
      }
    }
  }
  
  return false; // default font
}

/**
 * Map font size to Quill size class
 * @param {string} size - CSS font-size value
 * @returns {string|false} Quill size class name or false for normal
 */
export function mapFontSize(size) {
  if (!size) return false;
  const sizeStr = size.toLowerCase().trim();
  
  // Handle px values
  let pxValue = null;
  if (sizeStr.endsWith('px')) {
    pxValue = parseFloat(sizeStr);
  } else if (sizeStr.endsWith('pt')) {
    pxValue = parseFloat(sizeStr) * 1.333; // pt to px
  } else if (sizeStr.endsWith('em')) {
    pxValue = parseFloat(sizeStr) * 16; // assuming base 16px
  } else if (sizeStr.endsWith('rem')) {
    pxValue = parseFloat(sizeStr) * 16;
  } else if (!isNaN(parseFloat(sizeStr))) {
    pxValue = parseFloat(sizeStr);
  }
  
  // Handle keyword sizes
  if (sizeStr === 'small' || sizeStr === 'x-small' || sizeStr === 'xx-small') return 'small';
  if (sizeStr === 'large' || sizeStr === 'x-large') return 'large';
  if (sizeStr === 'xx-large' || sizeStr === 'xxx-large') return 'huge';
  
  // Map px values to Quill sizes
  if (pxValue !== null) {
    if (pxValue <= 12) return 'small';
    if (pxValue <= 18) return false; // normal
    if (pxValue <= 24) return 'large';
    return 'huge';
  }
  
  return false; // normal size
}

/**
 * Pre-process HTML to convert inline styles to Quill classes
 * @param {string} html - HTML string to process
 * @returns {string} Processed HTML with Quill classes
 */
export function preprocessHtml(html) {
  console.log('[HTML Parsing] preprocessHtml - Input length:', html?.length || 0);
  console.log('[HTML Parsing] preprocessHtml - Input preview:', html?.substring(0, 200) || 'null');
  
  const parser = new DOMParser();
  const wrappedHtml = '<div>' + html + '</div>';
  console.log('[HTML Parsing] preprocessHtml - Wrapped HTML length:', wrappedHtml.length);
  
  const doc = parser.parseFromString(wrappedHtml, 'text/html');
  
  // Check for parsing errors
  const parserError = doc.querySelector('parsererror');
  if (parserError) {
    console.error('[HTML Parsing] preprocessHtml - Parser error:', parserError.textContent);
  }
  
  const container = doc.body.firstChild;
  if (!container) {
    console.error('[HTML Parsing] preprocessHtml - No container element found after parsing');
    return html;
  }
  
  console.log('[HTML Parsing] preprocessHtml - Container tag:', container.tagName);
  console.log('[HTML Parsing] preprocessHtml - Elements to process:', container.querySelectorAll('*').length);
  
  // Process all elements with inline styles
  container.querySelectorAll('*').forEach(el => {
    const style = el.style;
    const classes = [];
    let fontClass = null;
    let sizeClass = null;
    let colorStyle = null;
    let bgColorStyle = null;
    
    // Convert font-family to ql-font-* class
    if (style.fontFamily) {
      const font = mapFontFamily(style.fontFamily);
      if (font) {
        fontClass = 'ql-font-' + font;
        classes.push(fontClass);
        style.removeProperty('font-family');
      }
    }
    
    // Convert font-size to ql-size-* class
    if (style.fontSize) {
      const size = mapFontSize(style.fontSize);
      if (size) {
        sizeClass = 'ql-size-' + size;
        classes.push(sizeClass);
        style.removeProperty('font-size');
      }
    }
    
    // Normalize and preserve color
    if (style.color) {
      const normalizedColor = normalizeColor(style.color);
      if (normalizedColor) {
        colorStyle = normalizedColor;
        style.color = normalizedColor;
      }
    }
    
    // Normalize and preserve background color
    if (style.backgroundColor) {
      const normalizedBg = normalizeColor(style.backgroundColor);
      if (normalizedBg) {
        bgColorStyle = normalizedBg;
        style.backgroundColor = normalizedBg;
      }
    }
    
    // Add classes if any
    if (classes.length > 0) {
      el.className = (el.className ? el.className + ' ' : '') + classes.join(' ');
    }
    
    // Special handling for table cells (TD, TH) - wrap text content in span with formatting
    if ((el.tagName === 'TD' || el.tagName === 'TH') && (fontClass || sizeClass || colorStyle)) {
      const hasFormattedChildren = el.querySelector('span[class*="ql-font"], span[class*="ql-size"]');
      
      if (!hasFormattedChildren) {
        const wrapContent = (parent) => {
          const childNodes = Array.from(parent.childNodes);
          childNodes.forEach(child => {
            if (child.nodeType === Node.TEXT_NODE && child.textContent.trim()) {
              const span = doc.createElement('span');
              if (fontClass) span.classList.add(fontClass);
              if (sizeClass) span.classList.add(sizeClass);
              if (colorStyle) span.style.color = colorStyle;
              span.textContent = child.textContent;
              child.replaceWith(span);
            } else if (child.nodeType === Node.ELEMENT_NODE) {
              if (child.tagName === 'P' || child.tagName === 'DIV') {
                wrapContent(child);
              } else if (child.tagName === 'SPAN' && !child.className.includes('ql-font') && !child.className.includes('ql-size')) {
                if (fontClass && !child.classList.contains(fontClass)) child.classList.add(fontClass);
                if (sizeClass && !child.classList.contains(sizeClass)) child.classList.add(sizeClass);
                if (colorStyle && !child.style.color) child.style.color = colorStyle;
              }
            }
          });
        };
        wrapContent(el);
      }
    }
  });
  
  // Handle <font> tags - convert to spans with proper styling
  container.querySelectorAll('font').forEach(font => {
    const span = doc.createElement('span');
    span.innerHTML = font.innerHTML;
    
    // Copy color attribute
    if (font.color) {
      const normalizedColor = normalizeColor(font.color);
      if (normalizedColor) {
        span.style.color = normalizedColor;
      }
    }
    
    // Copy face attribute (font family)
    if (font.face) {
      const mappedFont = mapFontFamily(font.face);
      if (mappedFont) {
        span.classList.add('ql-font-' + mappedFont);
      }
    }
    
    // Copy size attribute
    if (font.size) {
      const size = parseInt(font.size);
      if (size <= 2) span.classList.add('ql-size-small');
      else if (size >= 5) span.classList.add('ql-size-large');
      else if (size >= 6) span.classList.add('ql-size-huge');
    }
    
    font.parentNode.replaceChild(span, font);
  });
  
  const processedHtml = container.innerHTML;
  console.log('[HTML Parsing] preprocessHtml - Output length:', processedHtml?.length || 0);
  console.log('[HTML Parsing] preprocessHtml - Output preview:', processedHtml?.substring(0, 200) || 'null');
  
  return processedHtml;
}

/**
 * Extract body content from full HTML document
 * @param {string} html - Full HTML document or fragment
 * @returns {string} Body content only
 */
export function extractBodyContent(html) {
  console.log('[HTML Parsing] extractBodyContent - Input length:', html?.length || 0);
  console.log('[HTML Parsing] extractBodyContent - Input preview:', html?.substring(0, 200) || 'null');
  
  if (html.includes('<!DOCTYPE') || html.includes('<html')) {
    console.log('[HTML Parsing] extractBodyContent - Detected full HTML document, parsing...');
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Check for parsing errors
    const parserError = doc.querySelector('parsererror');
    if (parserError) {
      console.error('[HTML Parsing] extractBodyContent - Parser error:', parserError.textContent);
    }
    
    const body = doc.body;
    if (body) {
      let bodyContent = body.innerHTML;
      
      // If body contains a single .ql-editor div, unwrap it to get just the content
      // This handles exported HTML documents that wrap content in <div class="ql-editor">
      const qlEditorDiv = body.querySelector('.ql-editor');
      if (qlEditorDiv && body.children.length === 1 && body.children[0] === qlEditorDiv) {
        console.log('[HTML Parsing] extractBodyContent - Found .ql-editor wrapper, unwrapping...');
        bodyContent = qlEditorDiv.innerHTML;
        console.log('[HTML Parsing] extractBodyContent - Unwrapped content length:', bodyContent?.length || 0);
      }
      
      console.log('[HTML Parsing] extractBodyContent - Extracted body content length:', bodyContent?.length || 0);
      console.log('[HTML Parsing] extractBodyContent - Body content preview:', bodyContent?.substring(0, 200) || 'null');
      return bodyContent;
    } else {
      console.warn('[HTML Parsing] extractBodyContent - No body element found');
    }
  } else {
    console.log('[HTML Parsing] extractBodyContent - Not a full HTML document, returning as-is');
  }
  return html;
}

/**
 * Clean HTML for saving by removing editor artifacts
 * This should be called before saving to database to prevent corrupted HTML
 * @param {string} html - HTML to clean
 * @returns {string} Cleaned HTML
 */
export function cleanHtmlForSave(html) {
  if (!html) return html;
  
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, 'text/html');
  
  // 1. Remove all <temporary> elements (quill-table-better internal artifacts)
  doc.querySelectorAll('temporary, .ql-table-temporary').forEach(el => {
    el.remove();
  });
  
  // 2. Remove empty tables (tables with no actual content - no tbody or only empty tbody)
  doc.querySelectorAll('table').forEach(table => {
    const tbody = table.querySelector('tbody');
    const hasRows = table.querySelector('tr');
    const hasCells = table.querySelector('td, th');
    
    // If table has no rows or cells, remove it entirely
    if (!hasRows || !hasCells) {
      console.log('[HTML Cleaning] Removing empty table');
      table.remove();
    }
  });
  
  // 3. Remove quill-table-better tool elements
  doc.querySelectorAll('[class*="ql-table-better-tool"], [class*="ql-table-better-col"], [class*="ql-table-better-row"], [class*="ql-table-better-corner"]').forEach(el => {
    el.remove();
  });
  
  // 4. Remove selection classes
  const selectionClasses = [
    'selected', 'ql-cell-selected', 'ql-table-selected', 
    'ql-cell-focused', 'ql-table-better-selected-td',
    'ql-table-better-selection-line', 'ql-table-better-selection-block'
  ];
  
  doc.querySelectorAll('*').forEach(el => {
    selectionClasses.forEach(cls => {
      el.classList.remove(cls);
    });
    
    // Remove any class containing 'select'
    const classesToRemove = [];
    el.classList.forEach(cls => {
      if (cls.includes('select')) {
        classesToRemove.push(cls);
      }
    });
    classesToRemove.forEach(cls => el.classList.remove(cls));
  });
  
  return doc.body.innerHTML;
}

/**
 * Clean HTML for preview by removing selection classes
 * @param {string} html - HTML to clean
 * @returns {string} Cleaned HTML
 */
export function cleanHtmlForPreview(html) {
  console.log('[HTML Parsing] cleanHtmlForPreview - Input length:', html?.length || 0);
  console.log('[HTML Parsing] cleanHtmlForPreview - Input preview:', html?.substring(0, 200) || 'null');
  
  const parser = new DOMParser();
  const doc = parser.parseFromString(html, 'text/html');
  
  // Check for parsing errors
  const parserError = doc.querySelector('parsererror');
  if (parserError) {
    console.error('[HTML Parsing] cleanHtmlForPreview - Parser error:', parserError.textContent);
  }
  
  console.log('[HTML Parsing] cleanHtmlForPreview - Elements to clean:', doc.querySelectorAll('*').length);
  
  // Remove <temporary> elements (quill-table-better internal artifacts)
  doc.querySelectorAll('temporary, .ql-table-temporary').forEach(el => {
    el.remove();
  });
  
  // Remove empty tables (tables with no actual content)
  doc.querySelectorAll('table').forEach(table => {
    const hasRows = table.querySelector('tr');
    const hasCells = table.querySelector('td, th');
    if (!hasRows || !hasCells) {
      table.remove();
    }
  });
  
  // Classes to remove (selection-related)
  const selectionClasses = [
    'selected', 'ql-cell-selected', 'ql-table-selected', 
    'ql-cell-focused', 'ql-table-better-selected-td',
    'ql-table-better-selection-line', 'ql-table-better-selection-block'
  ];
  
  // Classes to preserve (alignment-related)
  const preserveClasses = ['align-left', 'align-center', 'align-right', 'table-with-header'];
  
  // Remove selection classes from all elements
  doc.querySelectorAll('*').forEach(el => {
    selectionClasses.forEach(cls => {
      el.classList.remove(cls);
    });
    
    // Remove any class containing 'select' (but preserve alignment and header classes)
    const classesToRemove = [];
    el.classList.forEach(cls => {
      if (cls.includes('select') && !preserveClasses.includes(cls)) {
        classesToRemove.push(cls);
      }
    });
    classesToRemove.forEach(cls => el.classList.remove(cls));
    
    // Remove inline background styles from table cells (selection colors)
    if (el.tagName === 'TD' || el.tagName === 'TH') {
      const bgStyle = el.style.backgroundColor;
      if (bgStyle && (bgStyle.includes('rgb(') || bgStyle.includes('rgba('))) {
        const match = bgStyle.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
        if (match) {
          const [, r, g, b] = match.map(Number);
          // Remove if it's a light blue/selection color (high blue component)
          if (b > r && b > g) {
            el.style.removeProperty('background-color');
            el.style.removeProperty('background');
          }
        }
      }
    }
  });
  
  // Remove quill-table-better tool elements entirely
  const toolElements = doc.querySelectorAll('[class*="ql-table-better-tool"], [class*="ql-table-better-col"], [class*="ql-table-better-row"], [class*="ql-table-better-corner"]');
  console.log('[HTML Parsing] cleanHtmlForPreview - Removing tool elements:', toolElements.length);
  toolElements.forEach(el => {
    el.remove();
  });
  
  const cleanedHtml = doc.body.innerHTML;
  console.log('[HTML Parsing] cleanHtmlForPreview - Output length:', cleanedHtml?.length || 0);
  console.log('[HTML Parsing] cleanHtmlForPreview - Output preview:', cleanedHtml?.substring(0, 200) || 'null');
  
  return cleanedHtml;
}

