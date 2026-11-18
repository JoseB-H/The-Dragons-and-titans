# T03 — Combate y enemigo

> Ejecución IA: planificación y TDD, tareas independientes delegadas, integración
> y revisión final. Especificación: `docs/SIGUIENTE_TAREA.md` recuperado de main.

**Objetivo:** combate básico contra un enemigo, física real y restauración mínima;
conservar movimiento/cámara T02. Godot 4.6.3 Compatibility, Windows pendiente.

**Base:** nueva rama `feat/v0.1-t03-combate-y-enemigo` desde `f436099`, sin merge.
Solo se recupera el encargo remoto, sin sustituir código ni ESTADO de T02.

## Arquitectura e interfaces

- `CombatActor` (CharacterBody3D): `max_health`, `current_health`, `faction`,
  `is_alive()`, `take_damage(amount, attacker_faction)`, señales de salud y muerte.
- `Weapon` (hijo del actor): datos exportados, `cooldown_remaining`,
  `projectile_parent`, `try_fire(direction)`. Sin entrada ni IA en el arma.
- `Projectile`: barrido de trayecto en física con rayquery; excluye emisor,
  aliados y muertos. Consumo único y caducidad. Datos capturados al disparar.
- Jugador: extiende CombatActor y conserva Facing/cámara T02; clic izquierdo
  mantenido dispara hacia -Z de Facing. Muerto no se mueve ni dispara.
- Enemigo: extiende CombatActor, objetivo asignado por Arena, persecución XZ,
  límites, alcance y arma con recarga; se detiene si él o su objetivo mueren.
- Arena: conecta composición, contenedor Projectiles, HUD mínimo de salud/recarga
  y acción R que recarga la escena completa. Sin estados de partida T05.

Valores provisionales: salud jugador/enemigo 100/80; daño 20/10; velocidad
proyectil 28, vida 2 s; recarga jugador/enemigo 0.4/1 s; enemigo velocidad 3,
alcance 7. No son estadísticas del juego original. Todos ajustables.

## Pasos y comprobación

- [x] Leer encargo de main, conservar base T02 y crear rama nueva sin merge.
- [x] Núcleo compartido y sus pruebas TDD (agente dedicado, archivos propios).
- [x] Enemigo/visual provisional (agente dedicado, archivos propios).
- [x] Escribir prueba de integración fallida antes de integrar jugador/arena.
- [x] Integrar escenas, Input Map, HUD y restauración por recarga de escena.
- [x] Importar, ejecutar suites núcleo/integración y regresión T02; arrancar escena.
- [x] Ejecutar prueba gráfica con combate y regresión T02, inspeccionar capturas.
- [x] Revisión independiente, corregir hallazgos y guardar código con pruebas.
- [x] README/ESTADO/CONTEXTO/encargo con evidencia y siguiente T04; commit y push.

## Foco de revisión

- Proyectil rápido atravesando varios cuerpos: exclusión de aliados y un solo daño.
- Paso mayor que vida restante: no impactar después de caducar.
- Muerte/recarga/entrada simultáneas: no generar acciones nuevas de muertos.
- Distancia al objetivo en borde/rango: no perseguir indefinidamente ni salir de arena.
- Tres recargas de escena: sin nodos, conexiones, estado o proyectiles heredados.
- Conservar TODAS las comprobaciones de T02 aislando su enemigo en el montaje,
  sin desactivar aserciones. Gráficos automatizados no equivalen a Windows probado.
