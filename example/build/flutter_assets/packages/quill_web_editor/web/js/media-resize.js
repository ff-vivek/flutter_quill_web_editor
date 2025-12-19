/**
 * Media Resize
 * ============
 * Image, video, iframe resize controls
 */

import { MEDIA_MIN_SIZE } from './config.js';
import { sendContentChange } from './flutter-bridge.js';

// State
let selectedMedia = null;
let originalMediaWidth = 0;
let originalMediaHeight = 0;
let isResizing = false;
let resizeHandle = null;
let resizeStartX = 0;
let resizeStartY = 0;
let resizeStartWidth = 0;
let resizeStartHeight = 0;
let hoveredMedia = null;
let isDraggingResize = false;
let resizeAnimationFrame = null;

// DOM Elements (initialized in setup)
let mediaResizer = null;
let mediaSizeDisplay = null;
let mediaAlignBtns = null;
let mediaSizeBtns = null;
let mediaResetBtn = null;
let mediaDeleteBtn = null;
let mediaDragIcon = null;
let resizeTooltip = null;

/**
 * Check if element is resizable (images, videos, iframes only - NOT tables)
 * @param {Element} el - Element to check
 * @returns {boolean} True if resizable
 */
export function isResizableMedia(el) {
  if (!el) return false;
  const tagName = el.tagName.toUpperCase();
  return tagName === 'IMG' || tagName === 'IFRAME' || tagName === 'VIDEO';
}

/**
 * Get the editor content width (accounting for padding)
 * @param {Object} editor - Quill editor instance
 * @returns {number} Content width in pixels
 */
function getEditorContentWidth(editor) {
  return editor.root.clientWidth - 48; // Account for padding
}

/**
 * Position drag icon on media element
 * @param {Element} media - Media element
 */
function positionDragIcon(media) {
  if (!media || !mediaDragIcon) return;
  requestAnimationFrame(() => {
    const rect = media.getBoundingClientRect();
    mediaDragIcon.style.left = `${rect.right - 34}px`;
    mediaDragIcon.style.top = `${rect.bottom - 34}px`;
  });
}

/**
 * Show drag icon on media hover
 * @param {Element} media - Media element
 */
function showDragIcon(media) {
  if (selectedMedia === media) return;
  hoveredMedia = media;
  positionDragIcon(media);
  mediaDragIcon.classList.add('visible');
}

/**
 * Hide drag icon
 */
function hideDragIcon() {
  if (!isDraggingResize) {
    hoveredMedia = null;
    mediaDragIcon.classList.remove('visible');
  }
}

/**
 * Position resizer overlay
 * @param {Element} media - Media element
 */
function positionMediaResizer(media) {
  if (!media || !mediaResizer) return;
  const rect = media.getBoundingClientRect();
  
  if (rect.width === 0 || rect.height === 0) return;
  
  mediaResizer.style.left = `${rect.left}px`;
  mediaResizer.style.top = `${rect.top}px`;
  mediaResizer.style.width = `${rect.width}px`;
  mediaResizer.style.height = `${rect.height}px`;
}

/**
 * Update size display
 * @param {Object} editor - Quill editor instance
 */
function updateMediaSizeDisplay(editor) {
  if (!selectedMedia || !mediaSizeDisplay) return;
  const width = selectedMedia.offsetWidth || selectedMedia.width;
  const height = selectedMedia.offsetHeight || selectedMedia.height;
  const editorWidth = getEditorContentWidth(editor);
  const percent = Math.round((width / editorWidth) * 100);
  
  mediaSizeDisplay.textContent = `${Math.round(width)} × ${Math.round(height)} px (${percent}%)`;
}

/**
 * Update alignment buttons
 */
function updateAlignmentButtons() {
  if (!selectedMedia || !mediaAlignBtns) return;
  mediaAlignBtns.forEach(btn => {
    const align = btn.dataset.align;
    btn.classList.toggle('active', selectedMedia.classList.contains(`align-${align}`));
  });
}

/**
 * Update size buttons
 * @param {Object} editor - Quill editor instance
 */
function updateSizeButtons(editor) {
  if (!selectedMedia || !mediaSizeBtns) return;
  const editorWidth = getEditorContentWidth(editor);
  const currentWidth = selectedMedia.offsetWidth || selectedMedia.width;
  const currentPercent = Math.round((currentWidth / editorWidth) * 100);
  
  mediaSizeBtns.forEach(btn => {
    const size = parseInt(btn.dataset.size);
    btn.classList.toggle('active', Math.abs(currentPercent - size) < 5);
  });
}

/**
 * Select media for resizing
 * @param {Element} media - Media element
 * @param {Object} editor - Quill editor instance
 */
