# Estado de Drones de Combate · 6 de agosto de 2026

Documento para retomar sin releer el historial. Lo que está hecho, lo que falta,
y las trampas que ya costaron tiempo una vez.

**En línea:** https://joanhispanista-star.github.io/simulador-de-guerra/
**Publicar:** `git push` desde `Desktop\maquinas`. Nada más.

---

## Lo que se hizo en esta sesión

Se partió de un juego que vivía suelto en una carpeta sin git y que en Bogotá
mostraba media ciudad. Ahora:

| Área | Estado |
|---|---|
| Ciudad real | 2.855 de 2.936 edificios (antes 1.500 de 2.936) |
| Techos | textura de losa, trastos de azotea, **tejados a dos aguas** y pretiles |
| Árboles | 3.100 con color propio, y arbolado de avenida |
| Calles | acera, asfalto y línea central discontinua; esquinas resueltas |
| Suelo | 0,59 m/píxel (antes 2,34 — el PC recibía calidad de móvil) |
| Horizonte | 21,6 km alrededor, con los cerros orientales |
| Máquinas | escala real: UGV 2,4 m, dron 0,9 m, perro robot 0,9 m |
| Modelos | ensamblador que fusiona piezas: ~100 piezas → 5 llamadas de dibujo |
| Armas | ametralladora con **trazadoras** de verdad (1 de cada 5) |
| Enemigos | **perros robot** con rifle y trote diagonal real |
| Vuelo | modo **FÁCIL** por defecto: sueltas y se para, mantiene altura |
| Cámara del dron | **gimbal** que baja solo al subir |
| Sonido | todo sintetizado; motor, rotores y viento continuos |
| **Modo foto** | `P`: congela, esconde el HUD, cámara libre, guarda a 2× |
| App de Windows | instalable, 2 MB, **abre sin internet** |
| **Copia del progreso** | ⬇ guardar / ⬆ restaurar en un archivo `.json` (14-ago) |
| **Teja de barro** | textura propia con canales de 16 cm y relieve (14-ago) |
| **Sombras** | siguen a la máquina y se afinan: 1,25 m → 0,33 m por punto (14-ago) |
| **Alero y cumbrera** | el tejado vuela 42 cm y remata en su hilera (14-ago) |
| **Chimeneas** | ~1.400, a caballo del caballete, instanciadas (14-ago) |
| **Losa de concreto** | de 0,46–0,56 de albedo a 0,30–0,40: ya no sale blanca |

## El error que hacía que los techos se vieran "lisos"

`computeVertexNormals` **suma** la normal de cada cara que toca un vértice. Los
tejados a dos aguas y los pretiles se dibujaban duplicando cada triángulo con la
vuelta al revés dentro de la misma malla, para poder verlos por dentro al volar
bajo. Las dos vueltas dan normales opuestas: **se anulan exactas y el vértice
queda con normal (0,0,0)**. Con normal cero `dot(N,luz)` es cero — el sol
sencillamente no llegaba a esas superficies. Quedaban iluminadas solo por la luz
ambiente: planas, sin cara clara y cara oscura, sin sombra propia. Justo lo
contrario de para lo que se pusieron.

No se veía como un fallo, se veía como una decisión de estilo. Comprobado con
three fuera del navegador: doble vuelta → `(0,0,0)`; una sola → `(0,1,0)`.

Ahora las dos caras las pone el **material** (`side: DoubleSide`), que es donde
va eso. Y `DRONES.normales()` lo vigila: en las mallas de la ciudad tiene que
salir `normalesEnCero: 0`. Si sale otra cosa, mira `deEsasConArea` — si es 0,
son triángulos degenerados (sin superficie) y no importan.

## El progreso: qué se resolvió y qué no

El progreso **sigue viviendo en `localStorage`**, y `localStorage` no viaja: se
borra al limpiar los datos del navegador, no lo ve otro navegador y no cruza de
un computador a otro. Lo que cambió el 14 de agosto es que **ya no es
irrecuperable**: en el menú, abajo, hay **⬇ Guardar copia** y **⬆ Restaurar
copia**. El archivo se llama `drones-progreso-AAAA-MM-DD.json` y lleva dentro
las misiones completadas, las mejores marcas, el garaje, la hora/clima y el
volumen.

