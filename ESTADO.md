# Estado de Drones de Combate · 22 de agosto de 2026

**Vive en `Desktop\drones`** (antes `Desktop\maquinas`; se renombró el 15-ago
porque ya no comparte carpeta con ningún otro juego).

## El juego cambió de naturaleza (15-ago): ahora ES de drones, y de guerra

Joan pidió "completa todo hasta D3" y las cuatro fases del PLAN-GUERRA.md
quedaron construidas EN UN DÍA:

| Fase | Qué | Estado |
|---|---|---|
| D0 | Las misiones arrancan EN el dron; el garaje abre por el dron | ✅ verificado |
| D1 | Campo grande: 2,4 / 4,8 / 7,2 km, selector en 🌍 · la escala de las máquinas NO cambia | ✅ verificado a 4,8 km |
| D2 | **Duelo 1v1 por internet**: sala con código (como el mando), primero a 3 derribos | ✅ un duelo REAL de 3–0 entre dos pestañas, por el Supabase de verdad |
| D3 | **Guerra por territorios**: AZUL vs ROJO, 23 ciudades, pestaña ⚔️ Guerra | ✅ cliente listo; **falta que Joan aplique `guerra.sql`** (2 min, abajo) |

**El único paso pendiente de D3 es de Joan:** Supabase → SQL Editor → pegar
`guerra.sql` → Run. Hasta entonces la pestaña Guerra espera con un aviso
honesto; el juego no se rompe. El SQL es idempotente y sigue la regla de la
casa: RLS en todo, el cliente NO puede escribir el marcador (lo lleva un
trigger), y conquistar exige ventaja de 5 (la histéresis evita que una ciudad
cambie de manos con cada partida). Facciones FICTICIAS a propósito.

Cómo se probó el duelo sin dos computadores: dos pestañas del mismo navegador,
`DRONES.dueloCrear()` en una, `DRONES.dueloUnir(código)` en la otra, y
`DRONES.dueloEstado()` en ambas. La trampa de esa prueba: la pestaña oculta no
corre su bucle, así que su respawn no avanza hasta dispararle `simN()` — en
juego real no pasa. Y `rumbo()` es BRÚJULA: yaw=(180−g)°; para apuntar a un
punto: `g = 180 − atan2(dx,dz)·180/π` (costó 13 tiros errados descubrirlo).

---

# Estado anterior · 6 de agosto de 2026

Documento para retomar sin releer el historial. Lo que está hecho, lo que falta,
y las trampas que ya costaron tiempo una vez.

**En línea:** https://joanhispanista-star.github.io/simulador-de-guerra/
**Publicar:** `git push` desde `Desktop\drones`. Nada más.

---

## La revisión adversaria de D0–D3 (15-ago) — 33 defectos, 16 arreglados

Seis lentes en paralelo revisaron el código nuevo y cada hallazgo pasó por un
verificador que intentaba REFUTARLO leyendo el código. Sobrevivieron 33. Los
que introdujeron D0–D3 quedaron arreglados; el resto está listado abajo.

**Del duelo (todos eran míos):**
- `duelo.active` se encendía ANTES de construir el mundo. Si fallaba la
  descarga de teselas, el jugador volvía al menú con el duelo encendido: la
  misión siguiente lo teletransportaba a una esquina, el marcador se pintaba
  encima del objetivo y sus victorias dejaban de sumar en la guerra el resto
  de la sesión. Ahora `startRealMission` DEVUELVE si logró arrancar.
- Un segundo `hola` reiniciaba la partida a 0–0 y recargaba el mundo. Pasaba
  con solo caerse el wifi un segundo (supabase-js reemite `SUBSCRIBED` al
  reconectar), con doble clic, o si un tercero tecleaba los mismos 4 dígitos.
- Los mensajes de red actuaban con la simulación parada: te derribaban DENTRO
  del menú de pausa y el reloj de reaparición no corría. Ahora en duelo **no
  hay pausa** (el rival sigue ahí) y `pum`/`tiro` exigen `playing && !paused`.
- `dueloFin` no cerraba nada: el perdedor reaparecía 3 s después de perder.
  Ahora hay pantalla de resultado propia (⚔️ DUELO GANADO / PERDIDO).
