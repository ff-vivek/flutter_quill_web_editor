/**
 * Font Loading Monitor
 * ====================
 * Tracks font loading errors to identify problematic font files
 */

/**
 * Monitor font loading errors
 */
export function monitorFontLoading() {
  try {
    console.log('[Font Monitor] Starting font loading monitoring...');
    
    // Track all font URLs being loaded
    const fontUrls = new Set();
    
    // Method 1: Monitor network requests for font files
    const originalFetch = window.fetch;
  window.fetch = function(...args) {
    const url = args[0];
    if (typeof url === 'string' && (url.includes('.ttf') || url.includes('.otf') || url.includes('.woff'))) {
      console.log('[Font Monitor] Font file request detected:', url);
      fontUrls.add(url);
      
      return originalFetch.apply(this, args)
        .then(response => {
          if (!response.ok) {
            console.error('[Font Monitor] Font request failed:', url, 'Status:', response.status, response.statusText);
          } else {
            console.log('[Font Monitor] Font request successful:', url, 'Status:', response.status);
          }
          return response;
        })
        .catch(error => {
          console.error('[Font Monitor] Font fetch error:', url, error);
          throw error;
        });
    }
    return originalFetch.apply(this, args);
    };
    
    // Method 2: Use Font Loading API to track font loading
    if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(() => {
      console.log('[Font Monitor] Font loading complete. Checking loaded fonts...');
      
      // Check all font faces
      const fontFaces = Array.from(document.fonts);
      console.log('[Font Monitor] Total font faces:', fontFaces.length);
      
      fontFaces.forEach((fontFace, index) => {
        try {
          const status = fontFace.status;
          const family = fontFace.family;
          const style = fontFace.style;
          const weight = fontFace.weight;
          
          if (status === 'loaded') {
            console.log(`[Font Monitor] ✓ Font loaded: ${family} (${weight}, ${style})`);
          } else if (status === 'loading') {
            console.warn(`[Font Monitor] ⏳ Font still loading: ${family} (${weight}, ${style})`);
          } else if (status === 'error') {
            // This is a real error - font failed to load
            console.error(`[Font Monitor] ✗✗✗ FONT ERROR: ${family} (${weight}, ${style})`);
            try {
              console.error(`[Font Monitor]   Source: ${fontFace.src}`);
            } catch (e) {
              // Ignore if src is not accessible
            }
          } else if (status === 'unloaded') {
            // Unloaded is normal - fonts are only loaded when used on the page
            // Only log if verbose mode or if it's a font we're specifically tracking
            // (commented out to reduce noise)
            // console.debug(`[Font Monitor] Font unloaded (normal): ${family} (${weight}, ${style})`);
          } else {
            console.error(`[Font Monitor] ✗ Unknown font status: ${family} (${weight}, ${style}) - Status: ${status}`);
          }
        } catch (e) {
          console.error(`[Font Monitor] Error checking font face ${index}:`, e.message);
        }
      });
      
      // Summary of font statuses
      const loaded = fontFaces.filter(f => f.status === 'loaded').length;
      const loading = fontFaces.filter(f => f.status === 'loading').length;
      const error = fontFaces.filter(f => f.status === 'error').length;
      const unloaded = fontFaces.filter(f => f.status === 'unloaded').length;
      
      console.log(`[Font Monitor] Font status summary: ${loaded} loaded, ${loading} loading, ${error} errors, ${unloaded} unloaded (normal)`);
      
      if (error > 0) {
        console.error(`[Font Monitor] ⚠️ ${error} font(s) failed to load!`);
        const errorFonts = fontFaces.filter(f => f.status === 'error');
        errorFonts.forEach(f => {
          try {
            console.error(`[Font Monitor]   - ${f.family} (${f.weight}, ${f.style}) - Source: ${f.src}`);
          } catch (e) {
            console.error(`[Font Monitor]   - ${f.family} (${f.weight}, ${f.style})`);
          }
        });
      }
    }).catch(err => {
      console.error('[Font Monitor] Error in fonts.ready:', err);
    });
    
    // Monitor font loading errors
    // Note: FontFaceSet events may have different structures in different browsers
    // Wrap in try-catch to prevent errors from breaking the script
    try {
      document.fonts.addEventListener('loading', (event) => {
        try {
          // Some browsers may not have fontface property, so we'll just log the event
          if (event && typeof event === 'object') {
            const fontface = event.fontface || event.fontfaces?.[0] || (event.target && event.target.fontface);
            if (fontface && fontface.family) {
              console.log('[Font Monitor] Font loading started:', fontface.family, fontface.weight, fontface.style);
            } else {
              console.log('[Font Monitor] Font loading started (event received)');
            }
          }
        } catch (e) {
          // Silently handle errors to prevent breaking the page
          console.log('[Font Monitor] Font loading started (event received, details unavailable)');
        }
      });
    } catch (e) {
      console.warn('[Font Monitor] Could not add loading listener:', e.message);
    }
    
    try {
      document.fonts.addEventListener('loadingdone', (event) => {
        try {
          if (event && typeof event === 'object') {
            const fontface = event.fontface || event.fontfaces?.[0] || (event.target && event.target.fontface);
            if (fontface && fontface.family) {
              console.log('[Font Monitor] Font loading done:', fontface.family, fontface.weight, fontface.style);
            } else {
              console.log('[Font Monitor] Font loading done (event received)');
            }
          }
        } catch (e) {
          console.log('[Font Monitor] Font loading done (event received, details unavailable)');
        }
      });
    } catch (e) {
      console.warn('[Font Monitor] Could not add loadingdone listener:', e.message);
    }
    
    try {
      document.fonts.addEventListener('loadingerror', (event) => {
        console.error('[Font Monitor] ✗✗✗ FONT LOADING ERROR ✗✗✗');
        try {
          // Try different possible event structures
          if (event && typeof event === 'object') {
            const fontface = event.fontface || event.fontfaces?.[0] || (event.target && event.target.fontface);
            
            if (fontface && fontface.family) {
              console.error('[Font Monitor] Font family:', fontface.family);
              console.error('[Font Monitor] Font weight:', fontface.weight);
              console.error('[Font Monitor] Font style:', fontface.style);
              console.error('[Font Monitor] Font source:', fontface.src);
              console.error('[Font Monitor] Font status:', fontface.status);
            }
          }
        } catch (e) {
          // Ignore errors accessing event properties
        }
        
        // Always check document.fonts for failed fonts as fallback
        try {
          if (document.fonts) {
            const failedFonts = Array.from(document.fonts).filter(f => {
              try {
                return f.status === 'error' || f.status === 'unloaded';
              } catch (e) {
                return false;
              }
            });
            if (failedFonts.length > 0) {
              console.error('[Font Monitor] Failed fonts found:');
              failedFonts.forEach(f => {
                try {
                  console.error('[Font Monitor]   -', f.family, f.weight, f.style, 'Source:', f.src);
                } catch (e) {
                  console.error('[Font Monitor]   - (font face with error)');
                }
              });
            }
          }
        } catch (e) {
          console.error('[Font Monitor] Could not check failed fonts:', e.message);
        }
      });
    } catch (e) {
      console.warn('[Font Monitor] Could not add loadingerror listener:', e.message);
    }
    }
    
    // Method 3: Monitor CSS @font-face loading via style sheets
    const styleSheets = Array.from(document.styleSheets);
  console.log('[Font Monitor] Found', styleSheets.length, 'style sheets');
  
  styleSheets.forEach((sheet, sheetIndex) => {
    try {
      const rules = Array.from(sheet.cssRules || []);
      rules.forEach((rule, ruleIndex) => {
        if (rule instanceof CSSFontFaceRule) {
          const fontFamily = rule.style.fontFamily;
          const src = rule.style.src;
          console.log('[Font Monitor] @font-face found in stylesheet', sheetIndex + ':', {
            family: fontFamily,
            src: src,
            stylesheet: sheet.href || 'inline'
          });
          
          // Extract URLs from src
          if (src) {
            const urlMatches = src.match(/url\(['"]?([^'"]+)['"]?\)/g);
            if (urlMatches) {
              urlMatches.forEach(match => {
                const url = match.replace(/url\(['"]?|['"]?\)/g, '');
                console.log('[Font Monitor] Font URL from @font-face:', url);
                fontUrls.add(url);
              });
            }
          }
        }
      });
    } catch (e) {
      // Cross-origin stylesheet, can't access rules
      console.log('[Font Monitor] Cannot access stylesheet', sheetIndex, ':', sheet.href, '(cross-origin)');
    }
    });
    
    // Method 4: Intercept XMLHttpRequest for font files
    const originalOpen = XMLHttpRequest.prototype.open;
  const originalSend = XMLHttpRequest.prototype.send;
  
  XMLHttpRequest.prototype.open = function(method, url, ...rest) {
    if (typeof url === 'string' && (url.includes('.ttf') || url.includes('.otf') || url.includes('.woff'))) {
      console.log('[Font Monitor] XHR font request:', method, url);
      fontUrls.add(url);
      
      this.addEventListener('load', function() {
        if (this.status >= 200 && this.status < 300) {
          console.log('[Font Monitor] XHR font loaded:', url, 'Status:', this.status);
        } else {
          console.error('[Font Monitor] XHR font failed:', url, 'Status:', this.status);
        }
      });
      
      this.addEventListener('error', function() {
        console.error('[Font Monitor] XHR font error:', url);
      });
    }
    return originalOpen.call(this, method, url, ...rest);
    };
    
    // Method 5: Check for OTS parsing errors in console
    const originalError = console.error;
  console.error = function(...args) {
    const message = args.join(' ');
    if (message.includes('OTS parsing error') || message.includes('invalid sfntVersion') || message.includes('Failed to decode downloaded font')) {
      console.error('[Font Monitor] ✗✗✗ OTS PARSING ERROR DETECTED ✗✗✗');
      console.error('[Font Monitor] Error message:', ...args);
      
      // Try to extract font URL from error message
      const urlMatch = message.match(/https?:\/\/[^\s]+\.(ttf|otf|woff|woff2)/i);
      if (urlMatch) {
        console.error('[Font Monitor] ⚠️ PROBLEMATIC FONT FILE IDENTIFIED:', urlMatch[0]);
        fontUrls.add(urlMatch[0]);
      }
      
      // Also check for relative paths
      const relativeMatch = message.match(/[\w\/\-]+\.(ttf|otf|woff|woff2)/i);
      if (relativeMatch && !urlMatch) {
        console.error('[Font Monitor] ⚠️ PROBLEMATIC FONT FILE (relative path):', relativeMatch[0]);
      }
      
      // Try to identify which font URL might be causing this
      console.error('[Font Monitor] All font URLs that were requested:');
      fontUrls.forEach(url => {
        console.error('[Font Monitor]   -', url);
      });
      
      // Check current font loading state - only check for actual errors, not unloaded
      if (document.fonts) {
        const failedFonts = Array.from(document.fonts).filter(f => f.status === 'error');
        if (failedFonts.length > 0) {
          console.error('[Font Monitor] Fonts with ERROR status (these are problematic):');
          failedFonts.forEach(f => {
            try {
              console.error('[Font Monitor]   ✗', f.family, f.weight, f.style, 'Source:', f.src);
            } catch (e) {
              console.error('[Font Monitor]   ✗', f.family, '(error accessing details)');
            }
          });
        }
      }
    }
    return originalError.apply(console, args);
    };
    
    // Log summary after a delay
    setTimeout(() => {
    console.log('[Font Monitor] === Font Loading Summary ===');
    console.log('[Font Monitor] Total font URLs detected:', fontUrls.size);
    fontUrls.forEach(url => {
      console.log('[Font Monitor]   -', url);
    });
    
    if (document.fonts) {
      const allFonts = Array.from(document.fonts);
      const loaded = allFonts.filter(f => f.status === 'loaded').length;
      const loading = allFonts.filter(f => f.status === 'loading').length;
      const error = allFonts.filter(f => f.status === 'error').length;
      const unloaded = allFonts.filter(f => f.status === 'unloaded').length;
      
      console.log('[Font Monitor] === Final Font Status Summary ===');
      console.log('[Font Monitor]   - Loaded:', loaded);
      console.log('[Font Monitor]   - Loading:', loading);
      console.log('[Font Monitor]   - Errors:', error, '(these are problematic)');
      console.log('[Font Monitor]   - Unloaded:', unloaded, '(normal - fonts load when used)');
      
      if (error > 0) {
        console.error('[Font Monitor] ⚠️⚠️⚠️ FONTS WITH ERRORS ⚠️⚠️⚠️');
        const errorFonts = allFonts.filter(f => f.status === 'error');
        errorFonts.forEach(f => {
          try {
            console.error(`[Font Monitor]   ✗ ${f.family} (${f.weight}, ${f.style})`);
            console.error(`[Font Monitor]     Source: ${f.src}`);
          } catch (e) {
            console.error(`[Font Monitor]   ✗ ${f.family} (error accessing details)`);
          }
        });
      }
    }
    }, 3000);
    
    console.log('[Font Monitor] Font monitoring initialized');
  } catch (error) {
    console.error('[Font Monitor] Fatal error initializing font monitor:', error);
    // Don't throw - we want the page to continue working even if monitoring fails
  }
}

