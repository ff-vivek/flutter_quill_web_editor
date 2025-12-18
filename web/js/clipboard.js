/**
 * Clipboard Handling
 * ==================
 * Native paste handler and selection preservation
 */

import { preprocessHtml } from './utils.js';
import { sendContentChange } from './flutter-bridge.js';

/**
 * Set up native paste handler for font styles and colors
 * @param {Object} editor - Quill editor instance
 * @param {Object} Quill - Quill constructor
 */
export function setupPasteHandler(editor, Quill) {
  const Delta = Quill.import('delta');
  
  editor.root.addEventListener('paste', function(e) {
    // Check if clipboard has HTML content
    const clipboardData = e.clipboardData || window.clipboardData;
    if (!clipboardData) return;
    
    const htmlData = clipboardData.getData('text/html');
    
    // Only intercept if we have HTML content with potential font styles or colors
    if (htmlData && (
      htmlData.includes('font-family') || 
      htmlData.includes('font-size') || 
      htmlData.includes('<font') ||
      htmlData.includes('color') ||
      htmlData.includes('background') ||
      htmlData.includes('style=')
    )) {
      console.log('[HTML Parsing] Paste handler - Intercepting paste with HTML content');
      console.log('[HTML Parsing] Paste handler - HTML data length:', htmlData?.length || 0);
      console.log('[HTML Parsing] Paste handler - HTML data preview:', htmlData?.substring(0, 200) || 'null');
      
      e.preventDefault();
      e.stopPropagation();
      
      // Pre-process the HTML to convert font styles and normalize colors
      let processedHtml = preprocessHtml(htmlData);
      console.log('[HTML Parsing] Paste handler - Processed HTML length:', processedHtml?.length || 0);
      
      // Get current selection
      const range = editor.getSelection(true);
      const index = range ? range.index : editor.getLength();
      
      // Delete selected content if any
      if (range && range.length > 0) {
        editor.deleteText(range.index, range.length, Quill.sources.SILENT);
      }
      
      // Convert HTML to Delta for proper format handling
      const tempContainer = document.createElement('div');
      tempContainer.innerHTML = processedHtml;
      console.log('[HTML Parsing] Paste handler - Converting HTML to Delta...');
      const delta = editor.clipboard.convert({ html: processedHtml, text: tempContainer.innerText });
      console.log('[HTML Parsing] Paste handler - Delta length:', delta.length());
      
      // Insert the delta at the current position
      editor.updateContents(new Delta().retain(index).concat(delta), Quill.sources.USER);
      
      // Move cursor to end of pasted content
      editor.setSelection(index + delta.length(), 0, Quill.sources.SILENT);
      
      // Notify Flutter of the content change
      sendContentChange(editor);
    }
  }, true);
}

/**
 * Set up selection preservation for toolbar pickers
 * @param {Object} editor - Quill editor instance
 */
export function setupSelectionPreservation(editor) {
  let savedSelection = null;
  
  // Save selection continuously while editing
  editor.on('selection-change', function(range, oldRange, source) {
    if (range && range.length > 0) {
      // Only save if there's an actual selection (not just cursor)
      savedSelection = range;
    } else if (range) {
      // Save cursor position too
      savedSelection = range;
    }
  });
  
  // Override toolbar handlers to restore selection before applying format
  const toolbar = document.querySelector('.ql-toolbar');
  if (toolbar) {
    // Save selection when any toolbar element is clicked
    toolbar.addEventListener('mousedown', function(e) {
      const selection = editor.getSelection();
      if (selection) {
        savedSelection = selection;
      }
    }, true);
    
    // For picker items, we need to restore selection BEFORE the format is applied
    toolbar.addEventListener('mousedown', function(e) {
      const pickerItem = e.target.closest('.ql-picker-item');
      if (pickerItem && savedSelection) {
        // Restore selection immediately (before Quill's click handler)
        editor.setSelection(savedSelection.index, savedSelection.length, 'silent');
      }
    }, false);
    
    // Also handle picker labels (when opening dropdown)
    const pickerLabels = toolbar.querySelectorAll('.ql-picker-label');
    pickerLabels.forEach(label => {
      label.addEventListener('mousedown', function(e) {
        const selection = editor.getSelection();
        if (selection) {
          savedSelection = selection;
        }
      }, true);
    });
  }
  
  // Intercept format changes to ensure selection is used
  const originalFormat = editor.format.bind(editor);
  editor.format = function(name, value, source) {
    // If we have a saved selection with length > 0, use it
    if (savedSelection && savedSelection.length > 0) {
      const currentSelection = editor.getSelection();
      if (!currentSelection || currentSelection.length === 0) {
        editor.setSelection(savedSelection.index, savedSelection.length, 'silent');
      }
    }
    return originalFormat(name, value, source);
  };
}

