# Drones de Combate frente a los simuladores de referencia

**Veredicto.** El simulador abarca más que cualquiera de los civiles: aire, tierra y mar, terreno real de cualquier punto del planeta, eras históricas y entradas que nadie más tiene. Pero se queda corto justo en lo que hace que un simulador forme pilotos:

- **El mando.** No lee emisoras ni gamepads, y el gas tiene solo tres posiciones.
- **La consecuencia.** Chocar no cuesta nada.
- **La evaluación.** La escuela está rota en tres puntos y no pone nota.

Mientras eso siga así, ningún instructor contaría estas horas como horas de simulador. La tanda 1 de la ruta ataca exactamente esos tres puntos.

Notas para leer el documento:
- Los números de línea son del fichero que revisaron los verificadores. Joan edita en paralelo y pueden haberse movido; hay que buscar por nombre de función.
- DRL Sim queda fuera de la tabla porque su backend está apagado y solo vive con parches de la comunidad. Uncrashed y TRYP se comportan como Liftoff en todo lo que importa aquí.

---

## 1) Tabla comparativa

Leyenda: **si / parcial / no / n.a.** (no aplica). `*` = inferido, no documentado en lo investigado. `s.d.` = sin dato.

| # | Capacidad para formar pilotos | **Nuestro** | Liftoff | VelociDrone | DJI Flight Sim | Zephyr | Obriy | VBS4 |
|---|---|---|---|---|---|---|---|---|
| 1 | Mando analógico real: emisora o gamepad por USB, con calibración y zona muerta | **no** (cero `getGamepads`) | si | si | si (mandos DJI por USB) | si* | si* | si |
| 2 | Gas proporcional y 4 ejes en PC | **parcial** (gas de 3 estados; alabeo solo con el celular) | si | si | si | si | si | si* |
| 3 | Modos progresivos GPS → ATTI/Angle → Acro | **parcial** (FÁCIL y ACRO, sin escalón intermedio) | si | si | si (P/A/S) | si (GPS/ATTI/CourseLock) | si | parcial* |
| 4 | Perfil del piloto: rates, expo, uptilt, FOV | **no** (540 °/s, expo 0,65, cámara a 25° y FOV 95°, todo fijo) | si | si | parcial (EXP y sensibilidad) | parcial* | parcial* | parcial* |
| 5 | Choque con consecuencias: suelo, edificios, hélices, reinicio | **no** (atraviesa edificios; el suelo solo frena la caída) | si | si (daño en pasos de 25%) | si | si (chocar = suspenso) | si* | si* |
| 6 | Viento configurable que actúa como arrastre sobre el aire relativo | **parcial** (racheado y con gradiente, pero rumbo fijo y, en ACRO, empuja como una aceleración) | si (con sotavento) | parcial* | si | si* | si | si* |
| 7 | Aerodinámica fina: VRS/propwash, efecto suelo, caída de voltaje (sag) | **parcial** (sag sí; efecto suelo casi muerto; sin VRS) | si | si | parcial* | parcial* | parcial* | no* |
| 8 | Enlace que cae por distancia, relieve y edificios | **parcial** (distancia y relieve; los edificios no tapan) | si | si (ruido de VTX por distancia) | si | si (pérdida por línea de vista) | si (Friis + Fresnel) | parcial* |
| 9 | Guerra electrónica por canal (control/video/GNSS) y fibra con largo real | **parcial** (jammer único de 95 u; fibra inmune y sin fin) | no | no | no | parcial (GPS "Unreliable") | si | si |
| 10 | Navegación y failsafe: OSD con altitud, velocidad y casa; RTH creíble; vuelo sin GNSS | **parcial** (OSD con voltaje y RSSI; en ACRO el RTH hace loops sin fin; el GPS nunca se pierde) | parcial (OSD sí, sin RTH) | parcial | si (3 tipos de RTH) | si (ATTI, HomeLock) | si | parcial* |
| 11 | Vista del piloto en tierra (VLOS) y orientación | **no** | si* | si* | si (Pilot FPV) | si (Nose In/Out) | n.a. | parcial* |
| 12 | Currículo con nota, umbral de aprobación y desbloqueo | **parcial** (9 lecciones con crono; Reintentar y Siguiente rotos, e3 imposible, sin nota) | parcial | parcial | si (hover en 7 niveles, Fly Track en 8) | si (120+ módulos, LMS) | si | si |
| 13 | Repetición, DVR o fantasma | **no** | si (T rebobina) | si (Nemesis) | parcial (ruta volada en 3D) | s.d. | s.d. | si (AAR 3D) |
| 14 | Instructor y debriefing: fallas inyectadas, informe exportable | **no** | no | no | parcial (interferencia aleatoria) | si (CSV con choques y violaciones) | parcial (editor de misiones) | si |
| 15 | Reconocimiento e identificación: zoom, térmico, siluetas | **parcial** (filtro IR sin zoom; "marcar" un blanco es pasar cerca) | n.a. | n.a. | parcial (búsqueda y rescate) | si (térmica con 9 paletas) | si | si |
| 16 | Vehículos terrestres y marinos con física propia | **parcial** (orugas y casco con olas, pero el UGV acelera por suavizado, el timón es incoherente y el submarino sale del agua) | n.a. | n.a. | n.a. | n.a. | n.a. | si |
| 17 | Terreno real de cualquier punto (satélite, relieve, edificios OSM) | **si** | no | no | no | no | parcial (solo el frente: 50.000 km²) | si (licencia militar) |
| 18 | En el navegador, sin instalar, con táctil, celular o webcam | **si** | no | parcial (versión móvil) | no | no | no | no |

**Lo que solo tenemos nosotros** (ninguno de los seis lo reúne):
- **Pilotar con la cabeza por webcam** (MediaPipe, con ritual de centrado), **usar el celular como mando por WebRTC** y **apuntar con la mirada**, todo en el navegador sin instalar. Los otros simuladores web (fpv0, WebFPV) no tienen cara ni celular. MSFS y opentrack usan la cabeza para mirar, no para pilotar.
- **Cualquier lugar del mundo con relieve, satélite y edificios OSM, gratis.** Solo VBS4 llega a eso, con licencia militar. Obriy se limita al frente ucraniano.
- **Aire, tierra y mar en un mismo producto civil**, en español, con eras históricas y documentales. VBS4 es multidominio, pero militar y sin esa capa histórica.

