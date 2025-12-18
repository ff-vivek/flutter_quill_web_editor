/**
 * Flutter Bridge
 * ==============
 * Communication layer between Quill editor and Flutter
 */

import { CONTENT_CHANGE_THROTTLE } from './config.js';
import { cleanHtmlForSave } from './utils.js';

// Message throttling state
let lastContentChangeTime = 0;
let contentChangeTimer = null;

/**
 * Internal function to actually post the message
 * @param {Object} data - Data to send
 */
function _postMessage(data) {
  data.source = 'quill-editor';
  if (window.parent) {
    window.parent.postMessage(JSON.stringify(data), '*');
  }
}

/**
 * Send message to Flutter with throttling for content changes
 * @param {Object} data - Data to send
 */
export function sendToFlutter(data) {
  // Immediate send for non-content changes
  if (data.type !== 'contentChange') {
    _postMessage(data);
    return;
  }

  // Throttle content changes to prevent flooding Flutter
  // but ALWAYS send the trailing edge (last update)
  const now = Date.now();
  const timeRemaining = CONTENT_CHANGE_THROTTLE - (now - lastContentChangeTime);

  if (timeRemaining <= 0) {
    // Can send immediately
    if (contentChangeTimer) {
      clearTimeout(contentChangeTimer);
      contentChangeTimer = null;
    }
    lastContentChangeTime = now;
    _postMessage(data);
  } else {
    // Throttle - schedule for later
    if (contentChangeTimer) {
      clearTimeout(contentChangeTimer);
    }
    contentChangeTimer = setTimeout(function() {
      lastContentChangeTime = Date.now();
      contentChangeTimer = null;
      _postMessage(data);
    }, timeRemaining);
  }
}

/**
 * Force immediate content change notification (bypasses throttle)
 * @param {Object} editor - Quill editor instance
 * @param {string} html - HTML content to send
 */
export function sendContentChangeImmediate(editor, html) {
  // Cancel any pending throttled updates
  if (contentChangeTimer) {
    clearTimeout(contentChangeTimer);
    contentChangeTimer = null;
  }
  lastContentChangeTime = Date.now();
  
  // Clean HTML before sending to remove editor artifacts
  const cleanedHtml = cleanHtmlForSave(html);
  
  const data = {
    type: 'contentChange',
    delta: editor.getContents(),
    html: cleanedHtml,
    text: editor.getText()
  };
  
  console.log('Sending immediate content change, HTML length:', cleanedHtml.length);
  _postMessage(data);
}

/**
 * Send ready signal to Flutter
 */
export function sendReady() {
  sendToFlutter({
    type: 'ready'
  });
}

/**
 * Send content response to Flutter
 * @param {Object} editor - Quill editor instance
 */
export function sendContentsResponse(editor) {
  // Clean HTML before sending to remove editor artifacts (like <temporary> tags)
  const cleanedHtml = cleanHtmlForSave(editor.root.innerHTML);
  
  sendToFlutter({
    type: 'response',
    action: 'getContents',
    delta: editor.getContents(),
    html: cleanedHtml,
    text: editor.getText()
  });
}

/**
 * Send zoom change notification
 * @param {number} zoomLevel - Current zoom level
 */
export function sendZoomChange(zoomLevel) {
  sendToFlutter({
    type: 'zoomChange',
    zoom: zoomLevel
  });
}

/**
 * Send content change notification
 * @param {Object} editor - Quill editor instance
 */
export function sendContentChange(editor) {
  // Clean HTML before sending to remove editor artifacts (like <temporary> tags and empty tables)
  const cleanedHtml = cleanHtmlForSave(editor.root.innerHTML);
  
  sendToFlutter({
    type: 'contentChange',
    delta: editor.getContents(),
    html: cleanedHtml,
    text: editor.getText()
  });
}

