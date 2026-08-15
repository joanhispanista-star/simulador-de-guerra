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

## Lo que falta, por orden de lo que yo haría

1. **La teja se ve lisa** — usa la textura de losa tintada de rojo; una teja real
   tiene acanaladura. Media sesión.
2. **Techos claros algo quemados** bajo el sol de mediodía. Es la exposición, un
   número.
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
```

Para probar la copia sin tocar el disco: `DRONES.restaurar(DRONES.copia())`.
Y para comprobar que rechaza basura: `DRONES.restaurar('{"juego":"otra-cosa"}')`
debe devolver `ok:false` **y dejar el progreso intacto**.

## Números de referencia (1280×720, misión 5)

- 0,9–6,7 ms por cuadro según lo que haya en pantalla
- ~1,0–1,8 ms de lógica
- Bogotá centro: 2.855 edificios · 740 calles · ~3.100 árboles · 2.840 trastos
- La Candelaria: 2.314 tejados a dos aguas de 3.564 edificios (65%)
