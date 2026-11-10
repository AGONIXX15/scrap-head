# Cómo crear una pieza nueva

Copia el patrón de las piezas de ejemplo en `parts/`.

1. **Arte** (`tools/gen_sprites.py`): añade una función que dibuje la capa con frames de 32x32, mismo origen que el resto, y regístrala en `sprites` con nombre `part_<nombre>`. Frames: piernas 10 (0-3 idle, 4-9 caminar); cabeza, espalda y brazo, los que quieras en bucle (el brazo tiene el hombro en el centro y apunta a la derecha, boca en x=29). Regenera con `PREVIEW_DIR=<carpeta> python3 tools/gen_sprites.py` y revisa la vista previa.
2. **Recurso**: duplica un `.tres` de `parts/` y cambia `name`, `slot` (head, arm, legs, back) y `texture`.
3. **Stats**: en `stats` pon solo lo que cambia; se suma a la base del jugador. Claves: `speed`, `max_hp`, `damage`, `fire_rate` (negativo = dispara más rápido), `range`, `pierce`, `auto_aim` (1 para activar).
4. **Efecto especial** (opcional): crea una escena (ver `scenes/drone.tscn`) y asígnala al campo `scene` de la pieza. Se instancia como hijo del jugador al equipar y se elimina al reemplazar la pieza. Puede usar `player.nearest_enemy()` y `player.spawn_bullet()`.
5. **Drop**: añade el `.tres` a la lista `PARTS` de `scripts/enemy.gd`.