- `dueloColocar` movía tu posición pero no la MALLA del blindado ni el puesto
  de mando: el chasis se quedaba dibujado en el centro del mapa y nacías con
  el enlace medido desde el sitio equivocado.
- Reiniciar desde la pausa no cerraba la sala y dejaba el juego congelado
  durante la descarga (`paused` seguía en true).

**Del campo grande:**
- `SIG_RANGE` estaba clavado en 280 u: en un campo de 7,2 km el enlace moría a
  1,3 km y el 90 % del mapa era inalcanzable — y en duelo los dos nacían fuera
  de alcance, sin poder disparar. Ahora escala con el campo (medido: a 1,6 km
  quedan 4 barras donde antes no había ninguna).
- El despliegue entero (enemigos, chatarra, extracción, puntos de recon) usaba
  radios absolutos: mapa gigante y toda la guerra apiñada en el kilómetro del
  centro. Ahora escalan con `escCampo()`, que vale exactamente 1 a 2,4 km.
- La rejilla de colisiones se cacheaba mirando solo CUÁNTOS obstáculos hay: al
  cambiar de tamaño de campo seguía usando la del mundo viejo y las colisiones
  desaparecían en media ciudad. Se invalida en `clearTerrain`.

**Del pivote a drones** (arrancar en el aire dejó al chasis aparcado, y medio
juego seguía mirándolo a él):
- El escuadrón aliado escoltaba al tanque vacío mientras tú volabas lejos.
- La zona de extracción solo contaba si llegaba el tanque.
- El radar se centraba en el tanque: volabas a un kilómetro y no salías en tu
  propio minimapa. Ahora los tres usan `activeUnitPos()`.

**De la guerra:** los partes de los 9 mapas de montaña y de "tu zona" los
rechazaba la llave foránea y **se perdían en silencio**. Se quitó la foránea y
el trigger ABRE el territorio la primera vez que alguien pelea ahí.

### Lo que queda sin arreglar (de otras sesiones, no de D0–D3)

Verificados y reales, anotados para quien siga: el UGV arranca flotando 2,6 m
(el `+0.5` son unidades, no metros); volver al tanque con F deja el dron
activo y congelado en el aire recargando batería; la mancha térmica sobrevive
entre misiones; el techo del dron cuelga de la cumbre del mapa en vez del
suelo que tiene debajo; y `computeGunnery` barre 420 u fijas.

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
| **Vuelo del dron** | inercia de giro, banqueo, horizonte que se inclina, FOV con la marcha, respiración en vuelo (14-ago) |
| **Batería** | 20 minutos de vuelo (eran 55 s) — decisión de Joan, 15-ago |
| **Misiones** | ciudades ×3 (24 enemigos con torretas y jammers), montañas ×2 |
| **Perros robot aliados** | garaje → Compañeros: ×2 veterano o Jauría ×4 élite; escoltan por tierra, ráfagas de 3 |
| **Plan de guerra** | `PLAN-GUERRA.md`: campo grande, duelo 1v1, guerra por territorios — fases con tiempos |

## El vuelo del dron: qué se pulió y cómo se prueba

Cinco cosas, todas de sensación — la física de FÁCIL/ACRO no cambió:

1. **Inercia de giro.** El yaw arrancaba y paraba EN SECO en el mismo cuadro;
   ahora la velocidad de giro persigue a la palanca (~⅓ s de rampa).
2. **Banqueo.** Girar inclina el aparato hacia el giro. Antes rotaba tieso,
   como una peonza.
3. **El horizonte se inclina** (FPV): la cámara toma el 60 % del roll del
   aparato. Un horizonte perfectamente recto en un giro se lee como "cámara
   en un raíl".
4. **La velocidad se ve:** el FOV se abre de 60° a 68° con la marcha.
5. **Respiración de vuelo:** meceo de centímetros y cabeceo de décimas de
   grado, más con viento. SOLO en el mesh — `drone.pos`, la física y el
   kamikaze no se enteran.

