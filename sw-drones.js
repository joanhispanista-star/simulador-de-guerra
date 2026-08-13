/* Service worker de Drones de Combate.
   Es lo que convierte la página en una app de Windows que abre SIN INTERNET.

   Antes solo guardaba drones.html y el manifiesto, y el motor 3D venía de un
   CDN. O sea que instalada y sin conexión arrancaba la ventana y se moría en
   "Error al iniciar el motor 3D": una app que no abre no es una app.
   Ahora el motor, la física y el cascarón entero se guardan al instalar.

   Lo que NO puede funcionar sin internet, y hay que decirlo claro: el MUNDO
   REAL. El relieve, la imagen satelital y los edificios de OpenStreetMap se
   descargan del lugar que elijas — sin conexión no hay Bogotá. Las misiones
   normales, esas sí corren enteras.
*/
const VERSION = 'v0_17';
const CACHE   = 'drones-' + VERSION;

/* El cascarón: todo lo que hace falta para ARRANCAR. Se guarda al instalar,
   de una vez, para que la primera vez que abras sin internet ya esté. */
const CASCARON = [
  './',
  './index.html',
  './drones.html',
  './drones.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './vendor/three/three.module.js',
  './vendor/cannon-es.js',
  './vendor/three/addons/utils/BufferGeometryUtils.js',
  './vendor/three/addons/postprocessing/EffectComposer.js',
  './vendor/three/addons/postprocessing/RenderPass.js',
  './vendor/three/addons/postprocessing/OutputPass.js',
  './vendor/three/addons/postprocessing/UnrealBloomPass.js',
  './vendor/three/addons/postprocessing/Pass.js',
  './vendor/three/addons/postprocessing/MaskPass.js',
  './vendor/three/addons/postprocessing/ShaderPass.js',
  './vendor/three/addons/shaders/CopyShader.js',
  './vendor/three/addons/shaders/LuminosityHighPassShader.js',
  './vendor/three/addons/shaders/OutputShader.js',
];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const c = await caches.open(CACHE);
    /* uno a uno y sin rendirse: con addAll(), si UN archivo falla se cae la
       instalación entera y te quedas sin nada guardado */
    await Promise.all(CASCARON.map(u => c.add(u).catch(() => {})));
    self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil((async () => {
    /* Solo se borran las cachés propias. caches.keys() no lista las de esta app:
       lista las de TODO el dominio. Sin el filtro por prefijo, Drones le borraría
       la caché a cualquier otra app publicada en la misma dirección. */
    const keys = await caches.keys();
    await Promise.all(
      keys.filter(k => k.startsWith('drones-') && k !== CACHE).map(k => caches.delete(k))
    );
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // lo de fuera (terreno, satélite, OpenStreetMap) no se toca: siempre a la red
  if (url.origin !== location.origin) return;

  /* El MOTOR se sirve de la caché primero: son 1,7 MB que no cambian nunca
     (van con la versión en la ruta), así que pedirlos a la red en cada arranque
     es tiempo tirado. */
  if (url.pathname.includes('/vendor/')) {
    e.respondWith(
      caches.match(req).then(hit => hit || fetch(req).then(r => {
        if (r && r.ok) { const cp = r.clone(); caches.open(CACHE).then(c => c.put(req, cp)); }
        return r;
      }))
    );
    return;
  }

  /* El JUEGO va a la red primero y cae a la caché si no hay: así, con internet
     siempre ves la última versión, y sin internet abre igual. */
  e.respondWith(
    fetch(req).then(r => {
      if (r && r.ok) { const cp = r.clone(); caches.open(CACHE).then(c => c.put(req, cp)); }
      return r;
    }).catch(() => caches.match(req).then(hit => hit || caches.match('./drones.html')))
  );
});
