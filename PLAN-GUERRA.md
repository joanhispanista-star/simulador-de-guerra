# Plan: de simulador a juego de GUERRA DE DRONES · 15-ago-2026

> **ACTUALIZACIÓN (mismo día):** Joan dijo "completa todo hasta D3" y las
> cuatro fases quedaron construidas y verificadas en esta sesión. Lo único
> pendiente: aplicar `guerra.sql` en Supabase (paso de Joan, 2 minutos).
> Lo que sigue abajo es el plan original, que sirve de mapa de lo hecho —
> con una diferencia: D3 v1 salió sin cuentas (partes anónimos acotados a
> 3 puntos), y las cuentas/ranking quedan como la siguiente frontera.

Lo que pidió Joan, en sus palabras: multijugador, guerra de máquinas de un país
con otro para simular invasiones, campo de juego más grande para drones de
largo alcance, y que el juego "sea de eso, de drones".

Este documento parte eso en fases con tiempos honestos. **Nada de aquí se
construye sin el visto bueno de Joan fase por fase.**

## Lo que YA quedó hecho (15-ago)

- Batería del dron: **20 minutos** (eran 55 segundos).
- Misiones el doble/triple de largas: ciudades con 24 enemigos (antes 8),
  montañas al doble.
- **Perros robot con ametralladora en TU bando**: dos opciones nuevas en el
  garaje (Perros robot ×2, Jauría ×4 élite). Escoltan por tierra, disparan en
  ráfagas de tres, mismo cerebro táctico que el resto.

## Fase D1 · El campo grande (drones de largo alcance)

**Qué:** hoy el mundo mide 2,4 × 2,4 km fijos. Para un dron de largo alcance
eso se cruza en un minuto. Meta: mapas de 5–10 km.

**La trampa técnica que lo hace no-trivial:** la escala de las máquinas (`M`)
está atada a la del mundo (`MPU`). Si se agranda `spanM` sin desacoplarlas,
los tanques salen del tamaño de una casa. Además 5 km al zoom actual son 4×
las teselas (memoria en móvil) y 4× el área de Overpass.

**Cómo:** desacoplar escala de máquina y escala de mundo; nivel de detalle por
distancia para la ciudad; zoom satelital adaptativo (fino cerca del centro).

**Tiempo: 2–3 sesiones.** Riesgo medio. Es el prerequisito del resto.

## Fase D2 · Duelo 1v1 (la semilla del multijugador)

**El descubrimiento que lo abarata:** el juego YA tiene canal en tiempo real —
el mando-celular funciona por Supabase Realtime con códigos de 4 dígitos. El
duelo usa la misma tubería: dos jugadores, un código, el mismo mapa real,
posiciones a 15–20 Hz.

**Qué se juega:** dron contra dron sobre una ciudad real. Derribo = punto.
Primera versión sin servidor árbitro: el que dispara reporta el impacto
(entre amigos alcanza; para ranking ya no, y eso es D3).

**Límites del gratis de Supabase:** 200 conexiones simultáneas — para amigos
y primeros usuarios, sobra.

**Tiempo: 3–4 sesiones** hasta un duelo jugable con marcador. Riesgo medio:
lo difícil no es la red, es que el rival se vea SUAVE con 20 mensajes/s
(interpolación), y ya sabemos dónde duele eso.

## Fase D3 · La guerra de países (el juego grande)

**Qué:** un mapa persistente por territorios; las batallas (duelos D2) mueven
la línea del frente. Esto ya no es un archivo HTML: es un backend con estado
(Supabase Postgres: guerras, territorios, batallas — **toda tabla con RLS**),
cuentas, y alguien que modere.

**La conversación incómoda que hay que tener antes:** "invasiones" entre
países REALES con nombre y bandera es carnada de toxicidad (imagínate el chat
de una guerra Colombia–Venezuela). Mi recomendación fuerte: **facciones
ficticias** (Coalición AZUL vs Pacto ROJO) sobre ciudades reales — la misma
fantasía, sin el veneno. Decisión de Joan.

**Tiempo: 4–6 semanas** de sesiones regulares, DESPUÉS de D1+D2. Y convierte
el juego de juguete en servicio: pensarlo dos veces es parte del plan.

## Fase D0 · El pivote a drones (transversal, barato)

"Que el juego sea de eso, de drones." Cambios chicos de identidad:
- Arrancar las misiones EN el dron (el tanque pasa a ser la base móvil).
- El garaje abre en la pestaña de drones.
- La portada y el título ya lo dicen: Drones de Combate.

**Tiempo: media sesión.** Se puede hacer en cualquier momento.

## Orden propuesto

**D0 → D1 → D2 → (decisión de facciones) → D3.**
Cada fase termina jugable y publicada; ninguna deja el juego roto a mitad.