Probarlo sin teclado: `DRONES.palanca({yaw:1, pitch:0.6})` + `DRONES.simN(50)`
y mirar `DRONES.vuelo()` (yawVel, roll, fov, camRoll). `palanca(null)` devuelve
los controles. Verificado: rampa 1,1→2,6 rad/s en ⅓ s; girando a la derecha
roll +0,40 y camRoll −0,23; a fondo vel 5,75 u/s y FOV 68,0.

**La batería quedó en 20 minutos** (Joan, 15-ago) y las misiones se alargaron
a juego: ciudades con 24 enemigos (tanques, torretas, drones, perros y
jammers), montañas al doble. El redespliegue sigue sin recargar.

**Los perros robot aliados** reutilizan el cuerpo, la marcha y la ráfaga del
enemigo (en azul): dos perros que caminan distinto se notaría más que dos del
mismo color. El anillo de escolta va en UNIDADES (1,9 u ≈ 10 m) — el primer
intento lo puso a 7 creyendo metros y escoltaban a 36 m, invisibles a escala
real. `DRONES.pantalla(x,y,z)` dice en qué píxel cae un punto del mundo: es lo
que permitió fotografiarlos sin adivinar el encuadre.

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


## 18-ago: el reescalado estaba a medias, y se notaba en veinte sitios

Joan reportó tres cosas: **"cosas negras volando"**, **"el vuelo del dron no es
tan realista"** y **"cuando activo la mirada es muy sensible y no apunta bien o
se mueve mucho"**. Las tres resultaron ser **la misma causa**.

Cuando se arreglaron las máquinas gigantes (1 unidad = 5,22 m), se reescalaron
**las mallas del tanque, el dron y el perro — y nada más**. Todo lo demás siguió
suponiendo que una unidad era un metro. Medido en vivo, esto es lo que quedaba:

| Cosa | Estaba en | Es de verdad |
|---|---|---|
| Escombros de explosión | 7,8 m y casi negros | 1,3 m |
| Impulso de la onda sobre esos escombros | 240 m/s, subían 250 m | 19 m/s, 13 m |
| Giro de los escombros | **17.400 rad/s** (46 vueltas por CUADRO) | 11 rad/s |
| Humo de explosión | 67 m, gris casi negro | 9,6 m, gris cálido |
| Gravedad del mundo físico | 22 u/s² = **11,7 g** | 9,81·M |
| Colisionador del UGV | 24 m de largo | 2,4 m |
| Bola de fuego de un obús de 90 mm | 161 m de diámetro | 11 m |
| Radio letal de un barril | 57 m | 8 m |
| Huella de la suspensión | 22 × 15 m | 2,4 × 1,24 m |
| Ojo del sensor de la IA | mástil de 10,4 m | 1,15 m |
| Velocímetro del HUD | dividía por 5,22 (108 km/h → "21") | correcto |
| Lluvia | gotas de 3,1 m a 313 m/s | 16 cm a 9 m/s |
| Sombra al atardecer | despegada hasta 17 m | 1 m |
| Zancada del perro | 83% deslizamiento | sin deslizar |

**La regla que salió de aquí, y que está escrita al principio del archivo:**
todo lo que tenga un tamaño físico se escribe **en metros y se multiplica por
M**. Lo único que va en unidades crudas son las coordenadas del mundo.

### El vuelo

No era falta de efectos: era que **la inclinación no causaba nada**. El dron
frenaba a 3,9 g estando plano (0,2° de inclinación), y un cuadricóptero no tiene
frenos — lo único que puede hacer es inclinar el disco de los rotores. Ahora
`θ = atan(a/g)` y la aceleración está topada a `g·tan(35°)`, así que postura y
movimiento no pueden volver a contradecirse.

| | Antes | Ahora | Un dron real |
|---|---|---|---|
| Aceleración | 16,8 g | 0,68 g | 0,5–0,8 g |
| Frena de 108 km/h en | 0,8 s y 5 m | 5,8 s y 66 m | 4–6 s, 45–75 m |
| Inclinación al frenar | 0,2° | 35° | 25–35° |

La cámara "FPV" además **no era FPV**: estaba 3,6 m detrás de un aparato de
0,9 m, con un brazo elástico que filtraba toda la vibración. Ahora va en el
morro (8 cm), sin suavizado, con gran angular de 95° y vibración de motores a
47–61 Hz. En ACRO el cabeceo del aparato entra en la mirada; en fácil manda el
gimbal, para no endurecer el modo fácil que Joan pidió.

