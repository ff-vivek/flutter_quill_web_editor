/**
 * Command Handling
 * ================
 * Handle commands from Flutter
 */

import { ZOOM_MIN, ZOOM_MAX } from './config.js';
import { preprocessHtml, extractBodyContent } from './utils.js';
import { sendContentChange, sendContentsResponse, sendZoomChange } from './flutter-bridge.js';

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
        console.log('[HTML Parsing] setHTML command - Starting HTML processing');
        console.log('[HTML Parsing] setHTML command - Original HTML length:', data.html?.length || 0);
        
        // Extract body content if it's a full HTML document
        let htmlContent = extractBodyContent(data.html);
        console.log('[HTML Parsing] setHTML command - After extractBodyContent, length:', htmlContent?.length || 0);
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        console.log('[HTML Parsing] setHTML command - After preprocessHtml, length:', htmlContent?.length || 0);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempContainer = document.createElement('div');
        tempContainer.innerHTML = htmlContent;
        console.log('[HTML Parsing] setHTML command - Converting HTML to Delta...');
        const delta = editor.clipboard.convert({ html: htmlContent, text: tempContainer.innerText });
        console.log('[HTML Parsing] setHTML command - Delta length:', delta.length());
        
        // IMPORTANT: Always use USER source for setContents to ensure proper table/complex content parsing
        // The quill-table-better module and other formatters require USER source to work correctly
        // We use the 'silent' flag only to control Flutter notification, not Quill's internal processing
        const isSilent = data.silent === true;
        
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
        
        // Clear undo history if this is silent initialization (to prevent undoing to empty state)
        if (isSilent) {
          const history = editor.getModule('history');
          if (history) {
            history.clear();
          }
        }
        
        // Only notify Flutter if not silent (user-initiated changes)
        if (!isSilent) {
          sendContentChange(editor);
        } else {
          // For silent initialization, send content change after a short delay to ensure editor is ready
          setTimeout(() => {
            sendContentChange(editor);
          }, 100);
        }
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
        console.log('[HTML Parsing] insertHtml command - Starting HTML processing');
        console.log('[HTML Parsing] insertHtml command - Original HTML length:', data.html?.length || 0);
        
        // Extract body content if it's a full HTML document
        let htmlContent = extractBodyContent(data.html);
        console.log('[HTML Parsing] insertHtml command - After extractBodyContent, length:', htmlContent?.length || 0);
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        console.log('[HTML Parsing] insertHtml command - After preprocessHtml, length:', htmlContent?.length || 0);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlContent;
        console.log('[HTML Parsing] insertHtml command - Converting HTML to Delta...');
        const insertDelta = editor.clipboard.convert({ html: htmlContent, text: tempDiv.innerText });
        console.log('[HTML Parsing] insertHtml command - Delta length:', insertDelta.length());
        
        if (data.replace) {
          // Replace all content
          editor.setContents(insertDelta, Quill.sources.USER);
        } else {
          // Insert at current position
          const range = editor.getSelection();
          const index = range ? range.index : editor.getLength();
          editor.updateContents(new Delta().retain(index).concat(insertDelta), Quill.sources.USER);
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

