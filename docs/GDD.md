# Scrap Head: Game Design Document

## Concepto
Arena survival 2D top-down. Un pequeño robot de chatarra sobrevive en un planeta abandonado frente a máquinas defectuosas. Cada enemigo suelta tornillos y el taller ofrece piezas que modifican físicamente al robot.

## Pilares
- Supervivencia simple de leer: moverse y esquivar; el arma dispara sola.
- Cada pieza cambia stats y apariencia: el robot se vuelve visiblemente distinto en cada partida.
- Partidas cortas y completas, con inicio y fin claros.

## Core loop
Oleada → taller → oleada. Sobrevivir, recoger los tornillos que sueltan los enemigos y, al terminar la oleada, elegir en el taller una de 3 piezas (o re-roll / saltar por tornillos) para armarte tú mismo; luego empieza la siguiente.

## Mecánicas
- Movimiento 8 direcciones, disparo manual apuntando con el mouse.
- Vida; derrota al llegar a 0.
- Chatarra (tornillos): moneda que sueltan los enemigos; se imanta al jugador. Se gasta en re-roll del taller.
- Piezas: se eligen en el taller entre 3 ofertas; modifican stats (velocidad, daño, vida, cadencia) y sprite.

## Piezas
Cada pieza ocupa una ranura, cambia stats y se ve en el robot. Rarezas: chatarra, reparada, legendaria. Implementadas hoy: Visor de torreta, Taladro, Orugas de tanque y Mini dron escolta (ver [guía](piezas.md)). La ranura "hombro" aún no tiene capa en el robot.

Sinergias por set: equipar varias piezas del mismo set unifica su pintura y da un bono extra.

| Ranura | Pieza | Efecto |
|---|---|---|
| Cabeza | Visor de torreta | +alcance |
| Cabeza | Módulo de autoapuntado (legendaria) | Dispara solo al enemigo más cercano |
| Cabeza | Antena de radar | Flechas hacia enemigos fuera de pantalla |
| Cabeza | Casco de olla | +2 vida, -velocidad |
| Cabeza | Ojo de cíclope | Crítico x2 con 15% |
| Brazo | Taladro | La bala perfora 2 enemigos |
| Brazo | Sierra circular | La bala rebota en los muros |
| Brazo | Cañón doble | 2 balas en V |
| Brazo | Lanzallamas | Cono de fuego continuo |
| Brazo | Brazo imán | Devuelve las balas enemigas |
| Brazo | Puño hidráulico | Empuja a los enemigos |
| Brazo | Escopeta de tuercas | 5 perdigones |
| Tracción | Ruedas de dron | +velocidad |
| Tracción | Orugas de tanque | +vida, sin empuje |
| Tracción | Patas de araña | Ignora el aceite |
| Tracción | Propulsor | Dash con Espacio |
| Tracción | Monociclo | Muy rápido, -vida |
| Espalda | Batería extra | +vida máxima |
| Espalda | Imán de chatarra | Radio de recogida x2 |
| Espalda | Mini dron escolta | Dron que orbita y dispara cada 1 s |
| Espalda | Reactor inestable | Explota al recibir daño |
| Espalda | Chimenea | Humo que daña |
| Hombro (legendarias) | Torreta de hombro | Segunda arma automática |
| Hombro (legendarias) | Escudo de puerta de nevera | Bloquea un golpe cada 5 s |

## Armas (previstas)
Sierras, taladros, cañones, drones, imanes, lanzallamas. La versión inicial incluye un cañón básico.

## Enemigos
Todos heredan de `EnemyBase` (vida, flash, empuje, barra de vida tras recibir daño, drop). Con `elite = true`: dorado, vida x3, más grande y drop garantizado.
- Oxidado: persigue; a corta distancia se detiene, tiembla y su ojo parpadea, luego embiste en línea recta y se recupera. Suelta Taladro.
- Chispa: dron kamikaze rápido, vuela en zigzag y explota en área (con círculo de aviso) al llegar o al morir. Suelta Mini dron.
- Remachadora: torreta fija; carga un láser de aviso y dispara una ráfaga de remaches. Mucha vida. Suelta Visor de torreta.
- Prensa: tanque élite lento y muy resistente; golpe de área telegrafiado con círculo rojo, temblor y polvo. Suelta Orugas siempre.
- Dron militar: rápido y frágil (pendiente).
- Máquina gigante: jefe de la oleada 5 (pendiente).

## Nivel
- 5 oleadas con temporizador y dificultad creciente; la oleada 5 termina con el jefe "máquina gigante".
- Taller de piezas tras cada oleada (no tras la última).
- Arena única de fábrica abandonada, 1280x720.

## Victoria y derrota
- Victoria: derrotar al jefe en la oleada 5.
- Derrota: vida a 0. Ambas pantallas permiten reintentar.

## Arte
Pixel art 32x32, paleta óxido / metal / acento naranja, contorno oscuro y 2-3 tonos por material.

## Audio
Chiptune generado por script: música de fondo y efectos (disparo, golpe, explosión).

## Controles
WASD o flechas para moverse. Mouse para apuntar y clic izquierdo para disparar.
