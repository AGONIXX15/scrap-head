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

Disparo: `game/audio/sfx/shoot.wav`, creado por el equipo (Leonardo Rios).

Resto de efectos de sonido (CC0, freesound.org), en `game/shared/audio/sfx/`:

- `enemy_hit`: https://freesound.org/people/qubodup/sounds/151624/ por qubodup
- `kill`: https://freesound.org/people/timgormly/sounds/162792/ por timgormly
- `explosion`: https://freesound.org/people/qubodup/sounds/171971/ por qubodup
- `player_death`: https://freesound.org/people/Jofae/sounds/368591/ por Jofae
- `pickup`: https://freesound.org/people/LilMati/sounds/402767/ por LilMati
- `equip`: https://freesound.org/people/SomeGuy22/sounds/431329/ por SomeGuy22
- `shield_block`: https://freesound.org/people/colorsCrimsonTears/sounds/641895/ por colorsCrimsonTears
- `player_hurt`: https://freesound.org/people/Breviceps/sounds/450616/ por Breviceps
- `ricochet`: https://freesound.org/people/morganpurkis/sounds/392975/ por morganpurkis
- `bolt`: https://freesound.org/people/michael_grinnell/sounds/512471/ por michael_grinnell
- `saw_loop`: https://freesound.org/people/sandizzy/sounds/25389/ por sandizzy
- `mine_place`: https://freesound.org/people/marsllzent/sounds/421950/ por marsllzent
- `charge`: https://freesound.org/people/SamsterBirdies/sounds/483883/ por SamsterBirdies
- `beep`: https://freesound.org/people/jeckkech/sounds/391650/ por jeckkech
- `laser`: https://freesound.org/people/BMacZero/sounds/164102/ por BMacZero
- `rivet_shot`: https://freesound.org/people/tec_studio/sounds/362329/ por tec_studio
- `slam`: https://freesound.org/people/magnuswaker/sounds/614063/ por magnuswaker
- `spawn`: https://freesound.org/people/suntemple/sounds/253173/ por suntemple
- `wave_start`: https://freesound.org/people/egomassive/sounds/536773/ por egomassive
- `wave_clear`: https://freesound.org/people/suntemple/sounds/253177/ por suntemple
- `ui_click`: https://freesound.org/people/suntemple/sounds/253168/ por suntemple
- `defeat`: https://freesound.org/people/Rocotilos/sounds/339837/ por Rocotilos
