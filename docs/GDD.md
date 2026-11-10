# Scrap Head: Game Design Document

## Concepto
Arena survival 2D top-down. Un pequeño robot de chatarra sobrevive en un planeta abandonado frente a máquinas defectuosas. Cada enemigo suelta piezas que modifican físicamente al robot.

## Pilares
- Supervivencia simple de leer: moverse y esquivar; el arma dispara sola.
- Cada pieza cambia stats y apariencia: el robot se vuelve visiblemente distinto en cada partida.
- Partidas cortas y completas, con inicio y fin claros.

## Core loop
Sobrevivir a la oleada, recoger chatarra y piezas, visitar el taller, equipar y pasar a la siguiente oleada.

## Mecánicas
- Movimiento 8 direcciones, disparo automático al enemigo más cercano.
- Vida; derrota al llegar a 0.
- Chatarra: moneda que sueltan los enemigos.
- Piezas: se compran/eligen en el taller; modifican stats (velocidad, daño, vida, cadencia) y sprite.

## Armas (previstas)
Sierras, taladros, cañones, drones, imanes, lanzallamas. La versión inicial incluye un cañón básico.

## Enemigos
- Robot oxidado: persigue y daña al contacto.
- Dron militar: rápido y frágil.
- Torreta: estática, dispara.
- Tanque / máquina gigante: lento y resistente; la máquina gigante es el jefe.

## Nivel
- 5 oleadas con temporizador y dificultad creciente; la oleada 5 termina con el jefe "máquina gigante".
- Taller de piezas entre oleadas.
- Arena única de fábrica abandonada, 1280x720.

## Victoria y derrota
- Victoria: derrotar al jefe en la oleada 5.
- Derrota: vida a 0. Ambas pantallas permiten reintentar.

## Arte
Pixel art 32x32, paleta óxido / metal / acento naranja, contorno oscuro y 2-3 tonos por material.

## Audio
Chiptune generado por script: música de fondo y efectos (disparo, golpe, explosión).

## Controles
WASD o flechas para moverse. Disparo automático.
