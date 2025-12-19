/**
 * Custom Clipboard Override
 * =========================
 * 
 * This file extends the package's clipboard.js to use custom font mapping.
 * 
 * Last updated: 2025-12-17
 */

// Import package clipboard functions
import { setupSelectionPreservation as packageSetupSelectionPreservation } from '/assets/packages/quill_web_editor/web/js/clipboard.js';
import { sendContentChange } from '/assets/packages/quill_web_editor/web/js/flutter-bridge.js';

// Import custom utils (with Mulish font mapping)
import { preprocessHtml } from './utils-override.js';

/**
 * Set up native paste handler with custom font mapping
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
      htmlData.includes('background-color')
    )) {
      e.preventDefault();
      
      // Get plain text as fallback
      const textData = clipboardData.getData('text/plain');
      
      // Preprocess HTML with custom font mapping (includes Mulish)
      let processedHtml = preprocessHtml(htmlData);
      
      // If preprocessing failed or returned empty, use plain text
      if (!processedHtml || processedHtml.trim() === '') {
        processedHtml = textData || '';
      }
      
      // Convert HTML to Delta and insert
      const delta = editor.clipboard.convert(processedHtml);
      editor.updateContents(delta, 'user');
      
      // Trigger content change
      sendContentChange(editor);
    }
  });
}

// Re-export selection preservation unchanged
export const setupSelectionPreservation = packageSetupSelectionPreservation;