**Donde estamos más lejos:**
1. **Mando real.** El primer paso de los currículos ucranianos es "calibrar los sticks", y nosotros ni siquiera leemos el mando.
2. **Consecuencia del choque.** Sin choque, las puertas y el vuelo urbano no enseñan nada.
3. **Evaluación.** La escuela tiene tres fallos que la rompen, no hay nota y no hay repetición.
4. **Instructor y debriefing.** Zephyr, DJI y VBS4 lo tienen; nosotros nada.

---

## 2) Ruta ordenada por valor formativo y costo

★ = una de las **6 imprescindibles de la próxima tanda**. Se han usado las correcciones de los verificadores donde contradicen la propuesta original.

**Calendario estimado** (sesiones diarias desde el 2-oct): tanda 1 (★1-6) hasta el **~10-oct**; tanda 2 (7-11) hasta el **~17-oct**; tanda 3 (12-15) hasta el **~24-oct**.

**Lo que solo puede hacer Joan:** el ítem 5 necesita que conecte una emisora o un mando físico para la prueba final. Sin esa prueba, la ayuda no puede decir "probado con…".

**Ajustes a `window.DRONES` que piden las mediciones** (una línea cada uno, se hacen con el ítem 1):
- `escuela:(id)=>startEscuela(ESCUELA.find(m=>m.id===id))`;
- un campo `mision` en `state()`;
- un campo `gas` en `palanca()` y en `rate()`.

### 1 ★ Una escuela que funciona: Reintentar, Siguiente, e3 completable y reinicio con X
*Valor alto · costo bajo*
- **Dónde:** `startEscuela` (L9609); los botones pRestart (L9889), rRetry (L9893) y rNext (L9894); la visibilidad en `endMission` (L7791); la rama sin zona de `startEra` (L9780); `updateEscuela` (L9712); el efecto suelo en ACRO (L7079-7080); el keydown (L5605).
- **Cambio:**
  - **Recordar qué se está jugando.** Declarar `let escuelaActual=null, eraActual=null`, asignarlas al empezar y ponerlas a null en `startMission`/`startRealMission`. pRestart y rRetry pasan a llamar `escuelaActual?startEscuela(…):eraActual?startEra(…):currentReal?startRealMission(…):startMission(missionIdx)`. Hoy llaman a `startMission(-1)` y eso lanza un TypeError en `MISSIONS[-1].biome`.
  - **Siguiente.** rNext lleva a la lección siguiente de ESCUELA, o al menú tras la última. L7791 queda `win && !mission.real && (escuelaActual ? idx<len-1 : missionIdx>=0 && missionIdx<MISSIONS.length-1)`.
  - **Altura del suelo.** Definir `const SUELO_DRON=1.2` (en metros) y usarlo en tres sitios: `gy+SUELO_DRON*M` en L7268, `agl-SUELO_DRON<0.35` en L9712 y `aglE-SUELO_DRON` en el efecto suelo de ACRO (hoy casi muerto). Guardar `drone.vImpacto=drone.vel.y` antes del recorte de L7275 y juzgar e3 con ese valor; si no, un golpe a 15 m/s a 30 fps cuenta como aterrizaje suave. Mientras no llegue el ítem 4, la frase del "colchón" en el texto de e3 hay que reescribirla (regla de honestidad).
  - **`reiniciarIntento()` con la tecla X.** Solo vale con `ESC.activa && playing && !missionResult` y fuera de las lecciones tácticas.
    - Pone el dron en `player.pos+8*M`, con vel=0, `yaw=player.yaw` y pitch/roll/yawVel a 0. En acro, el cuaternión se nivela y wx/wy/wz vuelven a 0.
    - No pasa por `deployDrone`, que apaga el acro.
    - Repone el estado de la lección: `ESC.idx=0`, aros a `hecho=false`, `tHover=0`, `tIni=tFin=null` y `objState[0].done=false`, y llama a `marcarAro()`.
    - Se añade a la pestaña de Controles.
- **Medirlo:**
  ```
  DRONES.escuela('e1'); /* ganar */ document.getElementById('rNext').click(); DRONES.state().mision  // 'esc_e2'
  document.getElementById('rRetry').click(); DRONES.state().playing        // true, sin TypeError en consola
  DRONES.escuela('e3'); /* posarse a 1 m/s */                                // completa
  /* repetir a 4 m/s */                                                      // no completa
  ```

### 2 ★ Candados de seguridad: B solo en multirrotor y un failsafe que nivela
*Valor alto · costo bajo*
- **Dónde:** el keydown de KeyB (L5634-5646); la rama acro (L7027), que hoy va antes que NAVAL (L7085); el failsafe en `readInput` (L6454-6466); `computeSignal` (L7986-7987).
- **Cambio:**
  - **B solo donde tiene sentido.** Exigir `!stats.drone.ala && !['surface','sub'].includes(stats.drone.domain)` y avisar en el feed: "un casco no tiene modo rate". Como segunda barrera, L7027 pasa a `else if(drone.acro && !NAVAL)`. Hoy B hace volar la lancha y el UUV como un cuadricóptero de 2,2 g, y deja la cámara del ala fija clavada.
  - **El failsafe vuelve a modo ángulo** (como GPS Rescue en Betaflight). Al entrar guarda `drone._acroPrev=drone.acro` y pone `acro=false`, `quat=null` y `wx=wy=wz=0`. Mientras dura, B está bloqueada. Al recuperar el enlace restaura el modo y llama a `updateChips()`. `_acroPrev` se limpia en `deployDrone` (L6748) y en L7568. Hoy `dr_pitch=0.6` se lee en rate como unos 190 °/s de cabeceo continuo: loops sin fin.
  - **Histéresis.** Se entra con `signal<0.14` y solo se sale con `>0.25` sostenido 1,5 s (`drone._recupT`). `linkAuth` se deriva de `linkLost`.
  - **Por tipo de aparato.** En naval, el RTH usa `dr_pitch=0.8`. En ala fija se dirige con `dr_roll` y, al llegar, `drone.orbita={x:cmdPost.x,z:cmdPost.z}`.
