---
tags: [validacion, godot]
---
# Bitácora de validación

[[Inicio]] · [[Punto de reanudación]]

## V0.3 T03 · Torres y vuelo

- Asedio en Linux: 27 comprobaciones headless y 30 en cada resolución,
  1280×720 y 960×540, sin fallos.
- Casos: disparo de torre, bloqueo del daño directo y del pulso por escudo,
  desbloqueo del núcleo correcto, daño por proyectil, victoria, empate,
  limpieza y reinicio. En ventana también se probó vuelo hacia el cursor,
  retroceso y zoom.
- Regresiones headless: movimiento 34, balizas 15, equipamiento 225 y
  estados de partida 51, sin fallos.
- Durante el desarrollo, Godot rechazó un array sin tipo enviado al método
  de defensa. El controlador ahora utiliza referencias tipadas a las torres.
- Pendiente: Windows nativo, rendimiento en GPU de laptop y balance humano.

## Verificar cada ZIP

Generar desde un commit con `git archive`. Ejecutar `unzip -t` y extraer a
una carpeta nueva. Importar el proyecto con `godot --headless --path game
--editor --import --quit` desde la raíz extraída y revisar el log. Ejecutar
la escena principal y la prueba del modo desde esa copia. Abrir la carpeta
de Obsidian y comprobar que conserva las notas y su índice.

## V0.3 T04 · Modelos y profundidad de la Caldera

- Tres GLB regenerados con Blender 4.3.2. Las membranas y pieles usan
  pigmentos procedurales de 512×512. Se conservan 16 huesos y cuatro clips.
- Cobre ganó cuernos curvos y coraza; Jade ganó alas de hoz y aletas; Sentinela
  ganó cristales en alas y pecho. Los recursos son originales y reproducibles.
- La Caldera agregó acantilados estratificados, islas, basalto agrietado
  y niebla concentrada bajo el carril. El borde es decorativo.
- Asedio: 27/0 headless y 30/0 a 1280×720 y 960×540 en Linux.
  Galería: 58/0 en ambas resoluciones dentro de la misma suite. Capturas en
  `docs/validacion/V03-T04` desde la raíz del proyecto.
- Pendiente: prueba Windows, rendimiento de laptop y otra pasada de
  materiales, modelado orgánico y efectos de combate.

## V0.3 T05 · Materiales e impactos

- Tres GLB regenerados con Blender 4.3.2. Cada GLB contiene dos mapas de
  normales, 16 huesos y cuatro clips. Revisar desde la galería 3D.
- Asedio Linux: 29/0 headless y 32/0 a 1280×720 y 960×540. La prueba observa
  la creación de un efecto por colisión, su captura y su eliminación.
- Galería: 58/0. Presentación de modelos, mapas de normales y animación: 46/0.
  Regresiones de combate, pulso, Q y balizas: 201/0.
- Evidencia: `docs/validacion/V03-T05`. El entorno gráfico usa llvmpipe.
  Quedan pendientes Windows nativo y rendimiento en GPU de laptop.

## V0.4 T01 · Frontera de Ceniza

- Nueva arena original de hielo y lava, con cámara oblicua cercana, minimapa
  y vista táctica en vivo con M. Capturas en `docs/validacion/V04-T01`.
- Diez dragones por partida, tres torres por equipo y dos núcleos.
  Daño a núcleo desbloqueado al caer la última torre de su facción.
- Vuelta a base a los seis segundos, marcador y reinicio comprobados.
- 16 verificaciones por resolución en Linux a 1280×720 y 960×540.
  Simulación de 35 s con IA: 12 bajas y pico de cuatro proyectiles.
- Regresiones headless: selector 64/0, asedio 29/0, balizas 15/0,
  equipamiento 225/0. Pendientes Windows y prueba de balance humano.

## V0.4 T02 · Oleadas y Jade

