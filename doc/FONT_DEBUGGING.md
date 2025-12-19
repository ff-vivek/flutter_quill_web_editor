# Font Loading Debugging Guide

## Overview

This guide helps identify which font file is causing OTS parsing errors like:
```
OTS parsing error: invalid sfntVersion: 1008813135
```

## Font Monitor

A font monitoring utility has been added to track font loading errors. It's automatically enabled in all HTML files (`quill_editor.html` and `quill_viewer.html`).

### How It Works

The font monitor uses multiple methods to track font loading:

1. **Network Request Monitoring**: Intercepts `fetch()` and `XMLHttpRequest` calls for font files
2. **Font Loading API**: Uses `document.fonts` API to track font loading status
3. **CSS @font-face Parsing**: Scans stylesheets for `@font-face` declarations
4. **Console Error Interception**: Catches OTS parsing errors and identifies the failing font

### Using the Font Monitor

1. **Open your browser's Developer Console** (F12 or Cmd+Option+I)
2. **Load the page** with the Quill editor
3. **Look for logs** prefixed with `[Font Monitor]`

### What to Look For

#### Successful Font Loading
```
[Font Monitor] Font request successful: ../fonts/Mulish-Regular.ttf Status: 200
[Font Monitor] ✓ Font loaded: Mulish (400, normal)
```

#### Failed Font Loading
```
[Font Monitor] ✗✗✗ FONT LOADING ERROR ✗✗✗
[Font Monitor] Font family: Mulish
[Font Monitor] Font weight: 400
[Font Monitor] Font style: normal
[Font Monitor] Font source: url('../fonts/Mulish-Regular.ttf')
[Font Monitor] Font status: error
```

#### OTS Parsing Error Detection
```
[Font Monitor] ✗✗✗ OTS PARSING ERROR DETECTED ✗✗✗
[Font Monitor] Error message: OTS parsing error: invalid sfntVersion: 1008813135
[Font Monitor] Font URLs that were requested:
[Font Monitor]   - ../fonts/Mulish-Regular.ttf
[Font Monitor]   - ../fonts/Mulish-Bold.ttf
[Font Monitor] Failed fonts:
[Font Monitor]   - Mulish 400 normal Source: url('../fonts/Mulish-Regular.ttf')
```

### Font Loading Summary

After 3 seconds, the monitor logs a summary:
```
[Font Monitor] === Font Loading Summary ===
[Font Monitor] Total font URLs detected: 18
[Font Monitor] Font status:
[Font Monitor]   - Loaded: 16
[Font Monitor]   - Loading: 0
[Font Monitor]   - Error/Unloaded: 2
[Font Monitor] ⚠️ Some fonts failed to load!
```

## Common Issues and Solutions

### Issue 1: Font File Not Found (404)
**Symptoms:**
- `Font request failed: Status: 404`
- Font URL resolves to HTML error page

**Solution:**
- Check font file paths in CSS (`mulish-font.css`)
- Verify files exist at the specified locations
- Check Flutter asset paths if using Flutter web

### Issue 2: Corrupted Font File
**Symptoms:**
- `OTS parsing error: invalid sfntVersion`
- Font loads but fails validation

**Solution:**
- Re-download the font file from a trusted source
- Verify file integrity: `file path/to/font.ttf` should show "TrueType font data"
- Check file size matches expected size

### Issue 3: Wrong Content-Type
**Symptoms:**
- Font request succeeds but fails to load
- Server returns HTML instead of font file

**Solution:**
- Check server response headers: `Content-Type` should be `font/ttf` or `application/font-sfnt`
- Verify server configuration for `.ttf` files

### Issue 4: CORS Issues
**Symptoms:**
- Font request blocked
- Cross-origin errors in console

**Solution:**
- Ensure CORS headers are set correctly
- Use same-origin fonts or configure CORS properly

## Manual Testing

### Test Individual Font Files

1. **Open font URL directly in browser:**
   ```
   http://your-domain.com/fonts/Mulish-Regular.ttf
   ```

2. **Expected:** Font file downloads or displays
3. **If HTML/text appears:** Server misconfiguration

### Check Font File Integrity

```bash
# Check file type
file example/assets/fonts/Mulish-Regular.ttf

# Expected output:
# Mulish-Regular.ttf: TrueType font data

# Check file size (should be > 0 and reasonable)
ls -lh example/assets/fonts/*.ttf
```

### Validate CSS Paths

Check that font URLs in CSS resolve correctly:
- `../fonts/Mulish-Regular.ttf` → Should resolve relative to CSS file location
- `../../assets/fonts/Mulish-Regular.ttf` → Should resolve relative to web root

## Browser Network Tab

1. Open DevTools → Network tab
2. Filter by "Font" or search for `.ttf`
3. Check each font request:
   - **Status:** Should be 200 (not 404, 500, etc.)
   - **Type:** Should be "font" (not "document" or "text/html")
   - **Size:** Should match actual file size
   - **Preview:** Should show font data (not HTML)

## Disabling Font Monitor

To disable font monitoring (for production), remove or comment out:
```javascript
import { monitorFontLoading } from './js/font-monitor.js';
monitorFontLoading();
```

## Additional Resources

- [MDN: Font Loading API](https://developer.mozilla.org/en-US/docs/Web/API/FontFace)
- [OTS (OpenType Sanitizer) Documentation](https://github.com/khaledhosny/ots)
- [Web Font Loading Best Practices](https://web.dev/font-best-practices/)

