# T02 — Dragón y cámara

> Ejecución por IA: `superpowers:executing-plans`; validación con Godot 4.6.3 real y revisión independiente final.

**Objetivo:** implementar T02 según `docs/SIGUIENTE_TAREA.md`, sin combate.

**Arquitectura:** `DragonController` mueve una raíz Node3D en física sobre XZ.
Solo el hijo `Facing` gira hacia el cursor. La cámara de T01 pasa a ser hija
de la raíz móvil: mantiene su ángulo/offset y sigue sin retardo ni rotación al apuntar.
La interpolación física suaviza el seguimiento. La silueta es una escena separada
con primitivas propias, delegada para trabajar en paralelo sin editar archivos comunes.

**Convención elegida:** WASD relativo a los ejes horizontales de la cámara;
W avanza hacia la parte superior de la pantalla. El dragón apunta con su eje -Z
al cursor proyectado al plano de vuelo. Velocidad 6, altura 1.5 y margen de arena
2 unidades son provisionales y exportados, no datos del juego original.

**Restricciones:** conservar Godot 4.6.3/Compatibility, suelo/luz de T01,
geometría propia sin descargas, Windows pendiente, no implementar T03–T06.

## Pasos

- [x] Conservar T01 en commit, traer los documentos remotos y publicar la rama T01.
- [x] Añadir pruebas reales de entrada/movimiento, diagonales, altura, límites,
  apuntado y relación cámara/jugador; observar fallo sin el controlador.
- [x] Crear `game/scripts/dragon_controller.gd` y `game/scenes/dragon.tscn`;
  componer `Facing`, visual y cámara; añadir instanciación a la arena.
- [x] Configurar Input Map físico WASD y mostrar controles de T02 mediante CanvasLayer.
- [x] Ejecutar importación, pruebas headless e inicio de escena con versión fijada.
- [x] Renderizar y probar entrada con servidor gráfico Linux; inspeccionar dragón,
  apuntado, bordes y seguimiento. Registrar límites de la prueba y captura propia.
- [x] Actualizar README/ESTADO/encargo, revisar independientemente, commit y push de T02.

## Foco de revisión

- Diagonal y teclas opuestas: evitar velocidad extra y movimiento residual.
- Esquinas: respetar margen de toda la silueta, no solo el centro del nodo.
- Cursor casi sobre el dragón o rayo sin intersección: preservar orientación finita y sin inclinación.
- Movimiento y apuntado simultáneos: el giro de la representación no debe girar la cámara ni alterar WASD.
- Suavidad/interpolación y legibilidad: requieren prueba gráfica, no solo salida 0 headless.
- Las pruebas Windows y la validación humana prolongada no deben darse por realizadas.
