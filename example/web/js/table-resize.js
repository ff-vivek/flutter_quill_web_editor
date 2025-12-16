/**
 * Table Resize
 * ============
 * Table resize controls and header toggle
 */

import { TABLE_MIN_WIDTH } from './config.js';
import { sendContentChange, sendContentChangeImmediate } from './flutter-bridge.js';

// State
let hoveredTable = null;
let isDraggingTable = false;
let tableResizeStartX = 0;
let tableResizeStartWidth = 0;
let resizingTable = null;
let isTableBetterResizing = false;
let lastTableHTML = '';
let tableHeaderPopup = null;

// DOM Elements (initialized in setup)
let tableDragIcon = null;
let resizeTooltip = null;

/**
 * Get the editor content width (accounting for padding)
 * @param {Object} editor - Quill editor instance
 * @returns {number} Content width in pixels
 */
function getEditorContentWidth(editor) {
  return editor.root.clientWidth - 48;
}

/**
 * Position table drag icon
 * @param {Element} table - Table element
 */
function positionTableDragIcon(table) {
  if (!table || !tableDragIcon) return;
  requestAnimationFrame(() => {
    const rect = table.getBoundingClientRect();
    tableDragIcon.style.left = `${rect.right - 34}px`;
    tableDragIcon.style.top = `${rect.bottom - 34}px`;
  });
}

/**
 * Show table drag icon
 * @param {Element} table - Table element
 */
function showTableDragIcon(table) {
  hoveredTable = table;
  positionTableDragIcon(table);
  tableDragIcon.classList.add('visible');
}

/**
 * Hide table drag icon
 */
function hideTableDragIcon() {
  if (!isDraggingTable) {
    hoveredTable = null;
    tableDragIcon.classList.remove('visible');
  }
}

/**
 * Get table percentage width
 * @param {Element} table - Table element
 * @param {Object} editor - Quill editor instance
 * @returns {number} Percentage width
 */
function getTablePercent(table, editor) {
  const editorWidth = getEditorContentWidth(editor);
  const tableWidth = table.offsetWidth;
  return Math.round((tableWidth / editorWidth) * 100);
}

/**
 * Handle table resize
 * @param {MouseEvent} e - Mouse event
 * @param {Object} editor - Quill editor instance
 */
function handleTableResize(e, editor) {
  if (!isDraggingTable || !resizingTable) return;
  
  const dx = e.clientX - tableResizeStartX;
  const editorWidth = getEditorContentWidth(editor);
  
  let newWidth = tableResizeStartWidth + dx;
  newWidth = Math.max(TABLE_MIN_WIDTH, Math.min(newWidth, editorWidth));
  
  const percent = Math.round((newWidth / editorWidth) * 100);
  
  resizingTable.style.width = `${newWidth}px`;
  
  const wrapper = resizingTable.closest('.ql-table-wrapper');
  if (wrapper) {
    wrapper.style.width = `${newWidth}px`;
  }
  
  resizeTooltip.textContent = `${percent}%`;
  resizeTooltip.style.left = `${e.clientX}px`;
  resizeTooltip.style.top = `${e.clientY - 10}px`;
  resizeTooltip.classList.add('visible');
}

/**
 * Find the table element from a cell or any child element
 * @param {Element} element - Element to search from
 * @param {Object} editor - Quill editor instance
 * @returns {Element|null} Table element or null
 */
function findParentTable(element, editor) {
  let current = element;
  while (current && current !== editor.root) {
    if (current.tagName === 'TABLE') {
      return current;
    }
    current = current.parentElement;
  }
  return null;
}

/**
 * Toggle header class on table
 * @param {Element} table - Table element
 * @param {boolean} hasHeader - Whether to add header class
 * @param {Object} editor - Quill editor instance
 */
function toggleTableHeader(table, hasHeader, editor) {
  if (hasHeader) {
    table.classList.add('table-with-header');
  } else {
    table.classList.remove('table-with-header');
  }
  sendContentChange(editor);
}

/**
 * Show table header popup menu
 * @param {Element} table - Table element
 * @param {number} x - X position
 * @param {number} y - Y position
 * @param {Object} editor - Quill editor instance
 */
