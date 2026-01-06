# How to Disable All Caching

This guide explains how to completely disable caching in the Quill Web Editor project for development purposes.

> **Current Status:** Caching is **currently disabled** by default in this project. This document explains the current configuration and how to re-enable caching if needed.

## Current Configuration Status

✅ **Caching is currently DISABLED** - The project is configured for no-cache mode:
- All cache durations set to `0` in `serve.py`
- ETag generation disabled
- Service worker unregistration code active in `index.html`
- All responses include no-cache headers

## Quick Steps (If Caching is Re-enabled)

If you've re-enabled caching and want to disable it again:

1. **Rebuild Flutter app without service worker:**
   ```bash
   cd example
   flutter build web --no-service-worker
   ```

2. **Restart the Python server:**
   ```bash
   python3 serve.py
   ```

3. **Clear browser cache:**
   - Open DevTools (F12)
   - Right-click the refresh button → "Empty Cache and Hard Reload"
   - Or use: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)

## What Has Been Disabled

### 1. Service Worker Caching
- ✅ Service worker unregistration code added to `index.html`
- ✅ Cache API cleared on page load
- ✅ Build with `--no-service-worker` flag

### 2. Server-Side Caching
- ✅ All cache durations set to 0 in `serve.py`
- ✅ ETag generation disabled
- ✅ Conditional requests (304 Not Modified) disabled
- ✅ All responses include `no-cache` headers

### 3. Browser Caching
- ✅ HTML meta tags set to `no-cache`
- ✅ Cache-Control headers: `no-cache, no-store, must-revalidate, max-age=0`
- ✅ Pragma: `no-cache`
- ✅ Expires: `0`

## Files Modified

### `example/web/index.html`
Added service worker unregistration and cache clearing:
```javascript
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for(let registration of registrations) {
      registration.unregister();
    }
  });
  if ('caches' in window) {
    caches.keys().then(function(names) {
      for (let name of names) {
        caches.delete(name);
      }
    });
  }
}
```

### `example/serve.py`
- All `CACHE_DURATIONS` set to `0`
- ETag generation commented out
- Conditional request checks disabled
- All responses include aggressive no-cache headers

## Build Command

Always build without service worker:
```bash
flutter build web --no-service-worker
```

## Verification

After making changes, verify caching is disabled:

1. **Check Network Tab:**
   - Open Chrome DevTools → Network tab
   - Look for resources - they should show actual file sizes, not "(ServiceWorker)" or "(disk cache)"
   - Status should be `200` (not `304`)

2. **Check Response Headers:**
   - Click any resource in Network tab
   - Check "Response Headers"
   - Should see:
     ```
     Cache-Control: no-cache, no-store, must-revalidate, max-age=0
     Pragma: no-cache
     Expires: 0
     ```

3. **Check Service Worker:**
   - DevTools → Application → Service Workers
   - Should show "No service workers registered"

## Re-enabling Caching

To re-enable caching later:

1. **Restore cache durations in `serve.py`:**
   ```python
   CACHE_DURATIONS = {
       '.html': 0,
       '.js': 31536000,      # 1 year
       '.css': 31536000,
       # ... etc
   }
   ```

2. **Uncomment ETag code in `serve.py`**

3. **Remove service worker unregistration from `index.html`**

4. **Build normally:**
   ```bash
   flutter build web  # Without --no-service-worker
   ```

## Browser DevTools Settings

For complete no-cache testing, also enable:

1. **Chrome DevTools:**
   - Network tab → Check "Disable cache" checkbox
   - This prevents browser from caching even with no-cache headers

2. **Firefox DevTools:**
   - Network tab → Settings → Check "Disable HTTP Cache"

## Notes

- ⚠️ **Performance Impact**: Disabling caching will make every page load slower
- ⚠️ **Bandwidth Usage**: All resources will be downloaded on every request
- ✅ **Always Fresh**: You'll always get the latest version of all files
- ✅ **Development Only**: Use this only during development, not in production

## Troubleshooting

### Service Worker Still Active

If you still see "(ServiceWorker)" in Network tab:

1. **Unregister manually:**
   - DevTools → Application → Service Workers → Unregister

2. **Clear all storage:**
   - DevTools → Application → Storage → Clear site data

3. **Hard refresh:**
   - `Ctrl+Shift+R` or `Cmd+Shift+R`

### Files Still Cached

1. **Check server is running updated `serve.py`**
2. **Verify build used `--no-service-worker`**
3. **Clear browser cache completely**
4. **Use incognito/private window**

### 304 Responses Still Appearing

1. **Verify ETag code is commented out in `serve.py`**
2. **Check response headers include `no-cache`**
3. **Restart Python server**

---

**Remember**: After disabling caching, always rebuild with `flutter build web --no-service-worker` and restart your server!

