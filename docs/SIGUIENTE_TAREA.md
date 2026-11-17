# Encargo T05 completado — continuidad hacia T06

T05 implementada y comprobada en Linux en `feat/v0.1-t05-ciclo-partida`.
Código: `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`; cierre documental posterior.
Estados51/0, ventana145/0 en 1280×720 y 960×540, regresiones T02–T04 sin fallos.
Comandos, capturas y límites en ESTADO.md y `docs/validacion/T05-linux.log`.
Sin merge. **Windows nativo sigue pendiente**.

Siguiente tarea: **T06 — Validación y entrega** según IMPLEMENTACION.md y el
próximo encargo de main. Conservar esta rama/código y T01–T04. Falta preparar y
comprobar el paquete descargable para laptop; exportar desde Linux no acredita
ejecución nativa Windows ni una sesión humana. No declarar V0.1 entregada todavía.

Se conserva debajo el encargo T05 leído de main en `a5ea2f1`, como referencia de
aceptación; ya no es una tarea pendiente.

## Encargo original — T05: Ciclo e interfaz de partida

## Base
Partir de `37e1ee96e41023bb28965dcd87c90abdf0e706e8` en `feat/v0.1-t04-habilidades`, código `c0a02d1e2bf9b78d78164d764918c34bdaeaf0a0`, creando rama descriptiva. Conservar T01–T04. Leer este encargo de main sin sustituir ESTADO ni código recientes. Sin merge ni force push.
Leer AGENTS.md y documentos obligatorios, README, arena.gd/arena.tscn, controladores, combat_actor.gd, weapon.gd, projectile.gd, pulse_ability.gd y suites T02–T04. Mantener Godot 4.6.3 Compatibility.

## Implementación concreta
1. Estados explícitos jugando, victoria y derrota. Vencer al enemigo gana; morir pierde. Definir resultado determinista si ambos mueren en el mismo tick y documentarlo como regla provisional; una transición final no se revierte ni duplica señales.
2. Al terminar bloquear movimiento/combate de jugador e IA, básico/Q/E y cualquier daño pendiente. Retirar o neutralizar proyectiles activos para que no cambien salud/resultado tras el cierre. Mantener interfaz operativa y efectos sin acumulación. Evitar pausa global que impida reiniciar o deje entradas atascadas.
3. HUD legible con objetivo, salud, controles y recargas; pantalla o panel final inequívoco de victoria/derrota y botón Reiniciar accesible mediante ratón y teclado. R reinicia desde final; conservar restauración durante juego si resulta útil y documentarla.
4. Reutilizar recarga completa de escena: salud, posiciones, objetivo, recargas, efectos, proyectiles, estados e indicadores quedan iniciales. Gestionar teclas mantenidas, eco y clic del botón para no lanzar acciones accidentales al volver.
5. Interfaz ajustada a ventana de laptop: comprobar 1280×720 y una ventana menor, sin texto cortado ni superposición que tape al jugador. Recursos provisionales propios; sin ampliar arte, catálogo ni sistemas online.

## Aceptación
- Importación/arranque sin errores y regresiones T02–T04. Adaptar montajes que antes permitían combate después de muerte a los nuevos estados, sin retirar cobertura relevante; conservar pruebas aisladas de salud/proyectil/habilidades.
- Ganar y perder mediante combate real; comprobar transición única, resultado definido en caso simultáneo y ausencia de daño/ataques/movimiento tras cierre, incluidos proyectiles en vuelo y Q/E pulsados.
- Tres reinicios consecutivos alternando victoria y derrota, por R y botón: estado inicial completo, sin nodos/conexiones duplicados ni entradas pegadas. Probar varias pulsaciones rápidas de reinicio.
- Validación gráfica de juego/victoria/derrota, foco y botón con teclado/ratón; capturas propias en resoluciones indicadas. Separar automatización, revisión visual y manejo humano.
- Registrar comandos, resultados y limitaciones reales; priorizar corrección de fallos antes de T06. Windows sigue pendiente hasta ejecución nativa.

## Cierre
Actualizar README y ESTADO.md, publicar rama y SHA de código/cierre, sin merge. Siguiente T06: validación integral y paquete Windows descargable con instrucciones para laptop. No afirmar compatibilidad nativa por exportar desde Linux. El usuario desea aviso cuando esté jugable y visualmente accesible: T05 completa el ciclo, pero aún falta la entrega comprobable T06.

## Evidencia de base revisada
Comparación remota T03→T04: dos commits, base conservada. Revisados estado, log y código de pulso/HUD; revisión estática parcial sin ejecutar Godot ni reinspeccionar imágenes. Log publicado: Q57/0, E78/0, integración42/0, gráfica49/0 y regresiones aprobadas. No constituyen pruebas repetidas por este seguimiento.