El texto del menú ahora **lo dice**: "Tu progreso se guarda solo en este
navegador y en este equipo… se pierde". Antes decía "Guarda tu progreso en este
navegador", que sonaba a promesa.

**Lo que NO se hizo, a propósito:** sincronizar solo, sin que el jugador haga
nada. Eso pide cuenta y servidor, y Drones es independiente y **abre sin
internet** — no vale la pena romper eso por guardar diez misiones. Si algún día
se quiere, el formato ya está preparado: la copia lleva `juego` y `formato`, y
el importador rechaza lo que no reconoce en vez de dejar la partida a medias.

## "Techos quemados": medido, y NO era eso

Se midió con `DRONES.quemado()` sobre La Candelaria a mediodía, incluso mirando
en vertical con el cuadro lleno de techos: **0,00 % de píxeles quemados**, y el
percentil 99 en 206 de 255. **No hay nada pegado al blanco.** Tocar la exposición
habría oscurecido la ciudad entera para arreglar algo que no estaba roto.

Lo que sí pasa es que los techos de losa son muy **claros y de poco contraste**:
`colorTecho` los devuelve en torno a 0,47–0,56 de albedo, y un hormigón viejo de
Bogotá está más cerca de 0,30. Eso ya es gusto, no defecto — decisión de Joan.

## Los cuatro números que deciden cómo se ve la ciudad

Están todos juntos a propósito: son de gusto, se tocan en un segundo y no hay
que entender nada del motor para moverlos.

| Dónde | Qué es | Ahora |
|---|---|---|
| `ALERO_M` | cuánto vuela el tejado sobre el muro | 0,42 m |
| `losa()` | albedo del concreto visto desde arriba | 0,30–0,40 |
| `colorTecho` → `r<0.72` | cuántas casas con faldón llevan teja | 72 % |
| `ruidoCuadra(...) < 0.62` | cuántos tejados llevan chimenea | 62 % |

## Lo que falta, por orden de lo que yo haría

1. **La losa, ¿aún más oscura?** Se bajó de 0,46–0,56 a 0,30–0,40 y la ciudad
   dejó de ser un mar de sábanas, pero en picado sigue clara. Un concreto viejo
   de verdad está en 0,22–0,30. Es un número, y es gusto tuyo.
2. **Ventana en el hastial.** El triángulo del remate está liso; en La
   Candelaria casi todos tienen su ventanuco. Es la última cosa que se nota al
   pasar a ras de tejado.
3. **Microsoft Store** (19 USD una vez, la firma Microsoft, sin advertencia de
   SmartScreen). PWABuilder toma lo que ya hay. Solo cuando el juego esté más
   terminado.

## Decisión pendiente, y es de Joan

La raíz de `joanhispanista-star.github.io` enlaza a `/joan-te-presta/crm.html`,
el panel de Tu Garantía. Quien tenga el enlace del juego puede recortar la URL y
llegar. Pide clave, pero está publicado. **No se tocó porque es su página de
negocio.**

## Trampas que ya costaron tiempo

- **Drones es INDEPENDIENTE: no enlaza a nada.** Se sacaron del repositorio
  `plaza.html` (el índice de todos los proyectos de Joan, que se publicó una vez
  por error), `tanques.html` y su LEEME. El enlace "← Plaza" se eliminó del
  juego entero. El despliegue usa **lista blanca**: si un archivo no está en
  `publicar.yml`, no viaja. La copia buena de Tanques vive en
  `Desktop/plaza-miniapps/tanques/` y está publicada aparte, en Vercel.
- **El service worker sirve versiones viejas.** Al probar, subir `VERSION` en
  `sw-drones.js` o Ctrl+F5. Pasó varias veces.
