'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "180932bb9ff6a351b5991e939e51a90d",
"assets/AssetManifest.bin.json": "1672412ab81abc7aaccb74d6fa09bee9",
"assets/AssetManifest.json": "ae10474555ca597f780e29aebf979a2d",
"assets/assets/animations/character.riv": "9748e6c60c84febc0b978fd08cc32b56",
"assets/assets/animations/skills.riv": "3fe6f78f7ba5d708f0c5a7fa057dda43",
"assets/assets/audio/readme.md": "b5f009a31d6d1a88e844e15087276622",
"assets/assets/images/banner.png": "32f20ea98f8534fb377696aed94f11ea",
"assets/assets/images/ember.png": "3027f5f0b80b46ee1ae2463f2ab3d1ce",
"assets/assets/images/equipments/armors/Tek_Boots.webp": "c34644fc27b75dcb5401e10207a93349",
"assets/assets/images/equipments/armors/Tek_Chestpiece.webp": "5e2c31619a84984ff301c1ab9dff7fd9",
"assets/assets/images/equipments/armors/Tek_Gauntlets.webp": "bac01eb14658c44cfe2f9e269724670b",
"assets/assets/images/equipments/armors/Tek_Helmet.webp": "51b9ed1e91886ecbc8473c56c039e904",
"assets/assets/images/equipments/armors/Tek_Leggings.webp": "c2b1b3e005d63b6fecc4caf7b12fc449",
"assets/assets/images/equipments/swords/0-9335_sword-slash-effect-png-png-download-circle-transparent.png": "5f9b8315331e8a16f70b6314f91701fa",
"assets/assets/images/equipments/swords/button-frame.png": "43d15fc9361fde72721765df3a13ee9c",
"assets/assets/images/equipments/swords/Chronosphere_icon.webp": "9d2f10ff75875c0228f4f14c76c2594d",
"assets/assets/images/equipments/swords/demon-sword.png": "cec57bab26943fbec069bee097125421",
"assets/assets/images/equipments/swords/desolator-effect.png": "0d2692d37f0bd8e807b29941fdc9f511",
"assets/assets/images/equipments/swords/desolator-sprite.png": "c5264e21322746b5782a77906781e03f",
"assets/assets/images/equipments/swords/desolator-sprite.psd": "e2f000cd534127c36a9926be4cc8543a",
"assets/assets/images/equipments/swords/fireball.png": "e98e2f93b82f51583a8de645a386ad53",
"assets/assets/images/equipments/swords/flame-effect.png": "b3265b9afa70c5196e37b145b6b580e2",
"assets/assets/images/equipments/swords/flame-sprite.png": "41bb7012d38137d63111a8cab12c6770",
"assets/assets/images/equipments/swords/flame-sword.png": "d3de8e5d6cdce2c1ebfdc0f3cd7b81b5",
"assets/assets/images/equipments/swords/Flame_Cloak_icon.webp": "638ac28bfc70d80b556e9ff30fa5c5be",
"assets/assets/images/equipments/swords/Guardian_Angel_icon.webp": "06d7d3d46586836a537f0d390c75f2fb",
"assets/assets/images/equipments/swords/kisspng-sword-dagger-clip-art-portable-network-graphics-we-5c921402bca724.9352191915530772507727.png": "faf74cbf657fb3f8a13d80f7be9011e9",
"assets/assets/images/equipments/swords/lightning-effect.png": "77f29f8cc9032c857f181635b4073f61",
"assets/assets/images/equipments/swords/lightning-sprite.png": "64865ae97d93f51629a6ecf731d120ac",
"assets/assets/images/equipments/swords/lightning-sword.png": "54604f7e4a4fef87ad4886953b9972a1",
"assets/assets/images/equipments/swords/png-clipart-hexagram-method-magic-spiritual-power.png": "cde2af3d567f2271d0fa52607cb26946",
"assets/assets/images/equipments/swords/pngfind.com-rpg-png-887284.png": "daa0aa7ff05160afd5544e06c30d1541",
"assets/assets/images/equipments/swords/purifier-effect.png": "4e732619c68760f3436b736955657f00",
"assets/assets/images/equipments/swords/purifier-sprite.png": "49351d93f09a4142fd99eeefa688e9c5",
"assets/assets/images/equipments/swords/Repel_icon.webp": "f1edcbcfead56a295a7fd8f1b1153720",
"assets/assets/images/equipments/swords/slash-on-enemy.png": "3f89299355313ef2711a2dc4ef06ef38",
"assets/assets/images/equipments/swords/splash.png": "269cab986fa916119aa6f34ed819729f",
"assets/assets/images/equipments/swords/sword.png": "9ab17e012632ce41abc2e8f2c2f2eb83",
"assets/assets/images/equipments/swords/sword.psd": "ff5a90a8f4d9ad63c2ea75f879b3b8da",
"assets/assets/images/equipments/swords/time-effect.png": "d1883acaaeb132b3aeebd3a443563aa0",
"assets/assets/images/equipments/swords/time-sprite.png": "d0d8e7ab8e5c7bf4805913307852966b",
"assets/assets/images/equipments/swords/time-sword.png": "ce1ea97f2d0eb0322ddcbbc56da3fbe4",
"assets/assets/images/equipments/swords/Time_Walk_icon.webp": "cdea10f846159aa8fe602b67941a5f39",
"assets/assets/images/equipments/swords/toppng.com-explore-dark-lightning-429x649.png": "e0105f6e0947c3c4e0404c7b3a0c6d33",
"assets/assets/images/hud/avatar-frame-original.png": "cfcb2d32812b153496b433c96feb4d1e",
"assets/assets/images/hud/avatar-frame.png": "81ec55423a06195eb8d782c201eb07d8",
"assets/assets/images/hud/hud-original.png": "4c9c37569ee0aaab6dbb8ca34d874aec",
"assets/assets/images/hud/hud.png": "0267c040626d562065323f4505fdf598",
"assets/assets/images/hud/hud.psd": "156b5ea22ad5d7d841ea0da2bca45a49",
"assets/assets/images/README.md": "029e486e45ccc723efb7b0f45dec900b",
"assets/assets/images/skills-and-effects/Ball_Lightning_icon.webp": "97b659148ad541c19d1aa2b207befd1a",
"assets/assets/images/skills-and-effects/boom.png": "3172e300cf7c040566fb873e001c706b",
"assets/assets/images/skills-and-effects/Chronosphere_icon.webp": "9d2f10ff75875c0228f4f14c76c2594d",
"assets/assets/images/skills-and-effects/Cold_Feet_icon.webp": "4d2eefe384d7ebbbae3ddc96ffba32a5",
"assets/assets/images/skills-and-effects/Fireblast_icon.webp": "d56c26d30446f426263a94d592f59471",
"assets/assets/images/skills-and-effects/Flame_Cloak_icon.webp": "638ac28bfc70d80b556e9ff30fa5c5be",
"assets/assets/images/skills-and-effects/Guardian_Angel_icon.webp": "06d7d3d46586836a537f0d390c75f2fb",
"assets/assets/images/skills-and-effects/Kinetic_Field_icon.webp": "f23928d60ecf222bae1394310b14724e",
"assets/assets/images/skills-and-effects/magic-circle.png": "44d4449d2436eb9e497150b9e87de582",
"assets/assets/images/skills-and-effects/Necromastery_icon.webp": "f91d70d7efa463338e159101f415323a",
"assets/assets/images/skills-and-effects/Rebel_effect.png": "d5d62907003f7c29710bd8ba19ef146d",
"assets/assets/images/skills-and-effects/Repel_icon.webp": "f1edcbcfead56a295a7fd8f1b1153720",
"assets/assets/images/skills-and-effects/Requiem_of_Souls_icon.webp": "da685797433d10e8ddf69815202cf2e5",
"assets/assets/images/skills-and-effects/skill-frame.png": "03211fad890e2e0b2c7bb756dd0c35bf",
"assets/assets/images/skills-and-effects/Thunder_Strike_icon.webp": "e9524492a95b9a0152636a3e48b73048",
"assets/assets/images/skills-and-effects/Time_Walk_icon.webp": "cdea10f846159aa8fe602b67941a5f39",
"assets/assets/images/Spritesheet.png": "91343291ba011127b7a31b59671e5f4f",
"assets/assets/tiles/Level1.tmx": "2c2f2b290623462904588e83a8234fdf",
"assets/assets/tiles/Level2.tmx": "cc1090efc22292453f46cca38e1b84a4",
"assets/assets/tiles/Spritesheet.tsx": "bce41dcfe90003dd8a8e124830126f7d",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "32fce58e2acb9c420eab0fe7b828b761",
"assets/NOTICES": "32f00fe330b484427a463091585aa83d",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "59a12ab9d00ae8f8096fffc417b6e84f",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "f558dc7794d7a40230a920cb4e2c20a6",
"/": "f558dc7794d7a40230a920cb4e2c20a6",
"main.dart.js": "c2c557c967f924568913e7c9616df72b",
"manifest.json": "c78d3f3155b75d44e95ed92febff7378",
"version.json": "d4060cab5baec6d7abb6714520a086cb"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
