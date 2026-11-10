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
- [x] Los enemigos aparecen en la arena y se dirigen al jugador.
- [x] Al tocar al jugador le quitan vida, con un breve periodo de invulnerabilidad.
- [x] Los enemigos mueren al recibir suficiente daño.

### HU-03 Disparo manual
Como jugador quiero apuntar con el mouse y disparar con clic para controlar cada tiro.
- [x] El robot mira y dispara hacia el cursor.
- [x] Mantener clic izquierdo dispara con una cadencia fija.
- [x] Los proyectiles dañan y desaparecen al impactar o salir de la arena.

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

### HU-15 Piezas visibles
Como jugador quiero que las piezas que equipo se vean en mi robot y cambien mis stats para sentir progreso.
- [x] El robot es modular: capas piernas, cuerpo, espalda, brazo y cabeza.
- [x] Equipar una pieza reemplaza la de su ranura y recalcula velocidad, vida máxima, cadencia, daño, perforación y autoapuntado.
- [x] Equipar da feedback: flash blanco, squash, chispas y texto flotante con el nombre.
- [x] El cuerpo base cambia (oxidado, reparado, pulido) según las piezas equipadas.
- [x] Hay 4 piezas de ejemplo: Visor de torreta, Taladro, Orugas de tanque y Mini dron escolta.
- [x] Las piezas se obtienen en el taller (HU-11), no del suelo.
- [ ] Resto del catálogo (ver GDD, sección Piezas).

### HU-16 Animaciones
Como jugador quiero personajes y efectos animados para que el juego se vea vivo.
- [x] Robot con piernas animadas (idle y caminar), brazo que rota hacia el mouse con retroceso y fogonazo.
- [x] Enemigo con caminar tambaleante, ojo que pulsa, flash y retroceso al ser golpeado.
- [x] Explosión de 6 frames con tuercas y chispas al morir un enemigo.
- [x] Bala con 2 frames de brillo y chispas al impactar.
- [x] Squash al empezar a moverse y polvo al caminar.
- [x] Al morir, el robot se desarma antes de reiniciar.

### HU-08 Cinco oleadas
Como jugador quiero oleadas con temporizador y dificultad creciente para sentir progresión.
- [x] Hay 5 oleadas con temporizador visible.
- [x] Cada oleada genera más enemigos o más fuertes.
- [x] Al acabar el tiempo se limpian los enemigos y se pasa al taller (HU-11).

### HU-10 Recoger chatarra
Como jugador quiero recoger chatarra de los enemigos para comprar mejoras.
- [x] Los enemigos sueltan tornillos al morir (más los élites y los fuertes).
- [x] El tornillo salta al aparecer, se imanta al acercarse y parpadea antes de desaparecer.
- [x] El jugador acumula `scrap` y emite `scrap_changed` (HUD pendiente).

### HU-11 Taller de piezas
Como jugador quiero un taller entre oleadas para armar mi robot.
- [x] El taller aparece al terminar cada oleada (menos la última) y pausa el juego.
- [x] Ofrece 3 piezas al azar con rareza y diferencias de stats frente a la pieza actual.
- [x] Una vista previa del robot muestra la pieza al pasar el mouse por una tarjeta.
- [x] Elegir (clic o teclas 1/2/3) equipa la pieza con efecto y empieza la siguiente oleada.
- [x] Re-roll con coste creciente en tornillos y opción de saltar a cambio de tornillos.

## Épica 2: Estructura de partida (Entrega 2)

### HU-07 Pantalla de título
Como jugador quiero una pantalla de título para empezar la partida de forma clara.
- [ ] Muestra el nombre del juego y botones Jugar y Salir.
- [ ] Jugar carga la arena.

### HU-09 Variedad de enemigos
Como jugador quiero distintos tipos de enemigos para variar mi estrategia.
- [ ] Dron rápido y frágil.
- [ ] Torreta estática que dispara al jugador.
- [ ] Tanque lento y resistente.

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
