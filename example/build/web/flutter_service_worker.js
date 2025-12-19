'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "6ebbd0127fa605105a852d43db480949",
"version.json": "932171c4f19043d860e3ec0c4e0f95fd",
"index.html": "7ff44f7d74cf35402ad02d3dbc84d6dd",
"/": "7ff44f7d74cf35402ad02d3dbc84d6dd",
"js/utils-override.js": "297beb714072ac98bc3022a8e2507e4d",
"js/clipboard-override.js": "95102627b87abcb210341525c78eb9fc",
"js/config-override.js": "6140dbdfb03f0b47110435bec051bf3a",
"js/quill-setup-override.js": "571b33f10cd066ad3d3d46ffc0fc6f64",
"main.dart.js": "b77162fc0451930dac18f2e110858dc2",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"quill_viewer.html": "88a86feba42857c5618a8ce7d23bec39",
"styles/mulish-font.css": "f6e19edd3cc1c4ed42802ab8435ef679",
"quill_editor.html": "bd7aaca1af654f9441253c80960fbf32",
"assets/AssetManifest.json": "615a15f185369d7c5e1c76b82d9c4e74",
"assets/NOTICES": "063ae379c9c98825aebf94fba3f16030",
"assets/FontManifest.json": "f4837a9becf1f1bc3ef23f99128cdd4b",
"assets/AssetManifest.bin.json": "c8a5ad5108cbdba989033853df022c9a",
"assets/packages/quill_web_editor/test/fonts/DMSans-Regular.ttf": "0ea0836464f94eb37523459eb765af8f",
"assets/packages/quill_web_editor/test/fonts/CrimsonPro-Regular.ttf": "6c1d818f3153e1f1a29a90ac976fa254",
"assets/packages/quill_web_editor/test/fonts/CrimsonPro-SemiBold.ttf": "9465b46801d61156c59db7069dd67be0",
"assets/packages/quill_web_editor/test/fonts/SourceCodePro-Regular.ttf": "9cbdbb6c2f75064529355552bf46cb5c",
"assets/packages/quill_web_editor/web/js/media-resize.js": "f55d47941b984b5e7c9d45527717b940",
"assets/packages/quill_web_editor/web/js/drag-drop.js": "9cc4853dd26726f538d9ca350558ee81",
"assets/packages/quill_web_editor/web/js/config.js": "63a5300973a7ac6c6f5eb0ef1e10757c",
"assets/packages/quill_web_editor/web/js/viewer.js": "9fdd470813d626eccdf53a4f506333aa",
"assets/packages/quill_web_editor/web/js/quill-setup.js": "2ddad2d9d2340ce7322f27d13f319d91",
"assets/packages/quill_web_editor/web/js/table-resize.js": "f2044ae43590c6fcbc4c99f85c91560a",
"assets/packages/quill_web_editor/web/js/clipboard.js": "e1cae3611631314966891a6260a665a1",
"assets/packages/quill_web_editor/web/js/commands.js": "c03f39bf722776ef77a239cc1db5f06d",
"assets/packages/quill_web_editor/web/js/utils.js": "c2407074dbb5416c602651252541af1a",
"assets/packages/quill_web_editor/web/js/flutter-bridge.js": "45c2614d4756e4eb4eb0d8ab5e70af4c",
"assets/packages/quill_web_editor/web/quill_viewer.html": "88a9f2567f71ecafcff6b0f391add03c",
"assets/packages/quill_web_editor/web/styles/media.css": "9bcf48cc90c79492749a56779fd9d1f0",
"assets/packages/quill_web_editor/web/styles/quill-theme.css": "4ad7913a56c620e77a4c012e9b2e0d94",
"assets/packages/quill_web_editor/web/styles/sizes.css": "b95ea965b616515a1a5083fa94732967",
"assets/packages/quill_web_editor/web/styles/viewer.css": "943d8971afbdba11c95077628dd5c62b",
"assets/packages/quill_web_editor/web/styles/fonts.css": "49e21c629a21c45bb5c33a06f8c519fc",
"assets/packages/quill_web_editor/web/styles/base.css": "dcb0f3a47c6561a6b39b4a01a7a84ffc",
"assets/packages/quill_web_editor/web/styles/tables.css": "ef2705d0f4a46a5528356f41713f8efb",
"assets/packages/quill_web_editor/web/quill_editor.html": "3055315677093d2ba73d84dc323a2ae7",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "a72fb98992fcc80daaa6e9701ea5b32d",
"assets/fonts/MaterialIcons-Regular.otf": "dff4553b5e18b57e3eae0767e1d1e145",
"assets/assets/fonts/Mulish-LightItalic.ttf": "c52d1a5f2f4550522e33562d93fae79a",
"assets/assets/fonts/Mulish-ExtraBoldItalic.ttf": "becc24ae22f8c1132125cf36bf47502a",
"assets/assets/fonts/Mulish-Italic.ttf": "f755b44718c68216e544226ae35563b3",
"assets/assets/fonts/Mulish-Regular.ttf": "77f8944e5a3366e1840f14d9391fb886",
"assets/assets/fonts/Mulish-Black.ttf": "5dd36b3c49eb38a51687406c99ea9f8b",
"assets/assets/fonts/Mulish-BlackItalic.ttf": "78d2044a37649ab8301f47501b24c2eb",
"assets/assets/fonts/Mulish-SemiBoldItalic.ttf": "13e77cb57cef7ea08aa88aa076a54742",
"assets/assets/fonts/Mulish-ExtraLightItalic.ttf": "760de9266daf57600d59b79e210b8270",
"assets/assets/fonts/Mulish-Bold.ttf": "146da79a7bbf3dad6d6621986cfb20b0",
"assets/assets/fonts/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"assets/assets/fonts/Mulish-Light.ttf": "65c92bc63393ac11642c76cf0748d16f",
"assets/assets/fonts/Mulish-ExtraBold.ttf": "a43b79a2903c75325ba5ab740af668e4",
"assets/assets/fonts/Mulish-ExtraLight.ttf": "f013da0743fd077065b321fc6bc72cf8",
"assets/assets/fonts/Mulish-Medium.ttf": "dbdf45355b87ce4b87eb4ef9193e3bc1",
"assets/assets/fonts/Mulish-MediumItalic.ttf": "fb49ea2c8e0695195725a05605d0014b",
"assets/assets/fonts/Mulish-SemiBold.ttf": "555d0b2fe29f7345f025f7ed1580c922",
"assets/assets/fonts/Mulish-BoldItalic.ttf": "7a66bfcf30ca90679945436e115d0f18",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
