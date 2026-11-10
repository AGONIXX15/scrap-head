# Scrap Head

Arena survival 2D top-down con robots, al estilo Brotato.

## Pitch

En un planeta abandonado, un pequeño robot hecho de piezas recicladas sobrevive entre máquinas defectuosas. Cada enemigo derrotado suelta piezas que puedes montarte encima: cambian tus estadísticas y también tu aspecto. Sobrevive a 5 oleadas y derrota a la máquina gigante.

## Controles

| Acción | Teclas |
|---|---|
| Moverse | WASD o flechas |
| Apuntar | Mouse |
| Disparar | Clic izquierdo (mantener) |

## Abrir y ejecutar

1. Instalar Godot 4.7 (renderer Compatibility).
2. Abrir Godot, "Importar" y seleccionar `project.godot`.
3. Ejecutar con F5, o desde terminal: `godot --path .`

## Estructura

```
assets/sprites/   sprites PNG generados
scenes/           escenas (.tscn)
scripts/          scripts GDScript
tools/            scripts para generar arte y audio
docs/             GDD y backlog
```

Regenerar sprites: `python3 tools/gen_sprites.py` (requiere Pillow).

## Documentación

- [GDD](docs/GDD.md)
- [Backlog](docs/backlog.md)

## Créditos

Arte y audio propios, generados con scripts en `tools/`.
