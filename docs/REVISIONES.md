# Seguimiento de revisiones

## Referencia inicial — 16 de noviembre de 2026
- Rama revisada: `main` (única rama publicada).
- SHA revisado: `e357b74c210823b61db522fa0d3a1d575e67ae0f`.
- SHA de código revisado: no existe todavía; el árbol contiene únicamente README, AGENTS y documentación.
- PR abiertos o cerrados: ninguno. Ejecuciones de GitHub Actions: ninguna.
- Leídos AGENTS.md, CONTEXTO_IA.md, PLAN_INICIAL.md, IMPLEMENTACION.md y ESTADO.md.
- Verificado mediante árbol completo e historial: planificación inicial; T01–T06 pendientes. No hay entrega de programación ni evidencia de finalización de Codex.
- No probado: importación, ejecución y comportamiento del juego; aún no existe proyecto ejecutable.
- Próximo encargo vigente: T01 de docs/IMPLEMENTACION.md, tal como indica docs/ESTADO.md. No se genera un encargo nuevo hasta detectar una entrega que requiera revisión.

## Regla para próximas revisiones
Comparar ramas y cambios de código contra esta referencia o la última entrega registrada aquí. Registrar por entrega la rama, SHA de código, evidencia y pruebas disponibles. Los commits que solo actualicen esta documentación de seguimiento o SIGUIENTE_TAREA.md no son avances de Codex y no requieren otro commit de seguimiento sin novedades. Conservar el registro anterior; no afirmar validaciones ejecutadas cuando solo se revisaron archivos.

## Entrega T02 — 16 de noviembre de 2026
- Rama: `feat/v0.1-t02-dragon-y-camara`.
- SHA de código revisado: `66815e5f1d9ccd899baea84f76bce0ef9f5301b9`.
- SHA de cierre revisado: `f436099969a70df498ee46c92b3fba60d30c6ba9`.
- T01 publicada en `feat/v0.1-t01-proyecto-ejecutable`, punta `35954f2b2ac17d29e39be66be598549af386c69d`.
- Frente a referencia inicial: proyecto Godot, dragón, movimiento, apuntado, límites, cámara y suites presentes. Revisados diff T02, instrucciones, estado y log publicado. Sin hallazgos bloqueantes en esta revisión estática.
- Evidencia registrada por entrega: importación/arranque salida 0; 34 comprobaciones headless y 22 gráficas aprobadas en Linux. No repetidas aquí; imágenes no reinspeccionadas. Revisión independiente aprobada según ESTADO, no repetida por este seguimiento.
- PR: ninguno; Forbidden reportado por Codex. GitHub Actions: ninguna ejecución. No hay validación CI independiente.
- No probado aquí: ejecución Godot, interacción, imágenes. Windows y GPU física pendientes según entrega.
- Nuevo encargo T03 en docs/SIGUIENTE_TAREA.md de main. Continuar desde cierre T02, no desde main. Commits documentales de esta revisión no cuentan como avance de programación.

## Entrega T03 — 17 de noviembre de 2026
- Rama revisada: `feat/v0.1-t03-combate-y-enemigo`.
- SHA código: `973e989096a602814c34d7fff4241f9ee0ab14c3`; cierre: `b9da1e4ddaa3b138b41275961d2144c8de72a5a9`.
- Comparación con f436099: dos commits por delante, base preservada. Salud, armas, proyectiles, IA y restauración incorporados.
- Revisados instrucciones, contexto, plan, estado, comparación de archivos, salud/arma/proyectil y log T03. No se detectó bloqueo en esos archivos; revisión estática parcial, no validación integral del juego.
- Log publicado: núcleo 51/0, integración 52/0, gráfica 34/0 y regresión T02 34/0 + 22/0. Gráfica anterior a última guardia de objetivo fuera del árbol; headless repetido después según log. No se repitieron pruebas ni inspección de imágenes aquí. Windows y manejo humano pendientes.
- Encargo T04 actualizado en main: partir del cierre T03. Conservar revisión como referencia; los cambios de planificación no son avance de código.
- Objetivo añadido por usuario: avisar al completar V0.1 jugable/legible y preparar prueba descargable para laptop Windows en T06.

## Entrega T04 — 17 de noviembre de 2026
- Rama: `feat/v0.1-t04-habilidades`; código `c0a02d1e2bf9b78d78164d764918c34bdaeaf0a0`; cierre `37e1ee96e41023bb28965dcd87c90abdf0e706e8`.
- Comparación contra cierre T03: dos commits por delante, base conservada. Habilidades, efectos, entradas e indicadores incorporados.
- Revisión remota parcial: AGENTS, ESTADO, listado comparativo, pulse_ability.gd, arena.gd y T04-linux.log. Sin bloqueo detectado en lo revisado; no equivale a auditoría completa.
- Evidencia publicada: Q57/0, E78/0, integración42/0, gráfica49/0; regresiones T02 34/0+22/0 y T03 núcleo51/0, integración52/0, gráfica34/0. No se ejecutó Godot ni se reinspeccionaron imágenes aquí. Windows/manejo humano siguen pendientes.
- Encargo T05 publicado en main; partir de cierre T04. Este cambio documental no es una nueva entrega de código. V0.1 aún requiere T05/T06 y paquete para laptop.

## Entrega T05 — 17 de noviembre de 2026
- Rama revisada: `feat/v0.1-t05-ciclo-partida`; código `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`; cierre `036553c7a9bd364f2e6d865a3d17b3ce46254ab1`.
- Comparación con cierre T04: dos commits, base conservada. Revisados listado de cambios, ESTADO, arena.gd y T05-linux.log; revisión estática parcial sin bloqueo detectado en lo revisado.
- Evidencia publicada: estados51/0, gráfica145/0 y regresiones T02–T04 aprobadas. No ejecutadas nuevamente ni capturas reinspeccionadas aquí. Windows y manejo humano siguen pendientes.
- Encargo T06 publicado en main: validación, exportación y paquete descargable para laptop; distinguir candidato exportado de prueba Windows nativa. Cambios documentales de seguimiento no son avances de código.
