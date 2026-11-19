# T05 — Estados de partida, bloqueo y reinicio

> Ejecución por IA: TDD y tareas independientes; revisión final. Especificación:
> `docs/SIGUIENTE_TAREA.md` recuperado de main, sin sustituir la continuidad T04.

**Base:** `37e1ee96e41023bb28965dcd87c90abdf0e706e8`; nueva rama
`feat/v0.1-t05-ciclo-partida`, sin merge/force push. Godot4.6.3 Compatibility.

## Diseño acordado para este incremento

- Arena: `MatchState { PLAYING=0, VICTORY=1, DEFEAT=2 }`, `state` y señal
  `match_finished(result)` única. Muestrea salud al final del paso físico con
  prioridad100, después de actores/proyectiles (0). Si ambos mueren en ese paso,
  **derrota tiene prioridad**; regla provisional, no del juego original.
- Fin: ambos actores deshabilitados para acciones y daño; movimiento y armas
  comprueban `can_act()`. Proyectiles neutralizados/eliminados y efectos limpiados.
  No pausa global: interfaz/R siguen operativos, resultado ya final no cambia.
- Reinicio: recarga completa existente con guardia contra peticiones repetidas.
  Jugador captura entradas mantenidas al crear la escena y espera su liberación;
  clic del botón, eco o teclas anteriores no deben provocar ataques/movimiento.
- HUD independiente: conserva `Controls/Panel/Margin/Label`, API
  `update_view(status_text, result)`, `restart_requested`, panel final inferior y
  botón Reiniciar con foco de teclado. No tapa al jugador en el centro.
- Ventanas: 1280×720 y960×540, mismo viewport lógico con escalado de Godot;
  capturas y comprobaciones de bounds/foco/ratón/teclado.

## Tareas

- [x] Leer main, conservar T04 y crear rama desde la base exacta.
- [x] Núcleo de estados/bloqueo/entrada segura y pruebas TDD (agente dedicado).
- [x] HUD/escena responsive y botón accesible (agente dedicado).
- [x] Integrar HUD en arena; adaptar SOLO montajes legacy que prueban combate
  tras muerte, pausando resolución de partida pero conservando aserciones.
- [x] Prueba gráfica T05: ganar/perder por combate real, bloqueo completo,
  tres reinicios alternos con R/botón, entradas retenidas y peticiones rápidas.
- [x] Importación, arranque, suites nuevas y regresiones T02–T04.
- [x] Gráficos y capturas en ambas ventanas; revisión independiente y correcciones.
- [x] Commit de código; README/ESTADO/evidencia, siguiente T06; commit y push.

Resultados: estados51/0; ventana145/0; regresiones completas sin fallos.
Código `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`; cierre documental posterior.
Evidencia y limitaciones en ESTADO.md. Windows y entrega T06 siguen pendientes.

## Foco de revisión

- Daño simultáneo en ambos órdenes: resultado estable y una sola señal.
- Daño/proyectiles/Q/E/movimiento después de cerrar, incluso llamadas directas.
- Controles retenidos y clic/Enter de reinicio no se arrastran a la nueva escena.
- R y botón rápidos: no recargar una escena ya retirada ni duplicar conexiones.
- Texto/foco/botón legibles sin recorte en1280×720 y960×540; no tapar el jugador.
- T06 y Windows nativo siguen pendientes; este incremento no entrega aún paquete
  descargable probado en la laptop ni debe presentarse como validación Windows.