function selectMedia(media, editor) {
  if (selectedMedia) {
    selectedMedia.classList.remove('selected');
  }
  
  selectedMedia = media;
  media.classList.add('selected');
  
  if (media.tagName === 'IMG') {
    originalMediaWidth = media.naturalWidth || media.width;
    originalMediaHeight = media.naturalHeight || media.height;
  } else if (media.tagName === 'TABLE') {
    originalMediaWidth = media.offsetWidth;
    originalMediaHeight = media.offsetHeight;
  } else {
    originalMediaWidth = media.offsetWidth;
    originalMediaHeight = media.offsetHeight;
  }
  
  requestAnimationFrame(() => {
    positionMediaResizer(media);
    mediaResizer.classList.add('active');
    updateMediaSizeDisplay(editor);
    updateAlignmentButtons();
    updateSizeButtons(editor);
  });
}

/**
 * Deselect media
 */
function deselectMedia() {
  if (selectedMedia) {
    selectedMedia.classList.remove('selected');
    selectedMedia = null;
  }
  if (mediaResizer) {
    mediaResizer.classList.remove('active');
  }
  hideDragIcon();
}

/**
 * Handle media resize
 * @param {MouseEvent} e - Mouse event
 * @param {Object} editor - Quill editor instance
 */
function handleMediaResize(e, editor) {
  if ((!isResizing && !isDraggingResize) || !selectedMedia) return;
  
  if (resizeAnimationFrame) {
    cancelAnimationFrame(resizeAnimationFrame);
  }
  
  resizeAnimationFrame = requestAnimationFrame(() => {
    const dx = e.clientX - resizeStartX;
    const dy = e.clientY - resizeStartY;
    
    const editorWidth = getEditorContentWidth(editor);
    const aspectRatio = resizeStartWidth / resizeStartHeight;
    const isTable = selectedMedia.tagName === 'TABLE';
    
    let newWidth = resizeStartWidth;
    let newHeight = resizeStartHeight;
    
    switch (resizeHandle) {
      case 'se': case 'e':
        newWidth = resizeStartWidth + dx;
        if (!isTable) newHeight = newWidth / aspectRatio;
        break;
      case 'sw': case 'w':
        newWidth = resizeStartWidth - dx;
        if (!isTable) newHeight = newWidth / aspectRatio;
        break;
      case 'ne':
        newWidth = resizeStartWidth + dx;
        if (!isTable) newHeight = newWidth / aspectRatio;
        break;
      case 'nw':
        newWidth = resizeStartWidth - dx;
        if (!isTable) newHeight = newWidth / aspectRatio;
        break;
      case 'n':
        if (!isTable) {
          newHeight = resizeStartHeight - dy;
          newWidth = newHeight * aspectRatio;
        }
        break;
      case 's':
        if (!isTable) {
          newHeight = resizeStartHeight + dy;
          newWidth = newHeight * aspectRatio;
        }
        break;
    }
    
    // Clamp to min/max sizes
    newWidth = Math.max(MEDIA_MIN_SIZE, Math.min(editorWidth, newWidth));
    
    if (!isTable) {
      newHeight = Math.max(MEDIA_MIN_SIZE, newWidth / aspectRatio);
    }
    
    // Calculate percentage immediately for display
    const currentPercent = Math.round((newWidth / editorWidth) * 100);
    
    // Apply size changes
    selectedMedia.style.width = `${newWidth}px`;
    if (!isTable) {
      selectedMedia.style.height = `${newHeight}px`;
    } else {
      selectedMedia.style.height = 'auto';
    }
    
    // Update size display
    const height = isTable ? selectedMedia.offsetHeight : Math.round(newHeight);
    mediaSizeDisplay.textContent = `${Math.round(newWidth)} × ${height} px (${currentPercent}%)`;
    
    // Show floating tooltip near cursor
    resizeTooltip.textContent = `${currentPercent}%`;
    resizeTooltip.style.left = `${e.clientX}px`;
    resizeTooltip.style.top = `${e.clientY - 10}px`;
    resizeTooltip.classList.add('visible');
    
    // Position resizer to match the new size
    positionMediaResizer(selectedMedia);
    
    updateSizeButtons(editor);
  });
}

/**
 * Set media alignment
 * @param {string} align - Alignment value (left, center, right)
 * @param {Object} editor - Quill editor instance
 */
