/* Servidor de desarrollo de Máquinas.
   Hace dos cosas:
     1. Sirve la carpeta por http://localhost:8199  — hace falta, porque con
        doble clic (file://) el navegador bloquea las descargas del terreno,
        del satélite y de OpenStreetMap, y también la webcam.
     2. Recibe capturas de pantalla en POST /captura y las guarda en capturas/.
        El juego dibuja en WebGL, así que la única forma de sacar una imagen
        fiable es leerla del propio motor y mandarla aquí.

   Sin dependencias: solo lo que trae Node.
   Arrancar:  node servidor.js [puerto]
*/
const http = require('http');
const fs   = require('fs');
const path = require('path');

const RAIZ    = __dirname;
const PUERTO  = Number(process.argv[2]) || 8199;
const CAPTURAS = path.join(RAIZ, 'capturas');

const TIPOS = {
  '.html': 'text/html; charset=utf-8',
  '.js'  : 'text/javascript; charset=utf-8',
  '.css' : 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.webmanifest': 'application/manifest+json; charset=utf-8',
  '.png' : 'image/png',
  '.jpg' : 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg' : 'image/svg+xml',
  '.txt' : 'text/plain; charset=utf-8',
  '.md'  : 'text/plain; charset=utf-8',
};

/* Nombre de archivo seguro: sin rutas, sin sorpresas. */
function nombreSeguro(s) {
  return String(s || 'captura').replace(/[^a-zA-Z0-9_-]/g, '').slice(0, 60) || 'captura';
}

const servidor = http.createServer((req, res) => {
  /* ---- capturas ---- */
  if (req.method === 'POST' && req.url.split('?')[0] === '/captura') {
    let cuerpo = '';
    let abortado = false;
    req.on('data', (c) => {
      cuerpo += c;
      if (cuerpo.length > 40e6) { abortado = true; req.destroy(); }   // tope: 40 MB
    });
    req.on('close', () => {
      if (abortado) console.log('  captura descartada: demasiado grande');
    });
    req.on('end', () => {
      if (abortado) return;
      try {
        const j = JSON.parse(cuerpo);
        const m = /^data:image\/(png|jpeg);base64,/.exec(j.img || '');
        if (!m) throw new Error('no es una imagen png/jpeg en base64');
        const ext = m[1] === 'jpeg' ? 'jpg' : 'png';
        const datos = Buffer.from(j.img.slice(m[0].length), 'base64');
        fs.mkdirSync(CAPTURAS, { recursive: true });
        const archivo = path.join(CAPTURAS, nombreSeguro(j.nombre) + '.' + ext);
        fs.writeFileSync(archivo, datos);
        console.log('  captura guardada: ' + path.basename(archivo) +
                    ' (' + Math.round(datos.length / 1024) + ' KB)');
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: true, archivo: path.basename(archivo), bytes: datos.length }));
      } catch (e) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ ok: false, error: e.message }));
      }
    });
    return;
  }

  /* ---- archivos estáticos ---- */
  let rel = decodeURIComponent(req.url.split('?')[0]);
  if (rel === '/') rel = '/drones.html';
  const destino = path.join(RAIZ, path.normalize(rel));
  // no dejar salir de la carpeta con ../
  if (!destino.startsWith(RAIZ)) { res.writeHead(403); return res.end('fuera de la carpeta'); }

  fs.readFile(destino, (err, datos) => {
    if (err) { res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
               return res.end('no existe: ' + rel); }
    res.writeHead(200, {
      'Content-Type': TIPOS[path.extname(destino).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-store',      // en desarrollo, siempre la última versión
    });
    res.end(datos);
  });
});

servidor.listen(PUERTO, () => {
  console.log('Máquinas en  http://localhost:' + PUERTO + '/drones.html');
  console.log('Con ?dbg al final sale window.DRONES para medir el juego.');
  console.log('Las capturas se guardan en  ' + CAPTURAS);
});
