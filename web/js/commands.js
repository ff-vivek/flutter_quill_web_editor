/**
 * Command Handling
 * ================
 * Handle commands from Flutter
 */

import { ZOOM_MIN, ZOOM_MAX } from './config.js';
import { preprocessHtml, extractBodyContent } from './utils.js';
import { sendContentChange, sendContentsResponse, sendZoomChange } from './flutter-bridge.js';

/**
 * Store image dimensions and alignment from HTML before conversion
 * @param {string} htmlContent - HTML content to extract styles from
 * @returns {Map} Map of image src to style properties
 */
function storeImageStyles(htmlContent) {
  const tempStore = document.createElement('div');
  tempStore.innerHTML = htmlContent;
  const imageStyles = new Map();
  
  tempStore.querySelectorAll('img, video, iframe').forEach(media => {
    const src = media.src || media.getAttribute('src');
    if (src) {
      imageStyles.set(src, {
        width: media.style.width || media.getAttribute('width'),
        height: media.style.height || media.getAttribute('height'),
        alignClass: Array.from(media.classList).find(cls => 
          cls === 'align-left' || cls === 'align-center' || cls === 'align-right'
        )
      });
    }
  });
  
  return imageStyles;
}

/**
 * Restore image dimensions and alignment after Quill conversion
 * @param {Object} editor - Quill editor instance
 * @param {Map} imageStyles - Map of image src to style properties
 * @returns {boolean} True if any styles were restored
 */
function restoreImageStyles(editor, imageStyles) {
  let stylesRestored = false;
  let foundAnyMedia = false;
  
  editor.root.querySelectorAll('img, video, iframe').forEach(media => {
    foundAnyMedia = true;
    const src = media.src || media.getAttribute('src');
    if (src && imageStyles.has(src)) {
      const styles = imageStyles.get(src);
      
      // Restore width if missing
      if (styles.width && !media.style.width) {
        const widthValue = styles.width.includes('px') || styles.width.includes('%') || 
                          styles.width.includes('em') || styles.width.includes('rem')
          ? styles.width 
          : styles.width + 'px';
        media.style.width = widthValue;
        stylesRestored = true;
      }
      
      // Restore height if missing
      if (styles.height && !media.style.height) {
        const heightValue = styles.height.includes('px') || styles.height.includes('%') || 
                           styles.height.includes('em') || styles.height.includes('rem')
          ? styles.height 
          : styles.height + 'px';
        media.style.height = heightValue;
        stylesRestored = true;
      }
      
      // Restore alignment class if missing
      if (styles.alignClass && !media.classList.contains(styles.alignClass)) {
        media.classList.remove('align-left', 'align-center', 'align-right');
        media.classList.add(styles.alignClass);
        stylesRestored = true;
      }
    }
  });
  
  // Return true if we found media but styles weren't restored (means styles were already present)
  // Return false if no media found (might need to retry)
  return foundAnyMedia ? stylesRestored : null;
}

/**
 * Handle commands from Flutter
 * @param {Object} data - Command data
 * @param {Object} editor - Quill editor instance
 * @param {Object} Quill - Quill constructor
 */