### La mirada

| Giras la cabeza | Antes | Ahora |
|---|---|---|
| 10° | 219 °/s | 3,4 °/s |
| 20° | 544 °/s | 17,9 °/s |
| 45° | 1497 °/s | 60 °/s (tope) |

Y **la deriva con la cabeza quieta pasó de 4,6 °/s a cero**. Cuatro causas, no
una: la zona muerta (1,15°) era menor que el ruido del sensor; la pose de cabeza
entraba sin filtrar; al yaw en radianes se le sumaba un número sin unidades del
iris que ganaba a la cabeza (y por el reflejo vestíbulo-ocular RESTABA, así que
la torreta arrancaba al revés); y el centrado tomaba **una** muestra a ciegas a
los 1,6 s sin comprobar siquiera que hubiera un rostro. Ahora: filtro "un euro",
zona muerta de 3° con histéresis, curva cuadrática con tope, los ojos fuera del
integrador de giro, centrado por mediana de 20 muestras y recentrado automático.
Y el parpadeo ya no pega el tirón vertical (el `||0.01` solo saltaba con el cero
exacto; al parpadear el divisor valía 0,0015).

### Herramientas de medida nuevas (con `?dbg`)

- `DRONES.aire()` — qué hay volando y **de qué tamaño en metros**. Es la que
  habría cazado esto en su día.
- `DRONES.curvaMirada()` — la tabla entera de grados de cabeza → °/s de torreta.
- `DRONES.tiro(n, metros)` — cuántos disparos aciertan y dónde mueren los que no.
- `DRONES.medidas()` **ya no miente**: medía la caja del sprite térmico y decía
  "UGV de 4,00 × 4,00 × 4,04 m" de un UGV de 2,4 m. Ahora mide solo mallas.

### Los tres cabos sueltos, ya cerrados

**Las escalas normalizaban una medida que no era la suya.** `ESC_UGV` decía "el
casco mide 4,2 u" cuando el modelo entero mide **7,07**, y `ESC_DRON` decía
"1,9 u de envergadura" cuando el dron mide **3,29**. Por eso las dos máquinas
salían 1,7 veces más grandes de lo que su propio comentario prometía. Los
denominadores ahora salen de medir con `DRONES.medidas()`, no de suponer:

| | Antes | Ahora |
|---|---|---|
| UGV (ancho × alto × largo) | 2,48 × 2,36 × 4,04 m | **1,84 × 1,75 × 3,00 m** |
| Dron | 1,56 × 0,51 × 1,55 m | **1,00 × 0,33 × 1,00 m** |
| Torreta (alto) | 1,46 m | **2,50 m**, como decía el comentario |

Con ellas se ajustaron el colisionador físico del UGV, la huella de la
suspensión y la posición de la cámara del morro (20 cm, no 42).

**Y `DRONES.tiro()` ya adelanta el tiro** (punto de intercepción por iteración
del tiempo de vuelo) y dispara siempre al MISMO blanco, dándole la vida entre
disparos. Con eso da la cifra que importa, que no es el porcentaje de acierto
sino **si el motor registra los tiros que sí pasan por encima del blanco**:

    50 m … 1500 m → pasaron dentro del radio: 19 · registrados: 19 · EXACTO

Tres cosas que costaron una hora de diagnóstico falso y conviene no repetir:
- **El contador medía la distancia a un cadáver.** El blanco moría al tercer
  tiro y los siguientes salían "a 66 metros"; parecía un 30% de acierto.
- **La propia herramienta de puntería tenía el signo del cabeceo invertido** y
  medía desde `player.pos` con un "+1 −2" en unidades. Los tiros caían nueve
  metros largos y la culpa parecía del motor.
- **La torreta seguía girando al disparar.** Con 0,75 s de espera, un blanco a
  la espalda daba la escalera 246 → 238 → 224 → … → 1 m. Ahora espera 3 s.


## 21-ago: el garaje pasa a ingeniería, y el juego explica

