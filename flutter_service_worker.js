'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets/LICENSE": "fff2a36afe9bed9f2b999ab884332819",
"/assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets/images/app_icon.png": "5f5244069ceba8559afa0a04f02321ef",
"/assets/images/rahbert.png": "98e5b6c34fa8cd40d5ada1e3deacb58d",
"/assets/images/bemzo.jpg": "570492a60b67ca635d4c5015d4f8a5b3",
"/assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets/AssetManifest.json": "90f2fa0daf400205cf17a106f261bfb2",
"/index.html": "f4e9d07268c4959f6f64e425712ec2e1",
"/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/main.dart.js": "7e3b4fe3bc8aaf5c7311425329a6b1d0",
"/manifest.json": "e635fd6dd182a2cf920db16d047ea5f3"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
