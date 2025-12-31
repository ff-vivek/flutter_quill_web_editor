/**
 * GIF Picker Module
 * =================
 * A dialog for inserting GIFs from URL into the Quill editor
 * 
 * This is an EXTENDED PLUGIN example showing how to create custom plugins
 * with JavaScript components.
 */

// GIF picker state
let pickerElement = null;
let currentPreviewUrl = null;
let isLoading = false;
let hasError = false;
let selectedSize = 'medium';
let gifOptions = {};

// Size presets
const SIZE_PRESETS = {
  small: { width: 200, label: 'Small' },
  medium: { width: 300, label: 'Medium' },
  large: { width: 450, label: 'Large' },
  original: { width: null, label: 'Original' }
};

/**
 * Initialize the GIF picker module
 * @param {Object} editor - Quill editor instance
 * @param {Object} options - Module options
 */
export function initGifPicker(editor, options = {}) {
  gifOptions = {
    maxWidth: options.maxWidth || null,
    maxHeight: options.maxHeight || null,
    defaultWidth: options.defaultWidth || 300,
    showPreview: options.showPreview !== false
  };
  
  // Set default size based on defaultWidth
  if (gifOptions.defaultWidth <= 200) {
    selectedSize = 'small';
  } else if (gifOptions.defaultWidth <= 350) {
    selectedSize = 'medium';
  } else {
    selectedSize = 'large';
  }
  
  console.log('GIF picker initialized with options:', gifOptions);
}

/**
 * Show the GIF picker dialog
 * @param {Object} editor - Quill editor instance
 * @param {Function} onInsert - Callback when GIF is inserted
 */
export function showGifPicker(editor, onInsert) {
  // Close existing picker
  hideGifPicker();
  
  // Reset state
  currentPreviewUrl = null;
  isLoading = false;
  hasError = false;
  
  // Create overlay
  pickerElement = document.createElement('div');
  pickerElement.className = 'ql-gif-overlay';
  pickerElement.innerHTML = buildPickerHTML();
  
  // Add to document
  document.body.appendChild(pickerElement);
  
  // Set up event listeners
  setupPickerEvents(editor, onInsert);
  
  // Focus URL input
  const urlInput = pickerElement.querySelector('.ql-gif-url-input');
  if (urlInput) {
    setTimeout(() => urlInput.focus(), 50);
  }
  
  // Close on overlay click
  pickerElement.addEventListener('click', (e) => {
    if (e.target === pickerElement) {
      hideGifPicker();
    }
  });
  
  // Close on Escape key
  document.addEventListener('keydown', handleEscapeKey);
}

/**
 * Hide the GIF picker dialog
 */
export function hideGifPicker() {
  if (pickerElement) {
    pickerElement.remove();
    pickerElement = null;
  }
  document.removeEventListener('keydown', handleEscapeKey);
}

/**
 * Handle Escape key press
 */
function handleEscapeKey(event) {
  if (event.key === 'Escape') {
    hideGifPicker();
  }
}

/**
 * Build the picker HTML
 */
function buildPickerHTML() {
  const sizeOptions = Object.entries(SIZE_PRESETS)
    .map(([key, preset]) => {
      const selectedClass = key === selectedSize ? 'selected' : '';
      return `<button class="ql-gif-size-option ${selectedClass}" data-size="${key}">${preset.label}</button>`;
    })
    .join('');
  
  return `
    <div class="ql-gif-picker">
      <div class="ql-gif-picker-header">
        <h3 class="ql-gif-picker-title">Insert GIF</h3>
        <button class="ql-gif-picker-close" title="Close">&times;</button>
      </div>
      
      <div class="ql-gif-url-input-container">
        <input 
          type="text" 
          class="ql-gif-url-input" 
          placeholder="Paste GIF URL (e.g., https://example.com/animation.gif)"
          autocomplete="off"
        />
        <button class="ql-gif-paste-btn" title="Paste from clipboard">📋 Paste</button>
      </div>
      
      <div class="ql-gif-preview-container">
        <div class="ql-gif-preview-placeholder">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <rect x="3" y="3" width="18" height="18" rx="2" />
            <circle cx="8.5" cy="8.5" r="1.5" />
            <path d="M21 15l-5-5L5 21" />
          </svg>
          <div>Enter a GIF URL to preview</div>
        </div>
      </div>
      
      <div class="ql-gif-size-options">
        ${sizeOptions}
      </div>
      
      <div class="ql-gif-actions">
        <button class="ql-gif-btn ql-gif-btn-cancel">Cancel</button>
        <button class="ql-gif-btn ql-gif-btn-insert" disabled>Insert GIF</button>
      </div>
    </div>
  `;
}