- Frontera: 22/0 sin interfaz y 22/0 por resolución en ventana, 1280×720
  y 960×540. Se probó aparición, avance y limpieza de oleadas, retirada y
  recuperación de bots, escudo, reaparición y reinicio.
- Galería 58/0. Regresiones: asedio 29/0, T03 52/0, núcleo 51/0 y balizas 15/0.
- Capturas reales de Jade en galería y combate en `docs/validacion/V04-T02`.
- Pendientes: balance con pruebas humanas y rendimiento en Windows.

## V0.5 T01 — Nethergate 5 contra 5

En el selector, elige Nethergate para volar entre islas sobre un barranco. En cada una de las tres runas, el equipo con más dragones vivos presentes avanza la captura. Las runas aceleran la carga del titán de su equipo. El titán marcha contra la puerta y su primer impacto desactiva el escudo. Escolta al aliado o intercepta al enemigo. Al romper la puerta aparece el resultado y emerge el titán liberado.

Inspiración visual y reglas generales: pantalla de carga y capturas de Nethergate aportadas por el jugador. Geometría, materiales, número y ubicación de las runas, tiempos, resistencia y daño son decisiones del prototipo. Juego local con nueve bots.

Código probado `4eae7b8`. Godot 4.6.3 Compatibility en Linux sin ventana. Nethergate 13/13 y Frontera 35/35. Una simulación con el jugador inactivo terminó en derrota a los 63,7 s. El servidor gráfico no pudo abrir la pantalla. Pendiente comprobar en Windows la legibilidad de las runas, el agua, el anuncio final y el ritmo de una partida humana.

## V0.5 T02 — Atlas y duelo LAN

F5 abre el atlas ilustrado. Elige un destino para leer el objetivo y entrar. Dragones y equipo abre el selector. Guía de modos resume los seis destinos jugables y explica los modos pendientes ARAM, Aventura y Capture Points de cinco puntos.

Para jugar entre dos PC, abre el mismo proyecto en ambos con Godot 4.6.3. En una misma red, elige Multijugador LAN → Abrir sala LAN. El anfitrión pulsa Crear sala y comparte la IP mostrada. El invitado introduce esa dirección y pulsa Unirme. La sala usa UDP 27940. Si Windows pide permiso al juego para la red local, permite redes privadas. WASD mueve al dragón, el cursor apunta y el clic izquierdo dispara. Cada dragón comienza con 100 PV. El primer derribo termina el duelo. Salir al atlas permite comenzar una sala nueva.

Las Agujas es un duelo entre Cobre y Jade con estadísticas iguales. El anfitrión resuelve movimiento, daño y resultado. Los mapas 5v5 mantienen sus nueve bots. Ilustración original generada para el atlas en esta entrega.

Código probado `ad7c032`, rama `feat/atlas-duelo`. Dos procesos Linux con ENet por 127.0.0.1 verificaron el selector, la conexión, movimiento, daño y resultados opuestos. Frontera 35/35 y Nethergate 13/13. Pendiente inspección gráfica y prueba entre dos PC Windows en una misma red.

## V0.6 — Códice y modos del atlas

Extrae el ZIP, importa `game/project.godot` en Godot 4.6.3 y pulsa F5. El Códice de los jinetes ofrece búsqueda por sección. El Pacto, Cinco bastiones, Halvalas y Mire Bog se seleccionan directamente en el mapa. Las cantidades de oro, tiempos y balance son provisionales.

Consulta `docs/obsidian/Wiki y cobertura jugable.md` para ver las fuentes, las diferencias y el alcance por modo.

Código local probado `edb41fe` en `feat/wiki-capture`. Godot 4.6.3 en Linux sin ventana. 23 comprobaciones del códice y los modos, 35 de Frontera, 13 de Nethergate, 51 del núcleo y 225 de equipamiento. En la simulación sin intervención, Captura y ARAM llegaron a derrota. El Pacto seguía en combate tras 179 segundos. Pendiente verificación gráfica y balance con jugadores en Windows.