- **Medirlo:**
  ```
  DRONES.start(0); DRONES.toggleDrone(); DRONES.acroOn(true); DRONES.forzarSenal(0)
  for(let i=0;i<10;i++){ DRONES.simN(30); const r=DRONES.rate(); console.log(r.pitch, r.invertido) }
  // esperado: |pitch| ≤ 35 e invertido=false en las 10; DRONES.sys().acro === false
  DRONES.forzarSenal(null); DRONES.simN(120); DRONES.sys().acro            // true otra vez
  // con el dron marino: disparar keydown {code:'KeyB'} → DRONES.sys().acro === false
  ```

### 3 ★ Gas analógico y cuarto eje en PC
*Valor alto · costo bajo-medio*
- **Dónde:** en `readInput`, el objeto inp (L6399), la rama dron (L6407), el táctil (L6418-6421), el celular (L6438), PALANCA_DBG (L6444) y el failsafe (L6463). En `updateDrone`, `lift` (L6929), `thr` (L7068), la batería (L6899) y `gasR` (L7303). También el visor (L6391-6393) y padTick (L8857).
- **Cambio:**
  - **Un gas que no se recentra en ACRO.** Nuevo `drone.gas ∈ [0,1]`.
    - Teclado: Espacio sube `+1.2/s` y Mayús baja `−1.6/s`.
    - Táctil: `drone.gas=clamp(drone.gas-TS.R.dy*1.4*dt,0,1)` (integrar, porque TS.R se recentra).
    - Celular: `clamp(drone.gas+throttle*1.2*dt,0,1)`, hasta que padScreen tenga un deslizador.
  - **Empuje.** Con `IDLE=0.055`: `thr=(IDLE+(1-IDLE)*drone.gas)*TWR*9.81*M*power`, sin `Math.min(1,TWR)`. El estacionario queda en `gC=clamp((1/(TWR*power)-IDLE)/(1-IDLE),0,1)`, unos 0,423 con TWR 2,2 (no 1/TWR). La curva thr_mid/expo queda para el ítem 8.
  - **Arranque en estacionario.** `drone.gas=gC` en los tres sitios donde se entra a ACRO: KeyB L5634, startEscuela L9622 y DRONES.acroOn L10439. También al lanzar (L6748) y en `soltarEntradas` (L5660). El failsafe y PALANCA_DBG fijan gas=gC.
  - **FÁCIL no cambia:** `lift` sigue siendo velocidad vertical.
  - **Alabeo.** Solo si `drone.acro || stats.drone.ala`: A/D → `dr_roll` y ←/→ → `dr_yaw`, leyendo `keys` dentro de la rama dron. No se tocan L6401-6402, que alimentan el UGV.
    - Rampa `_kbAlabeo=damp(_kbAlabeo,obj,1/0.15,dt)`: un toque de 80 ms da unos 72 °/s, no 540.
    - En el ala: A/D → `inRoll` (45°), y la fuga de guiñada de L6926-6927 queda envuelta en `if(!stats.drone.ala)`.
    - No usar Ctrl como modificador: Ctrl+W cierra la pestaña.
  - **Consumidores del gas.** Batería `0.6*gas^1.5`. `gasR` con el gas real. Visor: caja derecha `(dr_roll, dr_pitch)` sin `||dr_yaw`; caja izquierda `(dr_yaw, gas absoluto)` con una marca en gC. OSD: «THR nn%» en `dibujarOSD`.
  - **Textos** que hay que reescribir en el mismo cambio: L5641, L9625, L5966, L6843 y la descripción de e4/e5.
- **Medirlo:**
  ```
  DRONES.escuela('e4'); const y0=DRONES.droneInfo().y
  DRONES.palanca({gas:0.423}); DRONES.simN(180); DRONES.droneInfo().y-y0   // |Δ| < 0,1 u (≈0,5 m)
  DRONES.palanca({gas:0});   DRONES.simN(60)                                 // Δy < −1 u: cae
  DRONES.palanca({gas:0.423, roll:1}); DRONES.simN(20); DRONES.rate().wz     // alabeo real ≠ 0
  ```

### 4 ★ Chocar tiene consecuencias: suelo, edificios, hélices y modo sin daño
*Valor alto · costo medio*
- **Dónde:** nueva `chocarDron(dt)` justo después de `drone.pos.addScaledVector(drone.vel,dt)` (L7257); el suelo (L7268-7275); `damageDrone` (L5411-5421), de donde se separa `perderDron(motivo)`; los colliders (L2329 ruinas, L3606 OSM); el picado kamikaze (L7271); la rama FÁCIL (L7204-7225); la cámara FPV (L7429-7466); TWR (L6891); `store.env` (junto a L9805).
- **Cambio:**
  - **Primero, protección de aterrizaje en FÁCIL.** Antes de L7225: `if(aglF<30) _dv3.y=Math.max(_dv3.y,-(1.5+0.4*aglF)*M)`. Sin esto, todo aterrizaje de principiante a 15 m/s sería un choque.
  - **Suelo** (solo en la rama aérea; nunca surface, sub ni amph). Se usa la velocidad normal al terreno `vN`, sacada del gradiente de `terrainHeight`, para que las laderas del cañón cuenten.
    - Por debajo de 1,5 m/s: posado, con `damp(vel.x,0,6,dt)`.
    - De 1,5 a 4 m/s: rebote de 0,3 y −25 % de hélice.
    - Por encima de 4 m/s: caído.
    - En el ala fija se frena `vAire`, o el contacto por encima de VP cuenta como caído.
  - **Obstáculos.**
    - Se recorre el 3×3 de celdas, como hace `resolveColliders` (L5563). Radio del dron `0.5*M`, que dependa de `stats.drone`.
    - El círculo queda solo como prefiltro. La prueba real es punto-en-polígono con `pts` guardado en L3606 y caja orientada `{w,d,rot}` en L2329. Hoy el círculo choca a unos 30 m del muro corto de las ruinas.
    - **Techo:** si en el cuadro anterior (`_yPrev`) el dron estaba por encima del edificio, el contacto es de techo, con normal vertical, y se puede posar.
    - **Umbrales:** por debajo de 2,5 m/s, rebote (restitución 0,3); de 2,5 a 8 m/s, `drone.helices-=0.25`; por encima de 8 m/s o con hélices a 0, `perderDron('choque')`.
  - **Efecto de la hélice dañada.** `TWR*=1-0.35*(1-drone.helices)` en L6891. Un sesgo fijo de guiñada `±(1-helices)*0.6` sumado a yawVel, no ruido por cuadro. Temblor de cámara de 0,002 a 0,006 rad en `updateCamera`, también en la rama acro. Sacudida con `drone.golpeT` (`recoilT` solo funciona en el UGV).
  - **Kamikaze.** Si el picado toca un collider, `detonateDrone()`. Hoy atraviesa las casas y mata a lo que hay detrás.
  - **Según el contexto.**
    - Escuela: no se destruye; reaparece a los 1,2 s en `ESC.aros[ESC.idx-1].m.position`, o en el despegue si `idx===0`.
    - Combate: `perderDron`, no `damageDrone` (que marca al jugador como detectado y lanza hudFlash).
    - Duelo: `dueloDerribado()`.
    - Gracia de 1 s después de desplegar.
  - **Interruptor «Sin daño».** `store.env.sinDano`, que ya se persiste. Reponer `helices=1` en `deployDrone`.
  - **RTH.** Al entrar en failsafe calcula una sola vez el perfil hasta casa y sube por encima del obstáculo más alto. Si no, el failsafe se estrella solo en la ciudad.