- **Al medir, fijar el tamaño primero:** `DRONES.tamano(1280,720)`. Con la
  ventana oculta `innerWidth` vale 0, el lienzo queda en 0×0 y dibujar no cuesta
  nada — se mide humo. Los FPS medidos así son basura.
- **`requestAnimationFrame` no corre con la ventana oculta.** Por eso existen
  `DRONES.sim()` y `DRONES.fotoPaso()`: para avanzar el juego a mano.
- **Con la ventana oculta los TIEMPOS tampoco valen.** El navegador estrangula la
  GPU en segundo plano: seis medidas seguidas de la MISMA escena dieron entre 2,5
  y 72,9 ms. Para medir rendimiento hay que tener el juego a la vista.
- **Overpass no siempre devuelve lo mismo.** Tres cargas seguidas de la misma
  caja de La Candelaria dieron 2.301, 1.595 y 2.331 tejados. Si comparas dos
  capturas, la ciudad puede no ser la misma: no lo achaques al cambio.
- **Overpass es gratuito y se satura.** Devuelve 0 edificios y no es un fallo del
  código. Reintentar. Además `overpass.osm.ch` contesta 200 con cero elementos
  mientras `overpass-api.de` trae los 2.936 de la misma caja.
- **Todo lo continuo (sonido) va en `sonidoAmbiente()`,** que corre siempre. El
  motor estaba dentro de la rama del tanque y se quedaba congelado a todo volumen
  al pilotar el dron.

## Cómo medir sin jugar

`?dbg` en la URL expone `window.DRONES`.

```javascript
DRONES.tamano(1280,720)   // SIEMPRE primero
DRONES.realInfo()         // edificios, calles, árboles, tejados, nitidez
DRONES.medidas()          // tamaño de cada máquina EN METROS
DRONES.dibujo()           // triángulos y llamadas de dibujo
DRONES.cronometro()       // ms por cuadro
DRONES.audio()            // nivel de sonido REAL (no "no dio error")
DRONES.bucles()           // ganancia de motor, rotores y viento por separado
DRONES.fotoPrueba()       // comprueba la captura sin descargarla
DRONES.rumbo(90)          // apuntar el dron al este (los cerros)
DRONES.aislar({sombras:false})  // apagar partes para ver qué cuesta
DRONES.progreso()         // misiones, marcas, garaje, hora/clima, volumen
DRONES.copia()            // el MISMO texto que descarga "⬇ Guardar copia"
DRONES.restaurar(texto)   // {ok,msg} — prueba restaurar sin abrir el diálogo
DRONES.quemado(1280,720)  // % de píxeles pegados al blanco; el p99 dice más
DRONES.normales()         // normales en cero por malla — tiene que ser 0
DRONES.sombra()           // metrosPorPunto: lo fino que es el borde de sombra
DRONES.foto64(700)        // la imagen en base64, para MIRARLA fuera del navegador
DRONES.aTejado(210,14,7)  // te pone al lado de una casa de teja y te la apunta
```

**Para revisar un cambio VISUAL sin poder ver la ventana** (que es lo normal
aquí): la captura de pantalla del navegador falla porque con el panel oculto la
página no compone cuadros — pero `readPixels` sí funciona. `DRONES.foto64(700)`
devuelve la imagen; se descarga con un `<a download>` y se abre desde el disco.
Es lo único que sirve: los números dicen si está roto, no si está feo.

Para probar la copia sin tocar el disco: `DRONES.restaurar(DRONES.copia())`.
Y para comprobar que rechaza basura: `DRONES.restaurar('{"juego":"otra-cosa"}')`
debe devolver `ok:false` **y dejar el progreso intacto**.

## Números de referencia (1280×720, misión 5)

- 0,9–6,7 ms por cuadro según lo que haya en pantalla
- ~1,0–1,8 ms de lógica
- Bogotá centro: 2.855 edificios · 740 calles · ~3.100 árboles · 2.840 trastos
- La Candelaria: 2.314 tejados a dos aguas de 3.564 edificios (65%)
