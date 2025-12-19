/**
 * Drag & Drop Handling
 * ====================
 * Preserve media properties when dragging between table cells
 */

import { isResizableMedia } from './media-resize.js';
import { sendContentChange } from './flutter-bridge.js';

// State
let draggedMediaProperties = null;

/**
 * Set up drag & drop handlers for media elements
 * @param {Object} editor - Quill editor instance
 */
export function setupDragDrop(editor) {
  // Capture media properties before drag starts
  editor.root.addEventListener('dragstart', (e) => {
    const target = e.target;
    if (isResizableMedia(target) && target.tagName !== 'TABLE') {
      draggedMediaProperties = {
        tagName: target.tagName,
        width: target.style.width || target.getAttribute('width'),
        height: target.style.height || target.getAttribute('height'),
        className: target.className,
        controls: target.hasAttribute('controls'),
        autoplay: target.hasAttribute('autoplay'),
        muted: target.hasAttribute('muted'),
        loop: target.hasAttribute('loop'),
        src: target.src,
        poster: target.poster,
        alignment: target.classList.contains('align-left') ? 'left' : 
                   target.classList.contains('align-center') ? 'center' : 
                   target.classList.contains('align-right') ? 'right' : null,
        wasInTableCell: target.closest('td, th') !== null,
        parentCell: target.closest('td, th')
      };
      console.log('Drag start - stored properties:', draggedMediaProperties);
    }
  });
  
  // Restore media properties after drop
  editor.root.addEventListener('drop', (e) => {
    if (draggedMediaProperties) {
      setTimeout(() => {
        const mediaElements = editor.root.querySelectorAll('img, video, iframe');
        mediaElements.forEach(media => {
          const hasWidth = media.style.width || media.getAttribute('width');
          const hasAlignment = media.classList.contains('align-left') || 
                              media.classList.contains('align-center') || 
                              media.classList.contains('align-right');
          
          if (media.src === draggedMediaProperties.src) {
            // Restore dimensions
            if (draggedMediaProperties.width && !hasWidth) {
              media.style.width = draggedMediaProperties.width;
            }
            if (draggedMediaProperties.height) {
              media.style.height = draggedMediaProperties.height;
            }
            
            // Restore alignment classes
            if (draggedMediaProperties.alignment && !hasAlignment) {
              media.classList.remove('align-left', 'align-center', 'align-right');
              media.classList.add('align-' + draggedMediaProperties.alignment);
            }
            
            // Restore video-specific attributes
            if (media.tagName === 'VIDEO') {
              if (draggedMediaProperties.controls) media.setAttribute('controls', '');
              if (draggedMediaProperties.autoplay) media.setAttribute('autoplay', '');
              if (draggedMediaProperties.muted) media.setAttribute('muted', '');
              if (draggedMediaProperties.loop) media.setAttribute('loop', '');
              if (draggedMediaProperties.poster) media.poster = draggedMediaProperties.poster;
            }
            
            // Restore custom classes (like ql-font-*, ql-size-*)
            const preserveClasses = ['ql-font-', 'ql-size-', 'align-'];
            if (draggedMediaProperties.className) {
              draggedMediaProperties.className.split(' ').forEach(cls => {
                if (preserveClasses.some(prefix => cls.startsWith(prefix))) {
                  if (!media.classList.contains(cls)) {
                    media.classList.add(cls);
                  }
                }
              });
            }
            
            console.log('Drop - restored properties to:', media);
          }
        });
        
        sendContentChange(editor);
        draggedMediaProperties = null;
      }, 100);
    }
  });
  
  // Clear properties if drag is cancelled
  editor.root.addEventListener('dragend', (e) => {
    setTimeout(() => {
      draggedMediaProperties = null;
    }, 200);
  });
}

/**
 * Set up MutationObserver to ensure media in table cells retains properties
 * @param {Object} editor - Quill editor instance
 */
export function setupMediaObserver(editor) {
  const mediaObserver = new MutationObserver((mutations) => {
    mutations.forEach(mutation => {
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            // Check if a media element was added to a table cell
            const tableCells = node.querySelectorAll ? node.querySelectorAll('td img, td video, td iframe, th img, th video, th iframe') : [];
            tableCells.forEach(media => {
              // Ensure video elements have controls
              if (media.tagName === 'VIDEO' && !media.hasAttribute('controls')) {
                media.setAttribute('controls', '');
              }
            });
            
            // Also check if the node itself is media in a table cell
            if ((node.tagName === 'IMG' || node.tagName === 'VIDEO' || node.tagName === 'IFRAME') && 
                node.closest('td, th')) {
              if (node.tagName === 'VIDEO' && !node.hasAttribute('controls')) {
                node.setAttribute('controls', '');
              }
            }
          }
        });
      }
    });
  });
  
  mediaObserver.observe(editor.root, {
    childList: true,
    subtree: true
  });
}