- **Medirlo** (con un helper nuevo, `DRONES.choque(v_ms)`: coloca el dron a 3 m del collider más cercano y en rumbo hacia él):
  ```
  DRONES.choque(2)  → {helices:1, caido:false}
  DRONES.choque(5)  → {helices:0.75}
  DRONES.choque(10) → {caido:true}
  DRONES.palanca({down:true}); DRONES.simN(900); DRONES.droneInfo().vImpacto   // ≤ 2 m/s en FÁCIL desde 60 m
  DRONES.cronometro()   // antes y después: ≤ +0,2 ms por cuadro
  ```

### 5 ★ Emisora y gamepad (Gamepad API) con asistente de calibración
*Valor alto · costo medio · depende del 3*
- **Dónde:** un bloque `GAMEPAD` nuevo (el nombre MANDO ya es el celular). `leerMando(inp)` se llama después de teclado, táctil, cara y mano (tras L6432) y antes del celular (L6435), de PALANCA_DBG, de linkAuth y del failsafe. Los botones se leen en `frame()` junto a padTick (L8396), detectando el flanco. El asistente va en la pestaña Controles (L792). `store.mando` se valida en `load()` (L1016).
- **Cambio:**
  - **Lectura.** `navigator.getGamepads()[GAMEPAD.idx]` en cada cuadro, sin guardar el objeto y con comprobación de null.
  - **Desconexión.** Llama a `doPause()` (en duelo, solo avisa) o activa una bandera propia que se suma a la condición del RTH. No se escribe `linkLost`, que se recalcula en cada cuadro.
  - **mapping 'standard' (Xbox/PS), Modo 2.** axes[0] guiñada, axes[1] gas `(1-a)/2` con resorte al estacionario, axes[2] alabeo, axes[3] cabeceo `-a`. La zona muerta inicial es `max(0.08, 3σ medida)`; los mandos gastados llegan a 0,24.
  - **mapping '' (EdgeTX/OpenTX).** No se adivina nada: se abre el asistente.
    1. Centro: mediana de 30 muestras y σ durante 1 s.
    2. Extremos, incluidas las esquinas.
    3. Asignación por movimiento ("sube el GAS", "alabeo a la derecha"…). Así se resuelven a la vez Chrome frente a Firefox y AETR frente a TAER.
    4. Zona muerta de 0 a 0,25 por lado, con `sign(x)·max(0,|x|−dz)/(1−dz)`, la misma fórmula que bindStick.
    5. Prueba en un canvas propio, porque el visor de L6352 no se pinta en el menú.
  - **Guardado.** `store.mando[gp.id]` queda fuera de la copia exportada, porque el id cambia entre navegadores. El UGV también se maneja con el mando.
  - **Estado visible:** «🎮 Conectado: <id>» o «No detectado: emisora en modo USB Joystick, cable de DATOS, mueve una palanca con esta ventana al frente».
- **Medirlo** (con `GAMEPAD_DBG`, un gamepad falso que `leerMando` usa si existe):
  ```
  DRONES.mandoFalso({mapping:'standard', axes:[0,-1,0,0]}); DRONES.simN(2); DRONES.rate().gas   // 1
  DRONES.mandoFalso({mapping:'standard', axes:[0.05,0,0.05,0.05]}); DRONES.vuelo().yawVel       // ≈0 (zona muerta)
  DRONES.mandoFalso(null)   // vuelve el teclado
  ```
  Prueba final con hardware: le toca a Joan.

### 6 ★ Modo ÁNGULO (ATTI): el escalón entre FÁCIL y ACRO
*Valor alto · costo medio*
- **Dónde:** en `updateDrone`, una rama nueva `else if(drone.atti)` **después** de NAVAL y antes del else final (L7193). B cicla FÁCIL → ÁNGULO → ACRO. También el OSD (L6320/L6332), el chip (L8054), la ayuda (L833-834, L5966) y `startEscuela` (L9622).
- **Cambio:**
  - **Booleano aparte.** `drone.atti`, sin reemplazar `drone.acro`, que se lee en 14 sitios.
  - **La palanca pide ángulo.** `drone.pitch=damp(drone.pitch,inPitch*tiltEf,8,dt)`, y lo mismo para el alabeo. `tiltEf=min(TILT_MAX, acos(1/max(TWR,1.01)))` hay que recalcularlo, porque es local de FÁCIL.
  - **La aceleración sale del ángulo.** `G_U*tan(pitch)` sobre fwd y `G_U*tan(roll)` sobre right, menos un arrastre cuadrático sobre el aire relativo con `k=G_U*tan(TILT_MAX)/VEL_DRON²≈0,04`. **Sin velocidad objetivo:** al soltar, el dron nivela pero sigue rodando, y el viento lo mueve al 100 % (en FÁCIL, al 18 %).
  - **Altura.** Se reutiliza la vertical de FÁCIL (L7203-7211, L7225), que hace de barómetro como el A-mode de DJI. El ANGLE con gas manual de Betaflight espera al gamepad, porque con gas digital e inclinación el dron se hunde.
  - **Nombres en el OSD.** FÁCIL pasa a "ALTH" (no "POSH", porque el viento lo mueve), luego "ATTI" y "ACRO".
  - **Lección nueva 'e3b'** «Sin GPS: el viento es tuyo»: `modo:'atti'`, con viento, objetivo hover de 15 s y r 3,5. Solo cambian los `name` de e4 a t3; los ids no, porque los récords van por id.
  - **Segundo paso, opcional en la tanda:** `gpsNegado` con radio propio de más de 95 u, que valga también para la fibra y se calcule antes del early-return de L7972. Con él, FÁCIL cae a ATTI, y el failsafe sin GNSS nivela y deriva en vez de volver a casa.
