# Caching Quick Reference

Quick reference guide for caching configuration in Quill Web Editor.

## Current Status

🟢 **Caching is DISABLED** (No-Cache Mode)
- All resources fetched fresh on every request
- No service worker caching
- No browser caching
- No server-side caching

## File Locations

| File | Purpose | Current State |
|------|---------|---------------|
| `example/serve.py` | Server-side caching configuration | All durations = 0 (no cache) |
| `example/web/index.html` | Client-side cache control | Service worker disabled, no-cache meta tags |
| `example/build/web/index.html` | Built HTML | Generated from source |

## Switching Modes

### Enable Caching (For Better Performance)

1. **Edit `example/serve.py`:**
   ```python
   CACHE_DURATIONS = {
       '.html': 0,
       '.js': 31536000,      # 1 year
       '.css': 31536000,
       '.wasm': 31536000,
       '.json': 3600,        # 1 hour
       # ... images/fonts: 31536000
   }
   ```

2. **Uncomment ETag code in `serve.py`** (search for commented sections)

3. **Remove service worker unregistration from `index.html`** (optional)

4. **Build:**
   ```bash
   flutter build web  # Without --no-service-worker
   ```

5. **Restart server:**
   ```bash
   python3 serve.py
   ```

### Disable Caching (Current State)

1. **Edit `example/serve.py`:**
   ```python
   CACHE_DURATIONS = {
       '.html': 0,
       '.js': 0,             # All set to 0
       '.css': 0,
       # ... all 0
   }
   ```

2. **Comment out ETag code in `serve.py`**

3. **Add service worker unregistration to `index.html`** (already present)

4. **Build:**
   ```bash
   flutter build web --no-service-worker
   ```

5. **Restart server**

## Verification

### Check if Caching is Disabled

**Network Tab:**
- Resources show actual file sizes (not "(ServiceWorker)" or "(disk cache)")
- Status codes are `200` (not `304`)
- Response headers include: `Cache-Control: no-cache, no-store...`

**Service Workers:**
- DevTools → Application → Service Workers
- Should show "No service workers registered"

### Check if Caching is Enabled

**Network Tab:**
- Resources may show "(ServiceWorker)" or "(disk cache)"
- Status codes may be `304` for unchanged files
- Response headers include: `Cache-Control: public, max-age=...`

## Cache Duration Reference

| File Type | No Cache | With Cache | Rationale |
|-----------|----------|------------|------------|
| HTML | 0 | 0 | Entry point, changes frequently |
| JS/CSS/WASM | 0 | 31536000 (1 year) | Versioned in production |
| JSON | 0 | 3600 (1 hour) | Config may change |
| Images/Fonts | 0 | 31536000 (1 year) | Rarely change |

## Build Commands

```bash
# No cache mode (current)
flutter build web --no-service-worker

# With cache mode
flutter build web
```

## Related Documentation

- **[CACHING_IMPLEMENTATION.md](CACHING_IMPLEMENTATION.md)** - Complete caching strategy documentation
- **[DISABLE_CACHING.md](DISABLE_CACHING.md)** - Detailed guide for disabling caching

## Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Still seeing cached files | Clear browser cache (Ctrl+Shift+R) |
| Service worker still active | Unregister in DevTools → Application → Service Workers |
| 304 responses appearing | Verify ETag code is commented out in `serve.py` |
| Changes not appearing | Rebuild and restart server |

---

**Last Updated:** Current configuration has caching disabled for development.



