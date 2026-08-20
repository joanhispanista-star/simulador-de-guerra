-- ⚔️ GUERRA POR TERRITORIOS · Drones de Combate
-- ====================================================================
-- CÓMO SE APLICA (paso de Joan, una vez, ~2 minutos):
--   Supabase → el proyecto de siempre → SQL Editor → pegar TODO este
--   archivo → Run. La pestaña "Guerra" del juego se enciende sola.
--
-- El diseño en una frase: el cliente (clave anónima, pública) solo puede
-- LEER territorios y PRESENTAR partes de guerra chicos (1–3 puntos); el
-- marcador lo lleva un TRIGGER en el servidor. El cliente no puede
-- escribir el marcador ni cambiar de dueño un territorio — eso lo decide
-- la base. Es la misma regla de la casa que en Plaza: sin política de
-- escritura, el cliente no escribe.
--
-- Honestidad sobre el límite de esta versión: cualquiera puede presentar
-- partes sin ganar de verdad (no hay cuentas todavía). Para una guerra
-- entre amigos alcanza; para ranking público harán falta cuentas, y eso
-- es otra fase. El daño posible está acotado: 3 puntos por parte.
-- ====================================================================

-- Idempotente: se puede correr dos veces sin romper nada.

create table if not exists guerra_territorios (
  id         text primary key,               -- 'lat,lon' con 2 decimales: lo genera el juego
  nombre     text not null,
  lat        double precision not null,
  lon        double precision not null,
  dueno      text not null default 'nadie' check (dueno in ('nadie','azul','rojo')),
  puntos_azul integer not null default 0,
  puntos_rojo integer not null default 0,
  actualizado timestamptz not null default now()
);
alter table guerra_territorios enable row level security;

drop policy if exists "territorios: leer todos" on guerra_territorios;
create policy "territorios: leer todos"
  on guerra_territorios for select using (true);
-- SIN política de insert/update/delete: el cliente no toca el marcador.

create table if not exists guerra_partes (
  id         bigint generated always as identity primary key,
  territorio text not null,
  faccion    text not null check (faccion in ('azul','rojo')),
  puntos     integer not null check (puntos between 1 and 3),
  creado     timestamptz not null default now()
);
-- ⚠ SIN llave foránea a propósito. Se puede pelear en CUALQUIER coordenada del
-- planeta ("tu zona") y en los 9 mapas de montaña del catálogo, no solo en las
-- 23 ciudades sembradas. Con la foránea, esos partes los rechazaba la base y
-- se perdían en silencio: el jugador ganaba y no pasaba nada, sin explicación.
-- Ahora el territorio se crea solo la primera vez que alguien pelea ahí
-- (lo hace el trigger de abajo), que es como se debe abrir un frente nuevo.
alter table guerra_partes drop constraint if exists guerra_partes_territorio_fkey;
alter table guerra_partes enable row level security;

drop policy if exists "partes: presentar" on guerra_partes;
create policy "partes: presentar"
  on guerra_partes for insert with check (true);
drop policy if exists "partes: leer" on guerra_partes;
create policy "partes: leer"
  on guerra_partes for select using (true);

-- El árbitro: cada parte suma en su territorio, y el dueño es quien va
-- ganando por 5 o más (la histéresis evita que la ciudad cambie de manos
-- con cada partida — conquistar debe costar más que molestar).
create or replace function guerra_sumar() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- Frente nuevo: si nadie ha peleado nunca aquí, el territorio se abre solo.
  -- El nombre provisional son sus coordenadas; se puede renombrar después.
  insert into guerra_territorios (id, nombre, lat, lon)
  values (new.territorio,
          'Frente ' || new.territorio,
          coalesce(split_part(new.territorio, ',', 1)::double precision, 0),
          coalesce(split_part(new.territorio, ',', 2)::double precision, 0))
  on conflict (id) do nothing;

  update guerra_territorios t set
    puntos_azul = t.puntos_azul + case when new.faccion='azul' then new.puntos else 0 end,
    puntos_rojo = t.puntos_rojo + case when new.faccion='rojo' then new.puntos else 0 end,
    actualizado = now(),
    dueno = case
      when t.puntos_azul + case when new.faccion='azul' then new.puntos else 0 end
         >= t.puntos_rojo + case when new.faccion='rojo' then new.puntos else 0 end + 5 then 'azul'
      when t.puntos_rojo + case when new.faccion='rojo' then new.puntos else 0 end
         >= t.puntos_azul + case when new.faccion='azul' then new.puntos else 0 end + 5 then 'rojo'
      else t.dueno end
  where t.id = new.territorio;
  return new;