function setMediaAlignment(align, editor) {
  if (!selectedMedia) return;
  
  const elementsToAlign = [selectedMedia];
  if (selectedMedia.tagName === 'TABLE') {
    const wrapper = selectedMedia.closest('.ql-table-wrapper');
    if (wrapper) {
      elementsToAlign.push(wrapper);
    }
  }
  
  elementsToAlign.forEach(el => {
    el.classList.remove('align-left', 'align-center', 'align-right');
    el.style.float = '';
    el.style.marginLeft = '';
    el.style.marginRight = '';
    
    el.classList.add(`align-${align}`);
    
    if (align === 'center') {
      el.style.display = el.tagName === 'TABLE' ? 'table' : 'block';
      el.style.marginLeft = 'auto';
      el.style.marginRight = 'auto';
    } else if (align === 'left') {
      el.style.float = 'left';
      el.style.marginRight = '16px';
    } else if (align === 'right') {
      el.style.float = 'right';
      el.style.marginLeft = '16px';
    }
  });
  
  updateAlignmentButtons();
  sendContentChange(editor);
  
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      positionMediaResizer(selectedMedia);
    });
  });
}

/**
 * Set size by percentage
 * @param {number} percent - Size percentage
 * @param {Object} editor - Quill editor instance
 */
function setMediaSizePercent(percent, editor) {
  if (!selectedMedia) return;
  
  const editorWidth = getEditorContentWidth(editor);
  const newWidth = (editorWidth * percent) / 100;
  const isTable = selectedMedia.tagName === 'TABLE';
  
  selectedMedia.style.width = `${newWidth}px`;
  
  if (!isTable) {
    const aspectRatio = (selectedMedia.offsetWidth || selectedMedia.width) / 
                       (selectedMedia.offsetHeight || selectedMedia.height);
    const newHeight = newWidth / aspectRatio;
    selectedMedia.style.height = `${newHeight}px`;
  } else {
    selectedMedia.style.height = 'auto';
  }
  
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      positionMediaResizer(selectedMedia);
      updateMediaSizeDisplay(editor);
    });
  });
  updateSizeButtons(editor);
  sendContentChange(editor);
}

/**
 * Reset media size
 * @param {Object} editor - Quill editor instance
 */
function resetMediaSize(editor) {
  if (!selectedMedia || !originalMediaWidth) return;
  
  const maxWidth = getEditorContentWidth(editor);
  let newWidth = originalMediaWidth;
  let newHeight = originalMediaHeight;
  const isTable = selectedMedia.tagName === 'TABLE';
  
  if (newWidth > maxWidth) {
    const scale = maxWidth / newWidth;
    newWidth = maxWidth;
    if (!isTable) {
      newHeight = originalMediaHeight * scale;
    }
  }
  
  selectedMedia.style.width = `${newWidth}px`;
  if (!isTable) {
    selectedMedia.style.height = `${newHeight}px`;
  } else {
    selectedMedia.style.height = 'auto';
  }
  
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      positionMediaResizer(selectedMedia);
      updateMediaSizeDisplay(editor);
    });
  });
  updateSizeButtons(editor);
  sendContentChange(editor);
}

/**
 * Delete selected media
 * @param {Object} editor - Quill editor instance
 * @param {Object} Quill - Quill constructor
 */
function deleteSelectedMedia(editor, Quill) {
  if (!selectedMedia) return;
  
  const blot = Quill.find(selectedMedia);
  if (blot) {
    const index = editor.getIndex(blot);
    editor.deleteText(index, 1, 'user');
  } else {
    selectedMedia.remove();
  }
  
  deselectMedia();
  sendContentChange(editor);
}

/**
 * Set up media resize functionality
 * @param {Object} editor - Quill editor instance
 * @param {Object} Quill - Quill constructor
 */
