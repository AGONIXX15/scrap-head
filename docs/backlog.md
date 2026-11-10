# Backlog

## Flujo de trabajo
- Una rama por historia: `feature/hu-XX-nombre`.
- Al terminar, merge a `main` con `git merge --no-ff`.

## Épica 1: Núcleo jugable (Entrega 1)

### HU-01 Movimiento y cámara
Como jugador quiero mover al robot con WASD o flechas para explorar la arena.
- [x] El robot se mueve en 8 direcciones a velocidad constante (150).
- [x] El sprite se voltea según la dirección horizontal y se balancea al caminar.
- [x] La cámara sigue al robot con suavizado y no sale de la arena.
- [x] Los muros impiden salir de la arena.

### HU-02 Robots oxidados
Como jugador quiero que robots oxidados me persigan y me dañen al contacto para sentir amenaza.
- [ ] Los enemigos aparecen en la arena y se dirigen al jugador.
- [ ] Al tocar al jugador le quitan vida, con un breve periodo de invulnerabilidad.
- [ ] Los enemigos mueren al recibir suficiente daño.

### HU-03 Disparo automático
Como jugador quiero disparar automáticamente al enemigo más cercano para centrarme en esquivar.
- [ ] El arma apunta al enemigo más cercano en rango.
- [ ] Dispara a intervalo fijo mientras haya objetivo.
- [ ] Los proyectiles dañan y desaparecen al impactar o salir de la arena.

### HU-04 HUD de vida y derrota
Como jugador quiero ver mi vida para saber cuándo estoy en peligro.
- [ ] El HUD muestra la vida actual y máxima.
- [ ] La barra se actualiza al recibir daño.
- [ ] Con vida 0 el juego termina y se muestra la derrota.

### HU-05 Arena de fábrica abandonada
Como jugador quiero una arena con ambientación de fábrica abandonada para sentir el mundo del juego.
- [ ] Suelo de placas metálicas sin costuras visibles.
- [ ] Bordes de arena definidos.
- [ ] Decoración (cajas, tuberías, manchas de óxido).
- [ ] Sombras bajo personajes y objetos.

### HU-06 Efectos y sonidos básicos
Como jugador quiero oír y ver el resultado de mis acciones para tener retroalimentación.
- [ ] Sonido de disparo, golpe y explosión.
- [ ] Efecto visual al morir un enemigo.
- [ ] Música de fondo en bucle.

## Épica 2: Estructura de partida (Entrega 2)

### HU-07 Pantalla de título
Como jugador quiero una pantalla de título para empezar la partida de forma clara.
- [ ] Muestra el nombre del juego y botones Jugar y Salir.
- [ ] Jugar carga la arena.

### HU-08 Cinco oleadas
Como jugador quiero oleadas con temporizador y dificultad creciente para sentir progresión.
- [ ] Hay 5 oleadas con temporizador visible.
- [ ] Cada oleada genera más enemigos o más fuertes.
- [ ] Al acabar el tiempo se limpian los enemigos y se pasa al taller.

### HU-09 Variedad de enemigos
Como jugador quiero distintos tipos de enemigos para variar mi estrategia.
- [ ] Dron rápido y frágil.
- [ ] Torreta estática que dispara al jugador.
- [ ] Tanque lento y resistente.

## Épica 3: Progresión y piezas (Entrega 2)

### HU-10 Recoger chatarra
Como jugador quiero recoger chatarra de los enemigos para comprar mejoras.
- [ ] Los enemigos sueltan chatarra al morir.
- [ ] La chatarra se recoge al acercarse y se muestra en el HUD.

### HU-11 Taller de piezas
Como jugador quiero un taller entre oleadas para modificar mi robot.
- [ ] El taller aparece al terminar cada oleada.
- [ ] Ofrece piezas con coste en chatarra.
- [ ] Equipar una pieza cambia stats y apariencia del robot.

## Épica 4: Final y pulido (Entrega 2)

### HU-12 Jefe máquina gigante
Como jugador quiero un jefe en la oleada 5 para tener un final memorable.
- [ ] El jefe aparece en la oleada 5 con barra de vida.
- [ ] Tiene al menos dos patrones de ataque.
- [ ] Derrotarlo termina la partida con victoria.

### HU-13 Victoria y derrota
Como jugador quiero pantallas de victoria y derrota con reintento para volver a jugar.
- [ ] Pantalla de victoria al derrotar al jefe.
- [ ] Pantalla de derrota con vida 0.
- [ ] Ambas permiten reintentar o volver al título.

### HU-14 Pulido
Como jugador quiero efectos y ajustes finales para que el juego se sienta bien.
- [ ] Screen shake y flash al recibir daño.
- [ ] Partículas en impactos y explosiones.
- [ ] Iluminación básica.
- [ ] Control de volumen.