export function handleCommand(data, editor, Quill) {
  const Delta = Quill.import('delta');
  
  switch (data.action) {
    case 'setContents':
      if (data.delta) {
        editor.setContents(data.delta, Quill.sources.SILENT);
      }
      break;

    case 'setHTML':
      if (data.html) {
        // Extract body content if it's a full HTML document
        let htmlContent = extractBodyContent(data.html);
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        
        // Store image dimensions before conversion (in case Quill strips them)
        const imageStyles = storeImageStyles(htmlContent);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempContainer = document.createElement('div');
        tempContainer.innerHTML = htmlContent;
        const delta = editor.clipboard.convert({ html: htmlContent, text: tempContainer.innerText });
        
        if (data.replace !== false) {
           // Replace all content - always use USER source for proper parsing
           editor.setContents([], Quill.sources.USER);
           editor.updateContents(new Delta().retain(0).concat(delta), Quill.sources.USER);
        } else {
          // Insert at current position
          const range = editor.getSelection();
          const index = range ? range.index : editor.getLength();
          editor.updateContents(new Delta().retain(index).concat(delta), Quill.sources.USER);
        }
        
        // Try to restore image dimensions synchronously first
        let restoreResult = restoreImageStyles(editor, imageStyles);
        
        // If media elements weren't found yet, retry after DOM updates
        if (restoreResult === null) {
          requestAnimationFrame(() => {
            restoreResult = restoreImageStyles(editor, imageStyles);
            if (restoreResult === null) {
              // Still not found, try one more time
              requestAnimationFrame(() => {
                if (restoreImageStyles(editor, imageStyles)) {
                  sendContentChange(editor);
                }
              });
            } else if (restoreResult) {
              sendContentChange(editor);
            }
          });
        } else if (restoreResult) {
          // Styles were restored synchronously, notify Flutter
          sendContentChange(editor);
        }
        
        // Notify Flutter of the content change
        sendContentChange(editor);
      }
      break;

    case 'insertText':
      if (data.text) {
        const selection = editor.getSelection(true);
        if (selection) {
          editor.insertText(selection.index, data.text, Quill.sources.USER);
          editor.setSelection(selection.index + data.text.length);
        }
      }
      break;

    case 'insertHtml':
      if (data.html) {
        // Extract body content if it's a full HTML document
        let htmlContent = extractBodyContent(data.html);
        
        // Check for nested tables before processing
        const tempCheck = document.createElement('div');
        tempCheck.innerHTML = htmlContent;
        const hasNestedTables = tempCheck.querySelector('td table, th table') !== null;
        
        if (hasNestedTables) {
          console.warn('[HTML Parsing] Nested tables detected - quill-table-better may not support this');
          console.log('[HTML Parsing] Nested table HTML:', tempCheck.querySelector('td table, th table')?.outerHTML);
        }
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        
        // Store image dimensions before conversion (in case Quill strips them)
        const imageStyles = storeImageStyles(htmlContent);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlContent;
        const insertDelta = editor.clipboard.convert({ html: htmlContent, text: tempDiv.innerText });
        
        // Note: Nested tables will likely be stripped by quill-table-better during conversion
        // This is a known limitation of the module
        
        if (data.replace) {
          // Replace all content
          editor.setContents(insertDelta, Quill.sources.USER);
        } else {
          // Insert at current position
          const range = editor.getSelection();
          const index = range ? range.index : editor.getLength();
          editor.updateContents(new Delta().retain(index).concat(insertDelta), Quill.sources.USER);
        }
        
        // Try to restore image dimensions synchronously first
        let restoreResult = restoreImageStyles(editor, imageStyles);
        
        // If media elements weren't found yet, retry after DOM updates
        if (restoreResult === null) {
          requestAnimationFrame(() => {
            restoreResult = restoreImageStyles(editor, imageStyles);
            if (restoreResult === null) {
              // Still not found, try one more time
              requestAnimationFrame(() => {
                if (restoreImageStyles(editor, imageStyles)) {
                  sendContentChange(editor);
                }
              });
            } else if (restoreResult) {
              sendContentChange(editor);
            }
          });
        } else if (restoreResult) {
          // Styles were restored synchronously, notify Flutter
          sendContentChange(editor);
        }
        
        // Notify Flutter of the content change
        sendContentChange(editor);
      }
      break;

    case 'getContents':
      sendContentsResponse(editor);
      break;

    case 'clear':
      editor.setContents([], Quill.sources.USER);
      // Also notify Flutter immediately since setContents may not trigger text-change
      sendContentChange(editor);
      break;

    case 'focus':
      editor.focus();
      break;

    case 'undo':
      {
        console.log('Executing undo command');
        const history = editor.getModule('history');
        console.log('History module:', history);
        if (history) {
          history.undo();
          console.log('Undo executed');
          sendContentChange(editor);
        } else {
          console.warn('History module not found');
        }
      }
      break;

    case 'redo':
      {
        console.log('Executing redo command');
        const history = editor.getModule('history');
        console.log('History module:', history);
        if (history) {
          history.redo();
          console.log('Redo executed');
          sendContentChange(editor);
        } else {
          console.warn('History module not found');
        }
      }
      break;

    case 'format':
      // Apply formatting to selection or at cursor
      if (data.format && data.value !== undefined) {
        const range = editor.getSelection();
        if (range) {
          if (range.length > 0) {
            // Format selected text
            editor.formatText(range.index, range.length, data.format, data.value, Quill.sources.USER);
          } else {
            // Format at cursor position (for next typed characters)
            editor.format(data.format, data.value, Quill.sources.USER);
          }
          sendContentChange(editor);
        }
      }
      break;

    case 'insertTable':
      // Insert a table at cursor position
      if (data.rows && data.cols) {
        const tableModule = editor.getModule('tableWrapper');
        if (tableModule) {
          tableModule.insertTable(data.rows, data.cols);
          sendContentChange(editor);
        }
      }
      break;

    case 'setZoom':
      if (data.zoom !== undefined) {
        const zoomLevel = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, data.zoom));
        const editorEl = document.querySelector('.ql-editor');
        if (editorEl) {
          editorEl.style.transform = `scale(${zoomLevel})`;
          // Adjust container width to prevent horizontal scroll
          editorEl.style.width = `${100 / zoomLevel}%`;
        }
        sendZoomChange(zoomLevel);
      }
      break;
  }
}

/**
 * Set up message listener for commands from Flutter
 * @param {Object} editor - Quill editor instance
 * @param {Object} Quill - Quill constructor
 */
export function setupCommandListener(editor, Quill) {
  window.addEventListener('message', function(event) {
    // Accept messages from parent window (Flutter) or same window
    if (event.source !== window.parent && event.source !== window) return;

    try {
      const data = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
      if (data.type === 'command') {
        console.log('Received command:', data.action);
        handleCommand(data, editor, Quill);
      }
    } catch (e) {
      console.log('Message parse error:', e, event.data);
    }
  });
}