function showTableHeaderPopup(table, x, y, editor) {
  hideTableHeaderPopup();
  
  tableHeaderPopup = document.createElement('div');
  tableHeaderPopup.style.cssText = `
    position: fixed;
    left: ${x}px;
    top: ${y}px;
    background: white;
    border: 1px solid #e5e0da;
    border-radius: 8px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.15);
    z-index: 1000;
    overflow: hidden;
  `;
  
  const hasHeader = table.classList.contains('table-with-header');
  
  tableHeaderPopup.innerHTML = `
    <div class="table-header-toggle" style="display: flex; align-items: center; gap: 8px; padding: 10px 14px; cursor: pointer; font-size: 13px; color: #2c2825; white-space: nowrap;">
      <input type="checkbox" id="tableHeaderCheckbox" style="width: 16px; height: 16px; accent-color: #c45d35; cursor: pointer;" ${hasHeader ? 'checked' : ''}>
      <label for="tableHeaderCheckbox" style="cursor: pointer;">Mark first row as header</label>
    </div>
  `;
  
  document.body.appendChild(tableHeaderPopup);
  
  const checkbox = tableHeaderPopup.querySelector('#tableHeaderCheckbox');
  const toggleDiv = tableHeaderPopup.querySelector('.table-header-toggle');
  
  const handleToggle = (e) => {
    e.stopPropagation();
    const newValue = !table.classList.contains('table-with-header');
    checkbox.checked = newValue;
    toggleTableHeader(table, newValue, editor);
  };
  
  checkbox.addEventListener('change', (e) => {
    toggleTableHeader(table, e.target.checked, editor);
  });
  
  toggleDiv.addEventListener('click', handleToggle);
  
  setTimeout(() => {
    document.addEventListener('click', hideTableHeaderPopup, { once: true });
  }, 10);
}

/**
 * Hide table header popup
 */
function hideTableHeaderPopup() {
  if (tableHeaderPopup) {
    tableHeaderPopup.remove();
    tableHeaderPopup = null;
  }
}

/**
 * Set up table resize functionality
 * @param {Object} editor - Quill editor instance
 */