/**
 * Set up event listeners for the picker
 */
function setupPickerEvents(editor, onInsert) {
  if (!pickerElement) return;
  
  const urlInput = pickerElement.querySelector('.ql-gif-url-input');
  const pasteBtn = pickerElement.querySelector('.ql-gif-paste-btn');
  const closeBtn = pickerElement.querySelector('.ql-gif-picker-close');
  const cancelBtn = pickerElement.querySelector('.ql-gif-btn-cancel');
  const insertBtn = pickerElement.querySelector('.ql-gif-btn-insert');
  const previewContainer = pickerElement.querySelector('.ql-gif-preview-container');
  
  // URL input change handler with debounce
  let debounceTimer = null;
  urlInput.addEventListener('input', (e) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      const url = e.target.value.trim();
      if (url) {
        loadGifPreview(url, previewContainer, insertBtn);
      } else {
        resetPreview(previewContainer, insertBtn);
      }
    }, 500);
  });
  
  // Enter key to insert
  urlInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && currentPreviewUrl && !isLoading && !hasError) {
      e.preventDefault();
      insertGif(editor, currentPreviewUrl, onInsert);
    }
  });
  
  // Paste button
  pasteBtn.addEventListener('click', async () => {
    try {
      const text = await navigator.clipboard.readText();
      if (text) {
        urlInput.value = text;
        urlInput.dispatchEvent(new Event('input'));
      }
    } catch (err) {
      console.log('Could not read clipboard:', err);
    }
  });
  
  // Size options
  pickerElement.querySelectorAll('.ql-gif-size-option').forEach(btn => {
    btn.addEventListener('click', () => {
      selectedSize = btn.dataset.size;
      pickerElement.querySelectorAll('.ql-gif-size-option').forEach(b => {
        b.classList.toggle('selected', b.dataset.size === selectedSize);
      });
    });
  });
  
  // Close/cancel buttons
  closeBtn.addEventListener('click', hideGifPicker);
  cancelBtn.addEventListener('click', hideGifPicker);
  
  // Insert button
  insertBtn.addEventListener('click', () => {
    if (currentPreviewUrl && !isLoading && !hasError) {
      insertGif(editor, currentPreviewUrl, onInsert);
    }
  });
}

/**
 * Load and preview a GIF from URL
 */
function loadGifPreview(url, container, insertBtn) {
  // Validate URL
  if (!isValidUrl(url)) {
    showError(container, 'Please enter a valid URL', insertBtn);
    return;
  }
  
  // Show loading state
  isLoading = true;
  hasError = false;
  currentPreviewUrl = null;
  insertBtn.disabled = true;
  
  container.innerHTML = `
    <div class="ql-gif-loading">
      <div class="ql-gif-loading-spinner"></div>
      <div>Loading GIF...</div>
    </div>
  `;
  container.classList.remove('has-preview');
  
  // Create image to test loading
  const img = new Image();
  
  img.onload = () => {
    isLoading = false;
    currentPreviewUrl = url;
    
    container.innerHTML = `<img class="ql-gif-preview-img" src="${url}" alt="GIF Preview" />`;
    container.classList.add('has-preview');
    insertBtn.disabled = false;
  };
  
  img.onerror = () => {
    isLoading = false;
    hasError = true;
    showError(container, 'Failed to load GIF. Please check the URL.', insertBtn);
  };
  
  // Set src to start loading
  img.src = url;
  
  // Timeout after 10 seconds
  setTimeout(() => {
    if (isLoading) {
      img.src = '';
      isLoading = false;
      hasError = true;
      showError(container, 'Loading timed out. Please try again.', insertBtn);
    }
  }, 10000);
}