- **Medirlo:**
  ```
  DRONES.escuela('e3b'); DRONES.palanca({pitch:1}); DRONES.simN(180); DRONES.vuelo().vel  // ≈5,7 u/s (VEL_DRON) ±10 %
  DRONES.palanca({}); DRONES.simN(30); DRONES.vuelo()        // pitch≈0 pero vel > 50 % de la anterior
  DRONES.simN(600); DRONES.vuelo().vel / DRONES.viento().medio   // 0,85-1,15 (en FÁCIL ≈0,18)
  ```

### 7 OSD de navegación y aviso «VUELVE YA»
*Valor alto · costo bajo*
- **Dónde:** `dibujarOSD` (L6295; se activa en L6297), `OSD_ULT` (L6332), el catálogo (L1289-1318) y `updateDrone` junto a `power` (L6916-6929); en `updateHUD`, L8166.
- **Cambio:**
  - **Altitud y velocidad.** ALT AGL `(pos.y−terrainHeight)*MPU`, en rojo por encima de 120 m. km/h `vel.length()*MPU*3.6`. En el ala fija, la velocidad del aire y PÉRDIDA.
  - **Flecha a casa** (cmdPost), con el signo corregido: `g.rotate(drone.yaw − atan2(cmdPost.x−x, cmdPost.z−z))`, y debajo "H 840m". En ACRO el rumbo sale de `camera.getWorldDirection`, porque el yaw de Euler voltea al ir invertido. Hay que revisar `dueloMarcador` (L8616), que probablemente invierte izquierda y derecha.
  - **mAh.** Un campo `mah` por dron, en todos (también ave, marino, sub e híbrido), coherente con 20 min de autonomía (unos 5000 por defecto): `(1−batt)*mah`.
  - **Enlace.** `LQ=round(clamp((signal−0.14)/0.30,0,1)*100)` y dBm `−50−55*(1−signal)`. Con fibra se muestra "FIBRA". "RSSI CRITICO" pasa a basarse en LQ.
  - **Voltaje real.** `drone.volt` con una curva LiPo por tramos y la caída según `drone.gasFrac`.
  - **«VUELVE YA».** Con `battRegreso=(dist_m/(0.8*velEf*power))*0.000833*(mTot/mBase)^1.5`, el aviso salta si `batt<1,25·battRegreso`. Orden de prioridad: FAILSAFE > ATERRIZA YA > VUELVE YA > BATERÍA BAJA > RSSI.
  - **Honestidad.** Hoy, con batt=0 el dron sigue volando al 30 % y F lo recoge desde cualquier distancia. O batt=0 pasa a ser descenso forzado y pérdida del dron, o el aviso se rotula como formativo.
  - **Ala fija.** "H x km" también en #telem, porque el ala arranca en la cámara 360°, donde no hay OSD.
- **Medirlo:**
  ```
  // dron 'fibra' + carga 'rpg', a 3 km de cmdPost
  DRONES.setBatt(0.35); DRONES.sim(); DRONES.osdInfo().aviso   // 'VUELVE YA'
  // mismo caso sin carga → sin aviso (umbral ≈0,15)
  DRONES.rumbo(0) con la casa al este → la flecha apunta a la derecha
  ```

### 8 Perfil del piloto: uptilt, FOV y tasas
*Valor alto · costo bajo*
- **Dónde:** `ajustarGimbal` (L6826), por donde pasan Q/R, la rueda y DRONES.setGimbal; `updateCamera` (0.44 en L7436 y el FOV en L7477); las tasas (L7051-7062); `updateChips` (L8051); `store` + `load()`.
- **Cambio:**
  - **Uptilt.** En acro, Q/R/rueda cambian `drone.uptilt` de 0 a 60°, a unos 15 °/s y en grados enteros. Se guarda solo al cambiar el grado, nunca en cada cuadro. Valores de fábrica: recon 15°, ataque 25° (e4, e5 y t2 están calibradas con 25°), cargero 10°, ave 10°, resto 25°. Chip: "CAM 25° fija".
  - **FOV.** `store.cam.fovH=120` (90-140), con `fovV=2·atan(tan(fovH/2)/aspect)` y tope de 100°. `+marcha*8` desaparece solo en acro. Teclas: `e.key` '−'/'+' y el teclado numérico, porque en el teclado latinoamericano `e.code` no corresponde.
  - **Tasas Actual por eje.** Por defecto, **70/540/0** (con 670, el teclado digital giraría un 24 % más rápido). Preajustes: Alumno 70/450/0,2, Carreras 70/600/0,3, Freestyle 100/850/0,4. El peso deja de bajar la tasa máxima y pasa al seguimiento: `damp` con `18·mk²`.
  - **Puntería del duelo** (L8703): usar el vector de la cámara acro.
- **Medirlo:** `DRONES.acroOn(true); DRONES.setGimbal(0.17)` → el chip pasa a 35°. `DRONES.vuelo().fov` da ≈88,5 en 16:9 y no cambia con la marcha. `DRONES.palanca({pitch:1}); DRONES.simN(30); DRONES.rate().wx` da ≈540.

