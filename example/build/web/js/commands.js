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
        // Extract body content if it's a full HTML document
        let htmlContent = extractBodyContent(data.html);
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempContainer = document.createElement('div');
        tempContainer.innerHTML = htmlContent;
        const delta = editor.clipboard.convert({ html: htmlContent, text: tempContainer.innerText });
        
        if (data.replace !== false) {
          // Replace all content
          editor.setContents(delta, Quill.sources.USER);
        } else {
          // Insert at current position
          const range = editor.getSelection();
          const index = range ? range.index : editor.getLength();
          editor.updateContents(new Delta().retain(index).concat(delta), Quill.sources.USER);
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
        
        // Pre-process to convert inline font styles to Quill classes and normalize colors
        htmlContent = preprocessHtml(htmlContent);
        
        // Convert HTML to Delta for proper format handling (including colors)
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = htmlContent;
        const insertDelta = editor.clipboard.convert({ html: htmlContent, text: tempDiv.innerText });
        
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
    if (event.source !== window.parent) return;

    try {
      const data = JSON.parse(event.data);
      if (data.type === 'command') {
        handleCommand(data, editor, Quill);
      }
    } catch (e) {
      console.log('Message parse error:', e);
    }
  });
}