export function setupMediaResize(editor, Quill) {
  // Initialize DOM references
  mediaResizer = document.getElementById('mediaResizer');
  mediaSizeDisplay = document.getElementById('mediaSizeDisplay');
  mediaAlignBtns = document.querySelectorAll('.media-align-btn');
  mediaSizeBtns = document.querySelectorAll('.media-size-btn');
  mediaResetBtn = document.getElementById('mediaResetBtn');
  mediaDeleteBtn = document.getElementById('mediaDeleteBtn');
  mediaDragIcon = document.getElementById('mediaDragIcon');
  resizeTooltip = document.getElementById('resizeTooltip');
  
  // Show drag icon on media hover
  editor.root.addEventListener('mouseover', (e) => {
    const targetMedia = e.target;
    if (isResizableMedia(targetMedia) && !selectedMedia) {
      showDragIcon(targetMedia);
    }
  });
  
  editor.root.addEventListener('mouseout', (e) => {
    const targetMedia = e.target;
    if (isResizableMedia(targetMedia)) {
      const toElement = e.relatedTarget;
      if (toElement !== mediaDragIcon && !mediaDragIcon.contains(toElement)) {
        hideDragIcon();
      }
    }
  });
  
  // Keep drag icon visible when hovering over it
  mediaDragIcon.addEventListener('mouseenter', () => {
    if (hoveredMedia) {
      mediaDragIcon.classList.add('visible');
    }
  });
  
  mediaDragIcon.addEventListener('mouseleave', () => {
    if (!isDraggingResize && !selectedMedia) {
      hideDragIcon();
    }
  });
  
  // Drag icon mousedown - start resize
  mediaDragIcon.addEventListener('mousedown', (e) => {
    if (!hoveredMedia && !selectedMedia) return;
    
    const targetMedia = selectedMedia || hoveredMedia;
    if (!selectedMedia) {
      selectMedia(targetMedia, editor);
    }
    
    isDraggingResize = true;
    resizeHandle = 'se';
    resizeStartX = e.clientX;
    resizeStartY = e.clientY;
    resizeStartWidth = targetMedia.offsetWidth;
    resizeStartHeight = targetMedia.offsetHeight;
    
    mediaDragIcon.classList.remove('visible');
    e.preventDefault();
    e.stopPropagation();
  });
  
  // Handle clicks on media
  editor.root.addEventListener('click', (e) => {
    const targetMedia = e.target;
    
    if (isResizableMedia(targetMedia)) {
      e.preventDefault();
      e.stopPropagation();
      selectMedia(targetMedia, editor);
      hideDragIcon();
    } else if (!e.target.closest('.media-resizer') && !e.target.closest('.media-drag-icon')) {
      deselectMedia();
    }
  });
  
  editor.root.addEventListener('mousedown', (e) => {
    if (e.target.tagName === 'VIDEO' || e.target.tagName === 'IFRAME') {
      e.preventDefault();
    }
  });
  
  editor.root.addEventListener('dblclick', (e) => {
    if (e.target.tagName === 'VIDEO') {
      if (e.target.paused) {
        e.target.play();
      } else {
        e.target.pause();
      }
    }
  });
  
  // Resize handle mousedown
  mediaResizer.querySelectorAll('.resize-handle').forEach(handle => {
    handle.addEventListener('mousedown', (e) => {
      if (!selectedMedia) return;
      
      isResizing = true;
      resizeHandle = handle.dataset.handle;
      resizeStartX = e.clientX;
      resizeStartY = e.clientY;
      resizeStartWidth = selectedMedia.offsetWidth;
      resizeStartHeight = selectedMedia.offsetHeight;
      
      e.preventDefault();
      e.stopPropagation();
    });
  });
  
  // Alignment buttons
  mediaAlignBtns.forEach(btn => {
    btn.addEventListener('click', () => setMediaAlignment(btn.dataset.align, editor));
  });
  
  // Size buttons
  mediaSizeBtns.forEach(btn => {
    btn.addEventListener('click', () => setMediaSizePercent(parseInt(btn.dataset.size), editor));
  });
  
  // Reset and delete buttons
  mediaResetBtn.addEventListener('click', () => resetMediaSize(editor));
  mediaDeleteBtn.addEventListener('click', () => deleteSelectedMedia(editor, Quill));
  
  // Document-level mouse events
  document.addEventListener('mousemove', (e) => handleMediaResize(e, editor));
  
  document.addEventListener('mouseup', () => {
    if (isResizing || isDraggingResize) {
      isResizing = false;
      isDraggingResize = false;
      resizeHandle = null;
      
      resizeTooltip.classList.remove('visible');
      
      if (selectedMedia) {
        updateMediaSizeDisplay(editor);
        sendContentChange(editor);
      }
    }
  });
  
  // Keyboard shortcuts
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      deselectMedia();
    }
    if ((e.key === 'Delete' || e.key === 'Backspace') && selectedMedia) {
      e.preventDefault();
      deleteSelectedMedia(editor, Quill);
    }
  });
  
  // Reposition on scroll/resize
  const repositionResizer = () => {
    if (selectedMedia) {
      requestAnimationFrame(() => {
        positionMediaResizer(selectedMedia);
      });
    }
  };
  
  editor.root.addEventListener('scroll', repositionResizer);
  document.querySelector('.ql-container')?.addEventListener('scroll', repositionResizer);
  document.addEventListener('scroll', repositionResizer, true);
  
  window.addEventListener('resize', () => {
    if (selectedMedia) {
      requestAnimationFrame(() => {
        positionMediaResizer(selectedMedia);
        updateSizeButtons(editor);
      });
    }
  });
  
  // ResizeObserver for layout changes
  const resizeObserver = new ResizeObserver(() => {
    if (selectedMedia) {
      requestAnimationFrame(() => {
        positionMediaResizer(selectedMedia);
      });
    }
  });
  resizeObserver.observe(editor.root);
}

