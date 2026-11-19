# Punto de reanudación

[[Wiki y cobertura jugable]] · [[Bitácora de validación]]

## V0.6 — Códice y modos del atlas

Extrae el ZIP, importa `game/project.godot` en Godot 4.6.3 y pulsa F5. El Códice de los jinetes ofrece búsqueda por sección. El Pacto, Cinco bastiones, Halvalas y Mire Bog se seleccionan directamente en el mapa. Las cantidades de oro, tiempos y balance son provisionales.

Consulta `docs/obsidian/Wiki y cobertura jugable.md` para ver las fuentes, las diferencias y el alcance por modo.

Código local probado `edb41fe` en `feat/wiki-capture`. Godot 4.6.3 en Linux sin ventana. 23 comprobaciones del códice y los modos, 35 de Frontera, 13 de Nethergate, 51 del núcleo y 225 de equipamiento. En la simulación sin intervención, Captura y ARAM llegaron a derrota. El Pacto seguía en combate tras 179 segundos. Pendiente verificación gráfica y balance con jugadores en Windows.

Siguiente bloque pendiente: equipamiento funcional de hechizos y runas, fichas individuales verificadas y continuación de campaña.

La wiki sirve como guía interna del equipo. El códice del jugador presenta sus categorías y resultados sin direcciones externas.

## Proving Grounds · v0.7

Destino PvE del atlas. Selección de dragón y arma antes de entrar. La primera victoria otorga el logro Proven y 50 cristales para una estela turquesa local. La vitrina general sigue en Dragones y equipo. No hay pagos.

| Capturas del tutorial | Aplicación |
|---|---|
| 01_0m30 y 02_1m30 | Destino del atlas con objetivo, recompensa y preparación. |
| 03_2m00 a 06_4m15 | Vitrina existente y selector del equipo disponible. La compra de una estela usa cristales de la misión. El comercio de War Marks queda pendiente. |
| 07_4m30 y 08_5m00 | Acercamiento inicial a la base y reaparición junto a la jaula aliada. |
| 09_hud a 11_panel | Barras, recargas, posición y objetivo en minimapa. El marcador superior cambia del escudo a la jaula. |
| 12_5m30 y 13_6m45 | Flecha direccional, vuelo, regreso al tesoro y depósito. |
| 14_7m15 a 16_8m45 | Tres demonios atacan el obelisco. Clic, Q y E usan el combate compartido. Los impactos fuertes añaden una pausa de 45 ms, movimiento de cámara y cifras. Duelo contra un dragón controlado por IA. |
| 17_9m45 a 19_11m00 | Dos torres protegen el santuario. Destruirlo abre la jaula. La ruptura muestra la victoria y permite volver al atlas. |

Prueba automatizada: game/tests/test_proving_grounds.gd. Ejecutar con un directorio de datos de usuario temporal vacío. Los tiempos, la economía y los valores de daño son ajustes locales. Pendientes: contraste y ritmo en Windows, terreno y cinemáticas específicos del tutorial, y vitrina ampliada.

v0.7.1 · [[Práctica de vuelo]] documenta la escena aislada de movimiento y cámara, el árbol exacto y la prueba F5/F6. El laboratorio permite capturar con F12.