end $$;

drop trigger if exists guerra_sumar_tg on guerra_partes;
create trigger guerra_sumar_tg after insert on guerra_partes
  for each row execute function guerra_sumar();

-- Los territorios: las mismas ciudades del catálogo del juego.
insert into guerra_territorios (id, nombre, lat, lon) values
  ('4.60,-74.08', 'Bogotá · Plaza de Bolívar', 4.60, -74.08),
  ('4.65,-74.06', 'Bogotá · Chapinero', 4.65, -74.06),
  ('6.21,-75.57', 'Medellín · El Poblado', 6.21, -75.57),
  ('3.45,-76.53', 'Cali · Centro', 3.45, -76.53),
  ('10.42,-75.55', 'Cartagena · Ciudad amurallada', 10.42, -75.55),
  ('10.97,-74.78', 'Barranquilla · Centro', 10.97, -74.78),
  ('7.12,-73.12', 'Bucaramanga · Centro', 7.12, -73.12),
  ('40.76,-73.98', 'Nueva York · Manhattan', 40.76, -73.98),
  ('19.43,-99.13', 'Ciudad de México · Zócalo', 19.43, -99.13),
  ('-34.60,-58.38', 'Buenos Aires · Obelisco', -34.60, -58.38),
  ('-23.56,-46.66', 'São Paulo · Paulista', -23.56, -46.66),
  ('-12.05,-77.03', 'Lima · Centro', -12.05, -77.03),
  ('-33.44,-70.65', 'Santiago · Centro', -33.44, -70.65),
  ('-0.22,-78.51', 'Quito · Centro', -0.22, -78.51),
  ('8.98,-79.52', 'Panamá · Centro', 8.98, -79.52),
  ('48.86,2.29', 'París · Torre Eiffel', 48.86, 2.29),
  ('40.42,-3.70', 'Madrid · Sol', 40.42, -3.70),
  ('41.39,2.17', 'Barcelona · Eixample', 41.39, 2.17),
  ('51.50,-0.13', 'Londres · Westminster', 51.50, -0.13),
  ('41.89,12.49', 'Roma · Coliseo', 41.89, 12.49),
  ('35.66,139.70', 'Tokio · Shibuya', 35.66, 139.70),
  ('25.20,55.27', 'Dubái · Burj Khalifa', 25.20, 55.27),
  ('30.05,31.24', 'El Cairo · Centro', 30.05, 31.24),
  -- y los 9 mapas de montaña del catálogo, que también se disputan
  ('6.79,-72.97', 'Cañón del Chicamocha', 6.79, -72.97),
  ('4.89,-75.32', 'Nevado del Ruiz', 4.89, -75.32),
  ('10.83,-73.72', 'Sierra Nevada de Santa Marta', 10.83, -73.72),
  ('36.15,-112.05', 'Gran Cañón', 36.15, -112.05),
  ('35.36,138.73', 'Monte Fuji', 35.36, 138.73),
  ('27.99,86.92', 'Everest', 27.99, 86.92),
  ('-0.68,-78.44', 'Volcán Cotopaxi', -0.68, -78.44),
  ('-50.94,-73.03', 'Torres del Paine', -50.94, -73.03),
  ('-32.65,-70.01', 'Aconcagua', -32.65, -70.01)
on conflict (id) do nothing;