export function setupTableResize(editor) {
  tableDragIcon = document.getElementById('tableDragIcon');
  resizeTooltip = document.getElementById('resizeTooltip');
  
  // Table hover events
  editor.root.addEventListener('mouseover', (e) => {
    const table = e.target.tagName === 'TABLE' ? e.target : e.target.closest('table');
    if (table && !isDraggingTable) {
      showTableDragIcon(table);
    }
  }, true);
  
  editor.root.addEventListener('mouseout', (e) => {
    const table = e.target.tagName === 'TABLE' ? e.target : e.target.closest('table');
    if (table) {
      const toElement = e.relatedTarget;
      if (toElement !== tableDragIcon && !tableDragIcon.contains(toElement) && !table.contains(toElement)) {
        hideTableDragIcon();
      }
    }
  }, true);
  
  // Keep table drag icon visible when hovering over it
  tableDragIcon.addEventListener('mouseenter', () => {
    if (hoveredTable) {
      tableDragIcon.classList.add('visible');
    }
  });
  
  tableDragIcon.addEventListener('mouseleave', () => {
    if (!isDraggingTable) {
      hideTableDragIcon();
    }
  });
  
  // Table drag icon mousedown - start resize
  tableDragIcon.addEventListener('mousedown', (e) => {
    if (!hoveredTable) return;
    
    isDraggingTable = true;
    resizingTable = hoveredTable;
    tableResizeStartX = e.clientX;
    tableResizeStartWidth = resizingTable.offsetWidth;
    
    tableDragIcon.classList.remove('visible');
    e.preventDefault();
    e.stopPropagation();
  });
  
  // Mouse move for table resize
  document.addEventListener('mousemove', (e) => handleTableResize(e, editor));
  
  // Detect quill-table-better cell/column resize
  editor.root.addEventListener('mousedown', (e) => {
    const isResizeHandle = e.target.classList.contains('ql-table-better-col-tool') ||
                          e.target.classList.contains('ql-table-better-row-tool') ||
                          e.target.closest('.ql-table-better-col-tool') ||
                          e.target.closest('.ql-table-better-row-tool') ||
                          e.target.classList.contains('ql-table-better-selection-line') ||
                          e.target.closest('.ql-table-better-selection-line');
    
    if (isResizeHandle) {
      isTableBetterResizing = true;
      const tables = editor.root.querySelectorAll('table');
      lastTableHTML = Array.from(tables).map(t => t.outerHTML).join('');
      console.log('Table-better resize started');
    }
  }, true);
  
  // Detect when quill-table-better finishes resizing
  document.addEventListener('mouseup', () => {
    if (isTableBetterResizing) {
      isTableBetterResizing = false;
      
      setTimeout(() => {
        const tables = editor.root.querySelectorAll('table');
        const currentTableHTML = Array.from(tables).map(t => t.outerHTML).join('');
        
        if (currentTableHTML !== lastTableHTML) {
          console.log('Table-better resize complete, sending update');
          const updatedHtml = editor.root.innerHTML;
          sendContentChangeImmediate(editor, updatedHtml);
        }
      }, 50);
    }
  });
  
  // MutationObserver to catch column width changes
  const tableResizeObserver = new MutationObserver((mutations) => {
    let tableChanged = false;
    
    mutations.forEach(mutation => {
      if (mutation.type === 'attributes' && mutation.attributeName === 'style') {
        const target = mutation.target;
        if (target.tagName === 'COL' || 
            target.tagName === 'TD' || 
            target.tagName === 'TH' || 
            target.tagName === 'TABLE' ||
            target.tagName === 'COLGROUP') {
          tableChanged = true;
        }
      }
      if (mutation.type === 'attributes' && mutation.attributeName === 'width') {
        tableChanged = true;
      }
    });
    
    if (tableChanged && !isTableBetterResizing && !isDraggingTable) {
      clearTimeout(tableResizeObserver.updateTimer);
      tableResizeObserver.updateTimer = setTimeout(() => {
        console.log('Table mutation detected, sending update');
        const updatedHtml = editor.root.innerHTML;
        sendContentChangeImmediate(editor, updatedHtml);
      }, 100);
    }
  });
  
  tableResizeObserver.observe(editor.root, {
    attributes: true,
    attributeFilter: ['style', 'width'],
    subtree: true
  });
  
  // Mouse up - finish table resize
  document.addEventListener('mouseup', () => {
    if (isDraggingTable && resizingTable) {
      const percent = getTablePercent(resizingTable, editor);
      resizingTable.setAttribute('data-width-percent', percent);
      
      const editorWidth = getEditorContentWidth(editor);
      const finalWidth = (editorWidth * percent) / 100;
      resizingTable.style.width = `${finalWidth}px`;
      
      const wrapper = resizingTable.closest('.ql-table-wrapper');
      if (wrapper) {
        wrapper.style.width = `${finalWidth}px`;
      }
      
      resizeTooltip.classList.remove('visible');
      
      console.log('Table resize complete:', percent + '%', 'Width:', finalWidth + 'px');
      
      setTimeout(() => {
        const updatedHtml = editor.root.innerHTML;
        sendContentChangeImmediate(editor, updatedHtml);
        console.log('Sent immediate HTML update to Flutter');
      }, 10);
      
      isDraggingTable = false;
      resizingTable = null;
    }
  });
  
  // Context menu for table header toggle
  editor.root.addEventListener('contextmenu', (e) => {
    const table = findParentTable(e.target, editor);
    if (table) {
      e.preventDefault();
      showTableHeaderPopup(table, e.clientX, e.clientY, editor);
    }
  });
  
  // Keyboard shortcut (Ctrl/Cmd + Shift + H) to toggle header
  document.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'H') {
      const selection = editor.getSelection();
      if (selection) {
        const [leaf] = editor.getLeaf(selection.index);
        if (leaf && leaf.domNode) {
          const table = findParentTable(leaf.domNode, editor);
          if (table) {
            e.preventDefault();
            const hasHeader = table.classList.contains('table-with-header');
            toggleTableHeader(table, !hasHeader, editor);
          }
        }
      }
    }
  });
}