### 9 Viento honesto: arrastre relativo, rumbo por misión y deslizadores
*Valor alto · costo bajo*
- **Dónde:** ACRO (L7072-7076), ala (L7011), `applyEnvironment` (L2124), `vientoAhora` (L6793 y L6807-6810), cascos (L7137-7138), #condBar con `seg()` (L9805).
- **Cambio:**
  - **ACRO.** `_dv3.copy(drone.vel).sub(w); vr=_dv3.length(); drone.vel.addScaledVector(_dv3,-Math.min(1,(0.2+0.038*vr)*dt))`. Conserva la punta de unos 142 km/h. La deriva converge al viento en unos 3 s. Hay que actualizar el comentario "k=0,064".
  - **Ala fija.** Factor 0,6 → 1,0, para que el alumno aprenda a corregir la deriva (crab).
  - **Rumbo por misión.** `h2(SEED,missionIdx)*TAU`, calculado en `deployMission`. Nunca `Math.random` dentro de `applyEnvironment`, que se llama desde 6 sitios. Una flecha en el OSD, relativa al morro.
  - **Turbulencia tipo Dryden** con `L=30*M` y la velocidad respecto al aire. **Sotavento:** muestrear `bucketAt` a barlovento; detrás de un edificio, viento medio ×0,35 y turbulencia ×2, solo por debajo de una altura tope.
  - **Deslizadores:** velocidad 0-15 m/s, ráfaga 0-100 % (hoy 0,45 fijo), turbulencia 0-100 %. Se guardan en `VIENTO_INST`, que se borra en `resetPlay`: es la misma trampa del viento que se quedaba pegado (L7540).
- **Medirlo:** `DRONES.viento()`, que hay que ampliar con `dir`. Con las palancas al centro en estacionario, `vuelo().vel/viento().medio` debe dar 0,9-1,1 a los 180 cuadros. A fondo y sin viento, `rate().vel_kmh` entre 135 y 148. Tras `DRONES.setEnv(null,'niebla')`, `dir` no cambia.

### 10 Circuitos a escala real y nota de precisión
*Valor alto · costo bajo*
- **Dónde:** `crearEscenarioEscuela` (L9629-9666), `updateEscuela` (L9677-9716), `checkObjectives` (L7751), `endMission` (L7767/L7790), `renderEscuela` (L9729).
- **Cambio:**
  - **Aros en metros.** Diámetro `o.dM`: e2 y e4 de 3 a 3,5 m, e5 2 m, t3 4 m. Tubo de `0.12*M` con banderín. Centro a ≥ r+0,5 m sobre el terreno más alto de x±r. Tramos de 15-25 m girando de 0,3 a 0,8 rad. En e6 (ala fija) se mantienen unos 300 m entre puertas, porque el radio de viraje es de 147 m, y la puerta pasa a 6-8 m.
  - **Cruce por el plano.** Contar cuando `(pos−prev)·n<0` y radial<r (el `lookAt` apunta al aro anterior). `ESC.prev` vuelve a null en idx++, en `limpiarEscuela` y en la salida temprana. Tocar el tubo: rebote ×0,4 y +2 s.
  - **Unidades sueltas.** Corregir el +2 crudo de e1 (son 10 m) y la plataforma de e3: radio `1.5*M` (hoy 8,4 m).
  - **Nota.**
    - Aros: distancia al centro dividida por r.
    - Hover: % dentro desde la primera entrada, más el RMS.
    - Aterrizaje: `70·max(0,1−dist/R)+30·(1−v/vmax)`.
    - Medallas: bronce 60, plata 80, oro 92, en `store.escuela[id]` (añadir a `load()`). La lección siguiente se desbloquea con bronce.
    - `endMission` muestra crono, parciales y nota, y no guarda `store.best`.
  - **Récords.** Clave versionada (`id+'@v2'`) solo en cronos. Si no, el primer intento en el circuito nuevo anuncia un RÉCORD falso.
  - **Bitácora de horas** por modo. Sin citar las "20-25 h del UALC" mientras no haya fuente.
- **Medirlo:** `DRONES.escuela('e2')` y luego `ESC.aros.map(a=>a.r*MPU*2)` debe dar `[3,3,…]`. Pasar por fuera o al revés no cuenta. `DRONES.progreso()` muestra `{nota, medalla}`.

### 11 Vista del piloto en tierra (VLOS)
*Valor alto · costo bajo*
- **Dónde:** en `updateCamera`, una rama `droneCam===3` antes de `drone.acro && drone.quat` (L7429); DRONECAM_NAMES (L4349); `cycleCam` (L7528); el FOV (L7477); `updateChips`.
- **Cambio:**
  - **El ojo.** En `cmdPost.x+2*M, cmdPost.z+2*M`, a `terrainHeight+1.7*M`, fuera del mástil y sin lerp. La cámara sigue al dron con `_mirPil.lerp(drone.pos,1−e^(−6dt))`, mantiene up (0,1,0) y usa FOV 50 sin el efecto de marcha.
  - **«FUERA DE VISTA»** con un umbral angular (tamaño/dist < 0,0015 rad; el tamaño sale de un Box3 calculado al desplegar) o con `IA.losBlocked` a 4 Hz.
  - **Chip** "PILOTO · 32 m", repintado cada 10 m. No disponible con el submarino.
  - **Lecciones.** e1 sirve tal cual (aro a unos 30 m). e3 necesita la plataforma a 30-50 m. Los ejercicios de orientación (morro, cola, lados ±25°) van en ATTI, porque en FÁCIL el dron se sostiene solo y no habría nada que medir.
- **Medirlo:** con `DRONES.cycleCam()` cuatro veces, `droneInfo().cam==='PILOTO'` y `vuelo().fov===50`. Distancia horizontal entre cámara y cmdPost ≥ 2 m.

