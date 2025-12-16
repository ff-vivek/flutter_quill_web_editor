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
      const cleanedHtml = cleanHtmlForPreview(event.data);
      viewer.innerHTML = cleanedHtml;
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
      const cleanedHtml = cleanHtmlForPreview(data.html || '');
      viewer.innerHTML = cleanedHtml;
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

