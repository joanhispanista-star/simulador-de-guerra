# Máquinas

Los juegos de máquinas de Joan. Dos, separados, cada uno en un solo archivo HTML.

**En línea:** https://joanhispanista-star.github.io/simulador-de-guerra/

| Juego | Archivo | Qué es | Estado |
|---|---|---|---|
| **Drones de Combate** | `drones.html` | Simulador de vehículos **no tripulados** sobre el mundo real | en obra |
| **Batalla de Tanques** | `tanques.html` | Duelo 2D estilo Atari Combat (1977) | terminado |

---

## Publicar

```bash
git push
```

Eso es todo. Un flujo de GitHub Actions reconstruye la rama `gh-pages` con una
**lista blanca** de lo publicable y el sitio se actualiza en un minuto.

Lo que **no** sale publicado, a propósito: `servidor.js`, `JUGAR.bat`,
`capturas/`, `README.md` y sobre todo **`plaza.html`**, que es el índice de todos
los proyectos de Joan. Si añades un archivo que deba publicarse, hay que meterlo
en la lista de `.github/workflows/publicar.yml` — si no, no viaja.

> Pages está servido desde la rama `gh-pages`. Se encendió creando esa rama:
> crearla lo activa solo. Encenderlo por API devolvía 403 porque el token del
> repositorio no tiene ese permiso por defecto.

## Instalarla como app de Windows

Abrir el enlace en **Edge** → icono de instalar en la barra de direcciones.
Queda con icono en Inicio, ventana propia y barra de tareas. Pesa **2 MB**.

**Abre sin internet.** El motor 3D (Three.js), la física (cannon-es) y el
cascarón van dentro de la app; el service worker los precarga al instalar.

**Lo que SÍ necesita internet**, y hay que decirlo claro:

- **El mundo real** — relieve, satélite y edificios se descargan del lugar que
  elijas. Sin conexión no hay Bogotá. Las misiones del menú sí van completas.
- **Apuntar con la mirada** — MediaPipe baja un modelo de visión de ~10 MB cada
  vez. Se deja en su CDN a propósito: empaquetarlo multiplicaría la app por seis
  para algo que sin conexión no funciona igual.

## Correrlo en local

Doble clic en **`JUGAR.bat`**, o:

```bash
node servidor.js 8199
```

**No vale abrir `drones.html` con doble clic.** En `file://` el navegador bloquea
las descargas del terreno, del satélite y de OpenStreetMap, y también la webcam.

## Drones de Combate

Escala real de vehículo no tripulado: **1 unidad = 5,22 m**, el UGV mide 2,4 m
(un THeMIS), el dron 0,9 m y el perro robot 0,9 m. El campo abarca 2,4 km y el
horizonte, 21,6 km.

Trae el mundo real de verdad: altura del terreno (Terrarium/AWS), imagen
satelital (ESRI) y de OpenStreetMap los edificios con su forma real, las calles,
el agua y el arbolado. **Nada de esto necesita llave de API ni cuenta.**

### Probarlo sin jugar

Con `?dbg` en la URL aparece `window.DRONES`: una API para medir el juego.

```javascript
DRONES.tamano(1280,720)  // ⚠ fijar el tamaño ANTES de medir nada
DRONES.realInfo()        // edificios, calles, árboles, nitidez del suelo
DRONES.medidas()         // tamaño de cada máquina EN METROS
DRONES.dibujo()          // triángulos y llamadas de dibujo
DRONES.cronometro()      // ms por cuadro
DRONES.rumbo(90)         // apuntar el dron al este (los cerros de Bogotá)
```

> Con la ventana oculta `innerWidth` vale 0, el lienzo queda en 0×0 y dibujar no
> cuesta nada: se mide humo. Por eso `tamano()` va primero, siempre.

## El núcleo está abierto a contenido

Casi todo son **registros de datos**: para añadir cosas no hay que tocar el motor.

| Registro | Qué añade |
|---|---|
| `CIUDADES` | ciudades listas (nombre + lat/lon) |
| `REAL_MAPS` | lugares naturales del planeta |
| `CATALOG` | piezas del garaje |
| `MISSIONS` | misiones: bioma, enemigos, objetivos |
| `BIOMES` / `TODS` / `WEATHER` | mundos, horas del día y climas |

## Historia

Vivían sueltos en `Desktop\Joan te presta\`, sin control de versiones. En agosto
de 2026 se mudaron aquí y el proyecto pasó a llamarse **Máquinas**. El primer
commit es una copia intacta de los originales.

La marca sigue siendo **Joan te presta**, el paraguas de las mini apps.