### 12 Los edificios tapan el enlace, y lección «Se va el video»
*Valor alto · costo medio*
- **Dónde:** `computeSignal` (L7970-7988); una función nueva `atenEnlace(a,b)` que copia `IA.losBlocked` (L4899-4926) pero cuenta cruces; un campo `tipo` en los push de colliders (L2291, L2311, L2329, L3606, L3794); el mástil (L7647-7652); el HUD (L8167).
- **Cambio:**
  - **Antenas a escala.** Puesto en `cmdPost.y+3*M` (mástil reescalado a 3 m; hoy mide 36,5 m), dron `+0.1*M`, UGV `+1.15*M`.
  - **Pérdidas.** Edificio ×0,55 con un máximo de 3 cruces o un piso de 0,2, para que el RTH no salte entre manzanas. Árbol ×0,85-0,9. Primera zona de Fresnel (λ=0,052 m) calculada sobre las mismas muestras, en lugar de mirar la altura sobre el suelo. Muestras: `clamp(dist/3,18,90)`.
  - **Motivo visible.** `enlaceMotivo` ('LOS: edificio', 'LOS: loma', 'distancia') en L8167. Actualizar el comentario de L987 y el texto de porQue (L6204).
  - **Lección e7 «Se va el video»** (recon).
    - Fase 1: un aro tras una loma, buscado con `losClear`, y salida directa a la fase 2 si no hay loma. No promete failsafe.
    - Fase 2: cortes cada 8-20 s, de 0,6 a 2 s. El corte se fuerza **después** del damp, junto a SENAL_DBG (L7985): el primer segundo `signal=0.2` (el alumno aún puede subir) y luego `0.1` (failsafe).
    - Una capa opaca de nieve en `dibujarOSD`, porque hoy con signal 0,1 la escena se sigue viendo.
    - Puntúa con la entrada cruda, guardada antes de L6446: no estrellarse, no girar a ciegas, soltar las palancas.
    - t1-t3 se renombran a 8-10 sin tocar los ids.
- **Medirlo:** en una misión urbana, `DRONES.sys().signal` detrás de 1, 2 y 3 edificios ≈ 0,55ⁿ × el factor de distancia, nunca por debajo de 0,2. `sys().linkLost` debe dar false al despegar en Bajmut, Taipéi y Chicamocha. `DRONES.cronometro()` sin aumento apreciable.

### 13 Marino que enseña: timón con chorro, varada y submarino bajo el agua
*Valor alto · costo bajo*
- **Dónde:** la rama NAVAL (L7085-7192), el giro genérico (L6926-6927), minY (L7266-7267), `computeSignal` antes de L7984, el failsafe (L6454), porQue (L6183-6187), las notas (L1315, L6215), el telem (L8137).
- **Cambio:**
  - **Giro.** El giro genérico solo si `!NAVAL`. Se invierte el signo de L7125 (yawVel>0 = estribor) **y también** la escora: `+yawVel*1.1` en L7152 y `+yawVel*0.5` en L7190, para que escore hacia dentro.
  - **Timón con chorro.** `vChorro=gas>0?0.2*VMAX*sqrt(gas*power):0`; `flujo=clamp(hypot(vProa,vChorro)/(VMAX*0.35),0,1)`. Dando atrás, el timón gobierna al revés. Efecto evolutivo de la hélice solo en superficie.
  - **Varada.**
    - Se comprueba tras L7264, solo con `water.visible`; calado `0.35*M`.
    - Daño una sola vez por encallada (`damageDrone(v*2)` si v>1,5 m/s), con el feed frenado a uno cada 2,5 s.
    - Solo se anula la componente de la velocidad que va hacia menos fondo, para poder salir marcha atrás.
  - **Telem.** Superficie: "VEL x kn · SONDA y m", ámbar por debajo de 1,5 m y rojo por debajo de 0,6 (San Andrés tiene 2 m). Submarino: "PROF · FONDO".
  - **Submarino.**
    - Tope en `wl−0.2*M`, con guarda `wl>-9000`.
    - Radio a 0 por debajo de −0,5 m. Va antes de `damp(signal…)`, nunca justo tras la línea de la fibra: ahí da un ReferenceError (TDZ) y congela el juego.
    - En failsafe, emerge (subir + `dr_pitch 0.6`). Los planos muerden solo con marcha avante (`max(0,vProa)`).
    - Añadir `kg` a marino y sub: sin él, el viento empuja al sub con 60 m/s².
  - **Textos** de "sin arrancada no obedece": L1315, L6215 y porQue con `v<VM*0.35 && gas<=0`.
- **Medirlo:** `DRONES.palanca({yaw:1})` (sin gas) → `DRONES.rumbo()` casi no cambia. `palanca({yaw:1,pitch:1})` → rumbo crece y `vuelo().roll>0`. A todo gas contra la playa, `droneInfo().y` no sube y el feed dice VARADO una sola vez. Con el sub sumergido, `sys().signal` cae a 0 y emerge solo.

### 14 UGV honesto: parada segura, aceleración física y vadeo
*Valor alto · costo bajo*
- **Dónde:** `readInput` tras L6448; `updatePlayer` (L6522-6536 y L6577); `resetPlay` (L7565, L7582); `deployMission` naval (L7611-7634).
- **Cambio:**
  - **Parada segura** (lo que hace por defecto un UGV real al perder enlace). `if(mode==='tank' && linkLost){ inp.moveF=0; inp.moveT=0; inp.boost=false; }`, con la torreta topada y "PARADA SEGURA" en #linkWarn, avisado con freno de 3 s.
  - **Aceleración por fuerzas** con ING y `stats.ficha`:
    - Fuerza del motor: `F=min(kW·1000/max(|v|,0.5), μ·m·g·cosθ)`.
    - Resistencias: `Crr·m·g·cosθ·sign(v)` y aire `½ρCdA·v|v|`, más la pendiente `m·g·senθ`, que actúa siempre, también en parado.
    - Tope de velocidad `topeMec·mob`; el impulso se aplica como potencia extra.
    - Se quita `tract` para no contar la pendiente dos veces. Lluvia: μ×0,75.
    - Retención en parado.
    - Freno de μ·m·g: 6,9 m/s² en seco, 5,2 mojado. Hoy meter reversa da 100 m/s².
    - Cabeceo `−accelLong*MPU*0.006`.
  - **Vadeo de 0,5 m**, excluyendo los mapas navales, donde la base empieza a propósito en el punto más hondo. El retorno por migas queda para después.