**El vehículo ya no son puntos: son kilos y kilovatios.** Cada pieza tiene masa
en kg, potencia en kW y energía en kWh o litros, y la punta, el arranque, la
autonomía y a qué distancia te oyen SALEN de ahí en vez de estar escritos a
mano. Las ecuaciones están en `ING` y el cálculo entero en `ficha(l)`, un solo
sitio del que beben el garaje, el HUD técnico y las explicaciones.

    P_rueda = ½·ρ·CdA·v³ + Crr·m·g·v        (punta, resuelta por bisección)
    a = mín( P/(m·v) , μ·g )                (arranque: potencia o agarre)
    autonomía = energía al eje / consumo medio

Lo que sale de montar cosas distintas, medido en el propio juego:

| | masa | punta | 0→X | autonomía | ruido |
|---|---|---|---|---|---|
| Eléctrico ligero | 356 kg | 60 km/h | 1,6 s | 39 min | 58 dB |
| Eléctrico blindado | 1.129 kg | 32 km/h | 2,0 s | 37 min | 62 dB |
| Diésel de patrulla | 866 kg | 30 km/h | 10,7 s | **16 h 7 min** | 78 dB |

Esa tabla ES el juego técnico: el eléctrico corre y no se oye pero dura una
mañana corta; el diésel es lento y ruidoso y dura el día entero. Y si el tren y
la fuente no casan (motor eléctrico con depósito de gasóleo) el vehículo no
anda y se dice por qué.

**Tres formas de explicar**, y una regla que las une: *nunca se inventa un
número*. Todo se lee del estado real o de la ficha.
- **¿POR QUÉ?** (tecla P o botón): explica lo que pasa AHORA, eligiendo el tema
  por urgencia. Pausa a propósito — leer mientras te disparan no es leer.
- **Ficha técnica por pieza** en el garaje: qué es un kWh traducido a *tus*
  minutos con *tu* consumo.
- **Modo técnico** (tecla T): el HUD pasa a instrumentos —
  `POT 0.7/7 kW · MASA 866 kg · GASÓLEO 40 L · RESTAN 967 min · T.MOTOR 90 °C`.

**Y dos modelos de movimiento nuevos**, porque lo que había era el del
cuadricóptero aplicado a cosas que no lo son:
- **Cascos** (lancha y submarino): empuje solo por el eje, y **sin arrancada no
  hay gobierno** — medido, 0 °/s con la máquina parada. Resistencia cuadrática,
  así que la punta sale sola: 72 km/h la lancha y 10,7 el sumergible. Y no
  frenan: 110 m de parada.
- **Ala fija**: el gas da EMPUJE, no velocidad. `dV/dt = (T−D)/m − g·sen γ`.
  Medido: 193 km/h a todo gas, 57 trepando y 165 picando.

### Trampas nuevas
- **El rendimiento se aplica UNA vez.** Multiplicarlo también en el consumo dio
  50 horas de autonomía a un diésel de 40 litros. `kWhEje` ya es energía al eje
  y `kW` es potencia al eje: el consumo NO se vuelve a multiplicar.
- **"0 a 30" no sirve si la punta es 30**: se acerca asintóticamente y sale «no
  llega», que es cierto e inútil. Se mide contra el 90% de su propia punta.


## 22-ago: la Historia documentada, Medio Oriente y el enjambre

**Pestaña 📜 Historia**: diez épocas de 1849 a hoy, con la regla de siempre —
nada inventado, hechos con fecha y sistemas con nombre (Kettering Bug, Queen
Bee, Firebee, Mole Cricket 19, Predator, TB2, Magura, fibra óptica, Telaraña).
Donde especula (el enjambre de Taiwán) dice HIPOTÉTICO en grande. Siete épocas
llevan misión jugable que **equipa sola el aparato de su tiempo** (Vietnam =
recon desarmado; Ucrania = FPV de fibra sobre la Avdíivka real; el enjambre =
ala fija contra 14 aparatos aéreos en Taroko). Verificadas jugando: Vietnam
completa (3 fotos → MISIÓN CUMPLIDA), la Becá con sus 6 baterías, el enjambre
con sus 22.

