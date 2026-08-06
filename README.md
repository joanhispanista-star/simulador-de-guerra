# Máquinas

Los juegos de máquinas de Joan. Dos, separados, cada uno en un solo archivo HTML
que se abre y corre — sin instalar, sin compilar, sin cuentas.

| Juego | Archivo | Qué es | Estado |
|---|---|---|---|
| **Drones de Combate** | `drones.html` | Simulador 3D de drones y vehículos terrestres sobre el mundo real | v0.8, en obra |
| **Batalla de Tanques** | `tanques.html` | Duelo 2D estilo Atari Combat (1977), 2 jugadores o contra la máquina | terminado |

## Drones de Combate

Es el grande. Motor 3D (Three.js) en un solo archivo de ~248 KB.

Lo que ya trae:

- **Mundo real de verdad.** Le das unas coordenadas y descarga la **altura real**
  del terreno (teselas Terrarium de AWS), la **imagen satelital** (ESRI) y de
  **OpenStreetMap** los **edificios con su forma real**, las calles, los ríos, los
  lagos y el arbolado. Nada de esto necesita llave de API ni cuenta.
- El campo abarca **2,4 km** a escala correcta: **1 unidad ≈ 5,2 metros**.
- Ciudades ya listas — Bogotá (Plaza de Bolívar y Chapinero), Medellín, Cali,
  Cartagena, Nueva York, París, Tokio… — y un campo para meter **cualquier
  coordenada del planeta**.
- Nueve lugares naturales (Chicamocha, Nevado del Ruiz, Everest, Cotopaxi…).
- Garaje con piezas intercambiables, misiones, ciclo día/atardecer/noche, clima,
  sensores EO/IR/nocturno, mando táctil, y puntería por **mirada con la webcam**.

### Correrlo

```bash
python -m http.server 8199 --directory "C:/Users/joanh/OneDrive/Desktop/maquinas"
```

Y abrir <http://localhost:8199/drones.html>.

Tiene que servirse por `http://` o `https://`, **no vale abrirlo con doble clic**
(`file://`): el navegador bloquea las descargas del terreno y la webcam.

### Probarlo sin jugar

Añadiendo `?dbg` a la URL aparece `window.DRONES` en la consola: una API para
medir el juego sin tener que jugarlo. Por ejemplo:

```javascript
DRONES.realInfo()    // cuántos edificios, calles y árboles se levantaron
DRONES.droneInfo()   // qué dron, a qué altura, con qué cámara
DRONES.dtp(x, y, z)  // teletransportar el dron
DRONES.simN(60)      // 60 pasos de física sin dibujar (mide la lógica pura)
```

## El núcleo está abierto a contenido

Casi todo el juego son **registros de datos**: para añadir cosas no hay que tocar
el motor, basta con agregar una entrada.

| Registro | Qué añade |
|---|---|
| `CIUDADES` | ciudades listas para desplegar (nombre + lat/lon) |
| `REAL_MAPS` | lugares naturales del planeta |
| `CATALOG` | piezas del garaje: chasís, cañón, 2ª arma, blindaje, motor, dron |
| `MISSIONS` | misiones: bioma, enemigos, objetivos |
| `BIOMES` | mundos procedurales (color, relieve, props) |
| `TODS` / `WEATHER` | horas del día y climas |

## Historia

Los dos juegos vivían sueltos en `Desktop\Joan te presta\`, una carpeta sin
control de versiones. En agosto de 2026 se mudaron aquí y el proyecto pasó a
llamarse **Máquinas**. El primer commit de este repo es una copia intacta de los
archivos originales, por si hay que volver atrás.

La marca sigue siendo **Joan te presta**, que es el paraguas de las mini apps.