- **Medirlo:** 0-vRef en llano frente a `stats.ficha.t30`, ±10 % (hace falta añadir `moveF` a PALANCA_DBG). Con `DRONES.forzarSenal(0); DRONES.simN(120)`, `sys().speed→0` y `sys().yawRate→0`.

### 15 Repetición del vuelo (DVR) y fantasma del récord
*Valor alto · costo medio*
- **Dónde:** el muestreo va tras `updatePlayer` dentro de `simulate` (L6269), con un acumulador a 30 Hz. En `frame()` (L8389), una rama `else if(dvr.on) reproducirDVR(dt)`. Las teclas se atienden en el keydown antes de las guardas de `playing`. El botón va en #result, junto a rRetry (L909). El récord, en `updateEscuela` (L9697-9701).
- **Cambio:**
  - **Grabación.** Anillo Float32Array de 60 s × 30 Hz × 16 floats (unos 115 KB): pos, `mesh.quaternion`, yaw/pitch/roll, gimbal, velocidad horizontal, signal, batt, gas y acro.
  - **Reproducción.** Al entrar se guardan, y al salir se restauran, mode, `drone.active`, la visibilidad de la malla, la pose, acro, gimbal, camRollFPV y missionTime. Velocidad de −4× a 4× con ←/→; C cambia de cámara. Bloqueada en duelo.
  - **Rótulo honesto:** «Repetición de tu vuelo». Solo se graba el aparato propio; enemigos y explosiones quedan congelados.
  - **Fantasma.**
    - Se graba a 10 Hz desde `ESC.tIni`, con posiciones relativas al primer aro.
    - Se guarda en una clave aparte, `drones_fantasmas_v1`, con su try/catch. `save()` se traga el error de cuota y dejaría de guardar todo el progreso.
    - La malla sale de `buildAparato(stats.drone,color)`, con materiales propios transparentes al 0,35 y depthWrite false.
    - **Nunca `disposeGroup`:** la caché GEO es compartida y liberarla rompe todas las mallas.
- **Medirlo:** 20 s de vuelo en e2 dan unas 600 muestras. Al salir de la repetición, `DRONES.state().mode` y la posición del dron coinciden con las de antes de entrar. La clave del fantasma ocupa menos de 40 KB y sobrevive a una recarga. `DRONES.cronometro()` no cambia con el fantasma visible.

**Después de las 15, en este orden:**
1. **Aerodinámica:** bajada limitada a 5 m/s en FÁCIL, con techo móvil a juego; VRS en acro con perturbación de 60-90 °/s; ala fija con pérdida a ×√n y barrena como estado.
2. **Suelo a la altura de los patines (0,15 m)**, con plano near dinámico, `alturaMalla` y la plataforma de e3 corregida.
3. **Estación del instructor** con fallas inyectadas.
4. **Guerra electrónica por canal**, más ESM con triangulación.
5. **Radar honesto** (solo lo que alguien ha visto) e identificación con zoom y criterio de Johnson.
6. **Sistema de video elegible**: analógico, HDZero, digital o fibra.
7. **Sonido**: tono del rotor según el empuje y sonido espacial.
8. **UGV avanzado**: latencia, repetidores y terramecánica.
9. **Tráfico marítimo** con AIS y COLREG.

---

## 3) Lo que NO conviene copiar

- **El firmware real corriendo dentro** (Betaflight SITL a 8 kHz, Betaflight en WASM como WebFPV, PX4 en lockstep). En un único HTML el costo es enorme, y solo lo notaría un corredor experto. Nos quedamos con lo que forma: la fórmula de tasas Actual, el límite de ángulo de 60° y el GPS Rescue que nivela.
- **Física por piezas con datos de banco de pruebas** (Liftoff Physics 6.0, el Garaje de VelociDrone). Nuestro alumno no arma drones. La TWR según la carga ya enseña lo que importa, y un sistema de piezas es contenido, no habilidad.
- **Editores de pistas con 2.000 objetos y Workshop.** Producen contenido, no pilotos. Como mucho, circuitos en JSON compartibles por enlace: así viajan por WhatsApp.
- **Paso fijo a 240 Hz para toda la lógica.** Según el verificador, serían 4 pasadas por cuadro y reventarían los 60 fps. Si algún día hace falta: 120 Hz solo para `updateDrone`, con interpolación.
- **Gráficos de Unreal 5, lentes medidas sobre lentes reales, render térmico físico.** El navegador no da para eso. El filtro IR con CSS y la mancha térmica bastan para enseñar el concepto.
- **Hidrodinámica completa (Fossen, Savitsky) y suelo deformable (Bekker-Wong, Chrono SCM).** Una tabla simple de resistencia según el Froude y un tope de pendiente enseñan el 90 % por el 10 % del costo.
- **Mercantes de 180 m con AIS en un mapa de 2,4 km.** Cruzan medio mapa en 3 minutos y el costo es alto. Si se hace, más adelante y con buques de 30-120 m.
- **Lo colectivo militar** (145 portátiles en red, video STANAG 4609 con metadatos KLV, RV como Shooter VR). No forma a un piloto individual en un navegador.
- **Copiar interfaces de equipos militares reales** (Bukovel, Kaskad-P) o el detalle operativo de Obriy. No es público, y un producto civil no debe replicarlo. La guerra electrónica se queda genérica y didáctica.
- **La pérdida de señal como límite del mapa que no se puede apagar** (DRL). Los jugadores la detestan. Ya tenemos geovalla y failsafe, que enseñan lo mismo sin castigar.
- **Bancos de preguntas de examen teórico** (FAA Part 107, EASA). Son otro producto. Además, presentarlos como preparación válida en Colombia (Aerocivil, RAC 100) sin respaldo rompería la regla de honestidad.
- **Puntos canjeables al estilo Army of Drones.** No forman, y atan el producto a una economía que no tenemos.
- **Rates de freestyle por defecto (670-850 °/s), desenfoque de movimiento u ojo de pez forzados.** Con teclado digital son inmanejables. Como opción, sí; por defecto, no.
- **Cifras de formación sin fuente en la interfaz** (las "20-25 h del UALC"). Mientras no haya una fuente comprobable, no se muestran.