**Medio Oriente, con la línea de siempre**: geografía real + contexto
DOCUMENTADO + bandos ficticios. Se añadieron las zonas atadas a hitos
históricos de la guerra de drones — **Valle de la Becá** (1982, 259 m de
desnivel medidos) y **Mosul** (2016-17, primera guerra urbana de drones) — y
**Taipéi** (159 m) para el escenario futurista. NO se hizo un escenario de la
guerra actual con sus bandos reales: la regla del proyecto es que la guerra
jugable es ficticia, y la actualidad se cuenta en la Historia con texto.
**Bab el-Mandeb se sondeó y no tiene batimetría** (SIN DATOS): la época del
mar Rojo se cuenta, no se vuela, y la ficha lo dice.

### Trampas nuevas
- `misionFija` en un mapa se salta la campaña y la ficha de la zona: es para
  las misiones de época, donde la época manda.
- Al probar clics de interfaz con el juego corriendo: **cerrar la pantalla de
  resultado antes**, y no romper el bucle de espera en `playing===true` si la
  misión ANTERIOR sigue viva — dos lecturas falsas vinieron de ahí.


## 22-ago (2ª tanda): solo computador, documentales animados, Irán

**Solo computador** (decisión de Joan): puerta a pantalla completa en móvil
(puntero grueso + pantalla angosta + sin puntero fino — NO user agent, que
miente con tablets y portátiles táctiles). El arranque SIGUE debajo de la
puerta porque los botones del mando-celular se conectan durante el arranque:
cortarlo mataría la única función móvil legítima, ser el MANDO. El botón de la
puerta lleva directo al flujo de unirse con código. Verificado emulando móvil.

**🎬 Documentales animados** en las 11 épocas de la Historia. Decisión de
fondo: NO se incrusta metraje real de guerra (muertes reales como contenido de
juego, no; enlaces externos se pudren; el juego abre sin internet). Son
animaciones PROPIAS de sala de mando — siluetas, radares, rótulos con los
hechos documentados — sobre un motor mínimo: escena = lista de beats, beat =
{dur, cap, draw(g,t,W,H)}, y una docena de primitivas (DZ.*) para que añadir
la época del año que viene sea escribir datos. `DRONES.docuPrueba()` dibuja
cada beat a dos tiempos y compara: 26 beats, 22 animan, 4 estáticos a
propósito (tarjetas de precio y cierres).
⚠ Trampa: rAF NO corre en paneles ocultos — el reproductor parece congelado si
se mide así; docuPrueba() existe para eso.

**Irán**: época «2025 · los doce días» — documentada (guerra de junio 2025,
FPV de contrabando desactivando defensas desde dentro, alto el fuego el día
doce), con la nota explícita de que el juego documenta hasta inicios de 2026 y
NO afirma qué pasa hoy. Zona nueva: **Montes Alborz** (917 m de desnivel
medidos, sondeado con DRONES.sonda). Misión de época: fibra óptica contra
defensas y jammers, bandos ficticios como siempre. 22 chinchetas ya.

## Trampas que ya costaron tiempo

- **La rama de este repo es `main`, no `master`.** Otros proyectos de Joan usan
  `master`, así que `git push origin master` falla aquí con "src refspec master
  does not match any" — que suena a repositorio roto y solo es el nombre. Usar
  `git push origin HEAD`.
- **Renombrar la carpeta:** Windows la da por ocupada al primer intento
  (`Device or resource busy`) porque OneDrive la tiene. `Rename-Item` de
  PowerShell sí puede, y si no, reintentar unas veces. El renombrado salió
  barato porque `servidor.js` usa `__dirname` y `JUGAR.bat` usa `%~dp0`: rutas
  relativas. Lo único absoluto estaba en los dos `launch.json` (el del proyecto
  y el de PLAZA, que es desde donde se levanta el servidor).

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
DRONES.palanca({yaw:1})   // palanca virtual del dron; palanca(null) = controles reales
DRONES.vuelo()            // yawVel, roll, fov, camRoll, batería
```

⚠ `sim(4)` es UN paso de 4 segundos, no 4 pasos — para pasos de cuadro usa
`simN(n)`. Medir una rampa con `sim(4)` da la rampa ya convergida y parece
que no existe (pasó).

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
