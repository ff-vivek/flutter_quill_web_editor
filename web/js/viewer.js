/**
 * Viewer Module
 * =============
 * Read-only HTML viewer for previewing content
 */

import { ZOOM_MIN, ZOOM_MAX } from './config.js';
import { cleanHtmlForPreview } from './utils.js';

/**
 * Initialize the viewer
 * @param {string} selector - Viewer container selector
 */
export function initializeViewer(selector = '#viewer') {
  const viewer = document.querySelector(selector);
  if (!viewer) {
    console.error('Viewer element not found:', selector);
    return;
  }
  
  // Add viewer mode class to body
  document.body.classList.add('viewer-mode');
  document.documentElement.classList.add('viewer-mode');
  
  // Listen for messages from Flutter
  window.addEventListener('message', function(event) {
    if (event.source !== window.parent) return;

    try {
      const data = JSON.parse(event.data);
      if (data.type === 'command') {
        handleViewerCommand(data, viewer);
      }
    } catch (e) {
      // Plain HTML string
      console.log('[HTML Parsing] Viewer - Received plain HTML string (not JSON)');
      console.log('[HTML Parsing] Viewer - HTML length:', event.data?.length || 0);
      const cleanedHtml = cleanHtmlForPreview(event.data);
      viewer.innerHTML = cleanedHtml;
      console.log('[HTML Parsing] Viewer - HTML set in viewer element');
    }
  });
}

/**
 * Handle commands for the viewer
 * @param {Object} data - Command data
 * @param {Element} viewer - Viewer element
 */
function handleViewerCommand(data, viewer) {
  switch (data.action) {
    case 'setHTML':
      console.log('[HTML Parsing] Viewer command - setHTML action');
      console.log('[HTML Parsing] Viewer command - HTML length:', data.html?.length || 0);
      const cleanedHtml = cleanHtmlForPreview(data.html || '');
      viewer.innerHTML = cleanedHtml;
      console.log('[HTML Parsing] Viewer command - HTML set in viewer element');
      break;
      
    case 'setZoom':
      const zoomLevel = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, data.zoom));
      if (viewer) {
        viewer.style.transform = `scale(${zoomLevel})`;
        viewer.style.width = `${100 / zoomLevel}%`;
      }
      break;
  }
}

