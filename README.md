# Scrap Head

Arena survival 2D top-down con robots, al estilo Brotato.

## Pitch

En un planeta abandonado, un pequeño robot hecho de piezas recicladas sobrevive entre máquinas defectuosas. Cada enemigo derrotado suelta tornillos y, tras cada oleada, el taller te deja elegir una pieza para montarte encima: cambian tus estadísticas y también tu aspecto. Sobrevive a 5 oleadas y derrota a la máquina gigante.

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
game/
  player/        robot del jugador (escena, script y sprites por capas)
  weapons/       proyectiles del jugador
  enemies/       un módulo por enemigo (oxidado, chispa, remachadora, prensa) y su base común
  parts/         sistema de piezas: recurso Part, datos (.tres), sprites y dron escolta
  level/         arena, oleadas y aviso de aparición
  intro/         cinemática inicial con su arte y audio
  fx/            explosiones, impactos y polvo
  autoload/      Juice (sacudida, hitstop, números de daño)
  shared/        sprites compartidos
docs/            GDD, backlog y guía de piezas
```

## Documentación

- [GDD](docs/GDD.md)
- [Backlog](docs/backlog.md)
- [Cómo crear una pieza](docs/piezas.md)

## Créditos

Arte y audio propios, salvo la música (CC0, [freesound.org](https://freesound.org)):

- Combate: [Synth Metal Rock Loop](https://freesound.org/people/furbyguy/sounds/361424/) por furbyguy.
- Taller: [GreyMorning](https://freesound.org/people/edemson86/sounds/324264/) por edemson86.
- Menú: [cyberpunk_metal](https://freesound.org/people/Bertsz/sounds/672783/) por Bertsz.
