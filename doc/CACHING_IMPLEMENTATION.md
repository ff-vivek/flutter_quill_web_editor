# Caching Implementation in Quill Web Editor

This document describes the comprehensive caching strategy implemented in the Quill Web Editor Flutter project. The caching system is designed to optimize performance while ensuring users always have access to the latest application code.

## Table of Contents

1. [Overview](#overview)
2. [Server-Side Caching](#server-side-caching)
3. [Client-Side Caching](#client-side-caching)
4. [Cache Busting Strategies](#cache-busting-strategies)
5. [ETag and Conditional Requests](#etag-and-conditional-requests)
6. [Cache Duration Strategy](#cache-duration-strategy)
7. [Development vs Production](#development-vs-production)
8. [Disabling Caching](#disabling-caching)
9. [Best Practices](#best-practices)

---

## Overview

The Quill Web Editor implements a multi-layered caching strategy:

- **Server-Side Caching**: HTTP cache headers with ETag support
- **Client-Side Caching**: HTML meta tags for development
- **Cache Busting**: Timestamp-based query parameters for dynamic assets
- **Conditional Requests**: ETag and Last-Modified headers for efficient updates

This approach ensures:
- Fast loading times for static assets (JS, CSS, fonts, images)
- Always-fresh HTML content during development
- Efficient bandwidth usage through 304 Not Modified responses
- Optimal performance in production environments

---

## Server-Side Caching

### Implementation: `serve.py`

The project includes a custom Python HTTP server (`example/serve.py`) that implements intelligent caching for development and testing.

#### Key Features

1. **File-Type Based Cache Durations**
2. **ETag Generation**
3. **Conditional Request Handling**
4. **CORS Support**

### Cache Duration Configuration

The server uses different cache durations based on file types. **Note:** The current configuration has caching disabled (all durations set to 0) for development. To enable caching, update the values below:

**Current Configuration (No-Cache Mode):**
```python
CACHE_DURATIONS = {
    '.html': 0,           # No cache for HTML
    '.js': 0,             # No cache for JS files
    '.css': 0,            # No cache for CSS files
    '.wasm': 0,           # No cache for WASM files
    '.json': 0,           # No cache for JSON files
    '.png': 0,            # No cache for images
    '.jpg': 0,
    '.jpeg': 0,
    '.gif': 0,
    '.svg': 0,
    '.ico': 0,
    '.woff': 0,           # No cache for fonts
    '.woff2': 0,
    '.ttf': 0,
    '.eot': 0,
    '.otf': 0,
}
```

**Recommended Configuration (With Caching):**
```python
CACHE_DURATIONS = {
    '.html': 0,           # No cache for HTML (always check for updates)
    '.js': 31536000,      # 1 year for JS files (31,536,000 seconds)
    '.css': 31536000,     # 1 year for CSS files
    '.wasm': 31536000,    # 1 year for WASM files
    '.json': 3600,        # 1 hour for JSON files
    '.png': 31536000,     # 1 year for images
    '.jpg': 31536000,
    '.jpeg': 31536000,
    '.gif': 31536000,
    '.svg': 31536000,
    '.ico': 31536000,
    '.woff': 31536000,    # 1 year for fonts
    '.woff2': 31536000,
    '.ttf': 31536000,
    '.eot': 31536000,
    '.otf': 31536000,
}
```

**Rationale:**
- **HTML (0 seconds)**: HTML files contain the entry point and may change frequently. No caching ensures users always get the latest version.
- **JS/CSS/WASM (1 year)**: These files are typically versioned or hashed in production builds. Long cache duration maximizes performance.
- **JSON (1 hour)**: Configuration files may change but not as frequently as HTML.
- **Images/Fonts (1 year)**: Static assets that rarely change benefit from long cache durations.

### HTTP Cache Headers

**Current Configuration (No-Cache Mode):**
The server sets aggressive no-cache headers for all resources:

```python
self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate, max-age=0')
self.send_header('Pragma', 'no-cache')
self.send_header('Expires', '0')
```

**With Caching Enabled:**
The server sets appropriate `Cache-Control` headers based on file type:

```python
if cache_duration > 0:
    self.send_header('Cache-Control', f'public, max-age={cache_duration}, immutable')
else:
    self.send_header('Cache-Control', 'no-cache, must-revalidate')
```

**Header Values:**
- `public`: Resource can be cached by any cache (browser, CDN, proxy)
- `max-age={duration}`: Maximum time the resource is considered fresh
- `immutable`: Indicates the resource will never change (for versioned assets)
- `no-cache, must-revalidate`: Forces revalidation on every request
- `no-store`: Prevents storing the response in any cache

### ETag Generation

**Note:** ETag generation is currently disabled in no-cache mode. To enable, uncomment the ETag code in `serve.py`.

When enabled, ETags are generated using MD5 hash of file path and modification time:

```python
etag = hashlib.md5(f"{path}{modified_time}".encode()).hexdigest()
self.send_header('ETag', f'"{etag}"')
```

**Benefits:**
- Unique identifier for each file version
- Enables efficient conditional requests
- Changes automatically when file is modified

### Conditional Request Handling

**Note:** Conditional request handling is currently disabled in no-cache mode. The server always returns `200 OK` with fresh content. To enable conditional requests, uncomment the ETag and conditional request code in `serve.py`.

When enabled, the server handles two types of conditional requests:

#### 1. If-None-Match (ETag)

```python
if_none_match = self.headers.get('If-None-Match')
if if_none_match == etag:
    self.send_response(304)  # Not Modified
    self.end_headers()
    return
```

If the client's ETag matches the server's ETag, the server responds with `304 Not Modified`, saving bandwidth.

#### 2. If-Modified-Since

```python
if_modified_since = self.headers.get('If-Modified-Since')
if if_modified_since:
    if_modified_since_time = email.utils.parsedate_to_datetime(if_modified_since).timestamp()
    if modified_time <= if_modified_since_time:
        self.send_response(304)  # Not Modified
        self.end_headers()
        return
```

Checks if the file hasn't been modified since the client's cached version.

---

## Client-Side Caching

### HTML Meta Tags

The `index.html` file includes meta tags to prevent aggressive browser caching:

```html
<!-- No-cache directives to prevent browser caching -->
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
```

**Purpose:**
- Ensures HTML is always fetched fresh during development
- Prevents stale HTML from being served
- Works in conjunction with server-side headers

**Note:** These meta tags only affect the HTML file itself, not referenced resources (JS, CSS, etc.).

### Service Worker Disabling

The `index.html` also includes code to disable service worker caching:

```javascript
// Disable service worker caching
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for(let registration of registrations) {
      registration.unregister();
    }
  });
  // Clear all caches
  if ('caches' in window) {
    caches.keys().then(function(names) {
      for (let name of names) {
        caches.delete(name);
      }
    });
  }
}
```

This ensures that Flutter's service worker doesn't cache resources when caching is disabled.

---

## Cache Busting Strategies

### Dynamic Script Loading with Timestamp

The `index.html` uses a cache-busting technique for the Flutter bootstrap script:

```javascript
// Appending a timestamp forces the browser to reload the file
var script = document.createElement('script');
script.src = "flutter_bootstrap.js?v=" + new Date().getTime();
script.async = true;
document.body.appendChild(script);
```

**How it Works:**
1. Generates a unique query parameter using current timestamp
2. Forces browser to treat each request as a new resource
3. Bypasses browser cache for the bootstrap script
4. Ensures latest version is always loaded during development

**Example URL:**
```
flutter_bootstrap.js?v=1704456000000
```

**Benefits:**
- Simple implementation
- Effective for development
- No build-time configuration needed

**Production Considerations:**
- In production, use version hashes or build numbers instead of timestamps
- Flutter's build system can generate hashed filenames automatically

---

## ETag and Conditional Requests

### Request Flow

1. **First Request:**
   ```
   Client → Server: GET /main.dart.js
   Server → Client: 200 OK
              ETag: "abc123"
              Cache-Control: public, max-age=31536000, immutable
              [File content]
   ```

2. **Subsequent Request (File Unchanged):**
   ```
   Client → Server: GET /main.dart.js
              If-None-Match: "abc123"
   Server → Client: 304 Not Modified
              ETag: "abc123"
              [No body content - saves bandwidth]
   ```

3. **Request After File Update:**
   ```
   Client → Server: GET /main.dart.js
              If-None-Match: "abc123"
   Server → Client: 200 OK
              ETag: "def456"
              Cache-Control: public, max-age=31536000, immutable
              [Updated file content]
   ```

### Benefits

- **Bandwidth Savings**: 304 responses contain no body, saving data transfer
- **Faster Responses**: Server doesn't need to read and send file content
- **Automatic Updates**: ETag changes when file is modified, triggering refresh

---

## Cache Duration Strategy

### Development Environment

| File Type | Cache Duration | Rationale |
|-----------|---------------|-----------|
| HTML | 0 (no cache) | Frequent changes during development |
| JS/CSS | 1 year | Long cache with ETag for efficient updates |
| JSON | 1 hour | Configuration may change |
| Images/Fonts | 1 year | Rarely change |

### Production Environment

For production deployments, consider:

1. **Versioned Filenames:**
   ```
   main.dart.abc123.js  (hash-based)
   main.dart.v2.0.0.js  (version-based)
   ```

2. **CDN Configuration:**
   - Use CDN cache settings
   - Configure purge/invalidation policies
   - Set appropriate TTL values

3. **Service Workers:**
   - Flutter generates `flutter_service_worker.js` automatically
   - Handles offline caching and updates
   - Respects cache strategies defined in build

---

## Development vs Production

### Development (`serve.py`)

**Characteristics:**
- Custom Python server with caching
- HTML: No cache (always fresh)
- Static assets: Long cache with ETag
- Timestamp-based cache busting
- CORS enabled for local development

**Usage:**
```bash
cd example
python3 serve.py
# Server runs on http://localhost:8090
```

### Production

**Recommended Approach:**

1. **Use Flutter's Built-in Service Worker:**
   - Automatically generated during `flutter build web`
   - Handles asset caching and updates
   - Works offline

2. **CDN/Web Server Configuration:**
   ```nginx
   # Nginx example
   location ~* \.(js|css|wasm)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   
   location ~* \.(html)$ {
       expires 1h;
       add_header Cache-Control "public, must-revalidate";
   }
   ```

3. **Versioned Assets:**
   - Flutter can generate hashed filenames
   - Use versioned paths for cache invalidation
   - Example: `/v2.0.0/main.dart.js`

---

## Disabling Caching

For development purposes, you may want to completely disable all caching to ensure you always get the latest files. The project currently has caching disabled by default.

### Current State

The project is configured with **no-cache mode** enabled:
- ✅ All cache durations set to `0` in `serve.py`
- ✅ ETag generation disabled
- ✅ Conditional requests disabled
- ✅ Service worker unregistration code in `index.html`
- ✅ Aggressive no-cache headers on all responses

### How to Disable Caching

See the detailed guide: **[DISABLE_CACHING.md](DISABLE_CACHING.md)**

**Quick Steps:**
1. Build without service worker: `flutter build web --no-service-worker`
2. Restart Python server: `python3 serve.py`
3. Clear browser cache: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)

### How to Re-enable Caching

To re-enable caching for better performance:

1. **Update `serve.py` cache durations:**
   ```python
   CACHE_DURATIONS = {
       '.html': 0,
       '.js': 31536000,      # 1 year
       '.css': 31536000,
       # ... restore other values
   }
   ```

2. **Uncomment ETag code in `serve.py`** (search for commented ETag sections)

3. **Remove service worker unregistration from `index.html`** (optional, if you want service worker caching)

4. **Build normally:**
   ```bash
   flutter build web  # Without --no-service-worker
   ```

5. **Restart the server**

### When to Use Each Mode

| Mode | Use Case | Performance | Freshness |
|------|----------|------------|-----------|
| **No-Cache** | Active development, debugging | Slower (downloads everything) | Always latest |
| **With Cache** | Testing, production | Faster (uses cached assets) | May show cached content |

---

## Best Practices

### 1. HTML Files
- ✅ Always set short or no cache duration
- ✅ Use cache busting for critical scripts
- ✅ Include version information in HTML

### 2. Static Assets (JS, CSS, WASM)
- ✅ Use long cache durations (1 year)
- ✅ Implement ETag support
- ✅ Use versioned or hashed filenames in production
- ✅ Mark as `immutable` if versioned

### 3. JSON/Configuration Files
- ✅ Moderate cache duration (1 hour)
- ✅ Use ETag for conditional requests
- ✅ Consider versioning for breaking changes

### 4. Images and Fonts
- ✅ Long cache duration (1 year)
- ✅ Use appropriate image formats
- ✅ Consider WebP for better compression

### 5. Testing
- ✅ Test cache behavior in development
- ✅ Verify ETag functionality
- ✅ Test 304 responses
- ✅ Validate cache invalidation on updates

### 6. Monitoring
- ✅ Track cache hit rates
- ✅ Monitor 304 response frequency
- ✅ Analyze bandwidth savings
- ✅ Check for stale cache issues

---

## Implementation Files

### Server-Side
- `example/serve.py` - Custom HTTP server with caching (currently in no-cache mode)

### Client-Side
- `example/web/index.html` - HTML with cache-busting script and service worker unregistration
- `example/build/web/index.html` - Built HTML (after Flutter build)

### Configuration
- Cache durations defined in `serve.py` (currently all set to 0)
- HTML meta tags in `index.html` (no-cache directives)
- Service worker unregistration code in `index.html`
- Flutter service worker (disabled with `--no-service-worker` flag)

### Related Documentation
- **[DISABLE_CACHING.md](DISABLE_CACHING.md)** - Complete guide for disabling caching
- **[CACHING_IMPLEMENTATION.md](CACHING_IMPLEMENTATION.md)** - This document (overview of caching strategy)

---

## Troubleshooting

### Issue: Stale Content After Update

**Symptoms:** Changes not appearing after deployment

**Solutions:**
1. Clear browser cache (Ctrl+Shift+R / Cmd+Shift+R)
2. Verify ETag is updating correctly
3. Check server cache headers
4. Ensure HTML has no-cache meta tags

### Issue: Too Many 200 Responses

**Symptoms:** 304 responses not being sent

**Solutions:**
1. Verify ETag implementation
2. Check `If-None-Match` header is being sent
3. Ensure ETag generation is consistent
4. Verify file modification times

### Issue: Slow Initial Load

**Symptoms:** First page load is slow

**Solutions:**
1. Verify static assets have long cache durations
2. Check CDN configuration (if using)
3. Ensure proper HTTP/2 or HTTP/3 support
4. Consider preloading critical resources

---

## Summary

The Quill Web Editor implements a comprehensive caching strategy that:

1. **Maximizes Performance**: Long cache durations for static assets (when enabled)
2. **Ensures Freshness**: No cache for HTML, ETag-based validation (when enabled)
3. **Saves Bandwidth**: 304 Not Modified responses (when enabled)
4. **Supports Development**: Cache busting and no-cache HTML
5. **Production Ready**: Compatible with CDNs and service workers
6. **Flexible Configuration**: Can be easily switched between cache and no-cache modes

**Current Configuration:** The project is currently in **no-cache mode** for development. All resources are fetched fresh on every request, ensuring you always see the latest changes. To enable caching for better performance, follow the instructions in the [Disabling Caching](#disabling-caching) section.

This multi-layered approach provides optimal performance while maintaining flexibility for both development and production environments.

---

## References

- [HTTP Caching (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching)
- [Cache-Control (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)
- [ETag (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