/**
 * Show error in preview container
 */
function showError(container, message, insertBtn) {
  container.innerHTML = `
    <div class="ql-gif-error">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="12" cy="12" r="10" />
        <line x1="12" y1="8" x2="12" y2="12" />
        <line x1="12" y1="16" x2="12.01" y2="16" />
      </svg>
      <div>${message}</div>
    </div>
  `;
  container.classList.remove('has-preview');
  insertBtn.disabled = true;
  hasError = true;
}

/**
 * Reset preview to placeholder
 */
function resetPreview(container, insertBtn) {
  container.innerHTML = `
    <div class="ql-gif-preview-placeholder">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
        <rect x="3" y="3" width="18" height="18" rx="2" />
        <circle cx="8.5" cy="8.5" r="1.5" />
        <path d="M21 15l-5-5L5 21" />
      </svg>
      <div>Enter a GIF URL to preview</div>
    </div>
  `;
  container.classList.remove('has-preview');
  insertBtn.disabled = true;
  currentPreviewUrl = null;
  hasError = false;
}

/**
 * Validate URL
 */
function isValidUrl(string) {
  try {
    const url = new URL(string);
    return url.protocol === 'http:' || url.protocol === 'https:';
  } catch (_) {
    return false;
  }
}

/**
 * Insert GIF into editor
 */
function insertGif(editor, url, onInsert) {
  if (!editor || !url) return;
  
  // Get width based on selected size
  const sizePreset = SIZE_PRESETS[selectedSize];
  let width = sizePreset.width || gifOptions.defaultWidth;
  
  // Apply max width constraint
  if (gifOptions.maxWidth && width > gifOptions.maxWidth) {
    width = gifOptions.maxWidth;
  }
  
  // Build image HTML with width
  const widthStyle = width ? `width: ${width}px;` : '';
  const heightStyle = gifOptions.maxHeight ? `max-height: ${gifOptions.maxHeight}px;` : '';
  const imgHtml = `<p><img src="${url}" style="${widthStyle}${heightStyle} object-fit: contain;" alt="GIF" /></p>`;
  
  // Insert at cursor position
  const range = editor.getSelection(true);
  if (range) {
    // Delete any selected content first
    if (range.length > 0) {
      editor.deleteText(range.index, range.length, 'user');
    }
    
    // Insert image as HTML
    const index = range.index;
    
    // Use clipboard.dangerouslyPasteHTML for proper insertion
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = imgHtml;
    const delta = editor.clipboard.convert({ html: imgHtml, text: '' });
    
    editor.updateContents(
      editor.constructor.import('delta')
        ? new (editor.constructor.import('delta'))().retain(index).concat(delta)
        : delta,
      'user'
    );
    
    // Move cursor after image
    editor.setSelection(index + 1, 0, 'user');
  } else {
    // Insert at end
    const length = editor.getLength();
    editor.clipboard.dangerouslyPasteHTML(length - 1, imgHtml, 'user');
  }
  
  // Close picker
  hideGifPicker();
  
  // Callback
  if (onInsert) {
    onInsert(url);
  }
  
  // Focus editor
  editor.focus();
}

/**
 * Register GIF command handler
 * This function registers the GIF picker with the global plugin action handlers
 */
export function registerGifCommand(editor) {
  return {
    showGifPicker: (data) => {
      showGifPicker(editor, (url) => {
        // Send to Flutter
        if (window.parent) {
          window.parent.postMessage(JSON.stringify({
            type: 'pluginAction',
            actionName: 'insertGif',
            params: { url: url }
          }), '*');
        }
      });
      return { success: true };
    }
  };
}

