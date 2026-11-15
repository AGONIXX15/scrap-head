# Cómo crear una pieza nueva

Copia el patrón de las piezas de ejemplo en `game/parts/data/`.

1. **Arte**: dibuja la capa en pixel art (Aseprite, Piskel o similar) como tira horizontal de frames de 32x32, con el mismo origen que las demás capas (usa las de `game/player/sprites/` y `game/parts/sprites/` como plantilla). Frames: piernas 10 (0-3 idle, 4-9 caminar); cabeza, espalda y brazo, los que quieras en bucle (el brazo tiene el hombro en el centro y apunta a la derecha, boca en x=29). Guárdala en `game/parts/sprites/part_<nombre>.png`.
2. **Recurso**: duplica un `.tres` de `game/parts/data/` y cambia `name`, `slot` (head, arm, legs, back), `texture`, `rarity` (chatarra, reparada, legendaria; las legendarias solo salen desde la oleada 3) y `description` (una línea corta y con gracia).
3. **Stats**: en `stats` pon solo lo que cambia; se suma a la base del jugador. Claves: `speed`, `max_hp`, `damage`, `fire_rate` (negativo = dispara más rápido), `range`, `pierce`, `auto_aim` (1 para activar).
4. **Efecto especial** (opcional): crea una escena (ver `game/parts/drone/drone.tscn`) y asígnala al campo `scene` de la pieza. Se instancia como hijo del jugador al equipar y se elimina al reemplazar la pieza. Puede usar `player.nearest_enemy()` y `player.spawn_bullet()`.
5. **Taller**: no hay que registrar nada; las piezas de `game/parts/data/` entran solas al pool del taller (se ofrecen tras cada oleada, pesadas por rareza y oleada, sin repetir la que ya llevas).

## Efectos procedurales (generador)

Definidos en `PartGenerator.EFFECTS`; todos se apilan con las copias equipadas. Lógica de piernas, espalda y radar en `game/parts/effects/part_fx.gd` (solo procesa si hay alguno equipado); los de bala en `bullet.gd`.

- **Cabeza**: Ciclópeo (15% de crítico x2 por copia, tope 60%), Telescópico (+alcance y balas más rápidas), Marcador (enemigo marcado 3 s, +1 daño por copia), Francotirador (+1 daño por copia si la bala viajó más de 250 px), Berserker (con la mitad de vida o menos, cadencia x(1+0,35 por copia)), Tasador (+1 chatarra por recogida y copia), Rastreador/radar (puntos rojos en el borde hacia enemigos fuera de pantalla).
- **Piernas**: Propulsor (acción `dash`, Shift: dash invulnerable; menos espera por copia), Incendiario (fuego a tu paso), Aceitoso (aceite que ralentiza), Minero (mina cada 3 s, menos por copia), Pisoteador (onda cada 4 s con daño y empuje), Patinador (+velocidad), Antideslizante (ignora aceite).
- **Espalda**: Aserrador (una sierra orbital por copia), Blindado (bloquea un golpe, recarga 8 s menos por copia), Espinoso (al recibir daño hiere a cercanos, daño = copias), Reactivo (+cadencia), Magnético (+radio de atracción de chatarra), Regenerador (+1 vida cada 10 s, menos por copia), Vampírico (+1 vida cada pocas muertes), Acolchado/mochila (+1 vida máxima), Orbital (dron).
