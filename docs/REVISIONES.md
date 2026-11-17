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
