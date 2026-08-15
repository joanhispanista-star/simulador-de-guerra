# Drones de Combate

Simulador de vehículos **no tripulados** sobre el mundo real, en un solo archivo
HTML. Proyecto independiente: no depende de nada ni enlaza a nada.

**En línea:** https://joanhispanista-star.github.io/simulador-de-guerra/

---

## Publicar

```bash
git push
```

Eso es todo. Un flujo de GitHub Actions reconstruye la rama `gh-pages` con una
**lista blanca** de lo publicable y el sitio se actualiza en un minuto.

Si añades un archivo que deba publicarse, hay que meterlo en la lista de
`.github/workflows/publicar.yml`. Si no está, **no viaja** — y eso es a
propósito.

> Pages está servido desde la rama `gh-pages`. Se encendió creando esa rama:
> crearla lo activa solo. Encenderlo por API devolvía 403 porque el token del
> repositorio no tiene ese permiso por defecto.

## Instalarlo como app de Windows

Abrir el enlace en **Edge** → icono de instalar en la barra de direcciones.
Queda con icono en Inicio, ventana propia y barra de tareas. Pesa **2 MB**.

**Abre sin internet.** El motor 3D (Three.js), la física (cannon-es) y el
cascarón van dentro; el service worker los precarga al instalar.

**Lo que SÍ necesita internet**, y hay que decirlo claro:

- **El mundo real** — relieve, satélite y edificios se descargan del lugar que
  elijas. Sin conexión no hay Bogotá. Las misiones del menú sí van completas.
- **Apuntar con la mirada** — MediaPipe baja un modelo de ~10 MB cada vez. Se
  deja en su CDN a propósito: empaquetarlo multiplicaría la app por seis para
  algo que sin conexión no funciona igual.

## Correrlo en local

Doble clic en **`JUGAR.bat`**, o:

```bash
node servidor.js 8199
```

**No vale abrir `drones.html` con doble clic.** En `file://` el navegador bloquea
las descargas del terreno, del satélite y de OpenStreetMap, y también la webcam.

## Qué es

Escala real de vehículo no tripulado: **1 unidad = 5,22 m**, el UGV mide 2,4 m
(un THeMIS), el dron 0,9 m y el perro robot 0,9 m. El campo abarca 2,4 km y el
horizonte, 21,6 km.

El mundo real es real: altura del terreno (Terrarium/AWS), imagen satelital
(ESRI) y de OpenStreetMap los edificios con su forma real, las calles, el agua y
el arbolado. **Nada de esto necesita llave de API ni cuenta.**

## Probarlo sin jugar

Con `?dbg` en la URL aparece `window.DRONES`.

```javascript
DRONES.tamano(1280,720)  // SIEMPRE primero: si no, se mide humo
DRONES.realInfo()        // edificios, calles, árboles, tejados, nitidez
DRONES.medidas()         // tamaño de cada máquina EN METROS
DRONES.dibujo()          // triángulos y llamadas de dibujo
DRONES.audio()           // nivel de sonido REAL
DRONES.fotoPrueba()      // comprueba la captura sin descargarla
DRONES.rumbo(90)         // apuntar el dron al este (los cerros de Bogotá)
```

> Con la ventana oculta `innerWidth` vale 0, el lienzo queda en 0×0 y dibujar no
> cuesta nada. Por eso `tamano()` va primero, siempre.

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

Nació dentro de una carpeta con otras mini apps de Joan y sin control de
versiones. En agosto de 2026 se separó en su propio repositorio, con git, con
despliegue automático y **sin enlazar a ningún otro proyecto**.
