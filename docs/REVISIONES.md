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

## Entrega de programación T01/T02 — 16 de noviembre de 2026
- T01: código `dba0564`, rama publicada `feat/v0.1-t01-proyecto-ejecutable`,
  punta sincronizada con documentos remotos `35954f2`. Conserva la evidencia original.
- T02: código `66815e5f1d9ccd899baea84f76bce0ef9f5301b9`, rama
  `feat/v0.1-t02-dragon-y-camara`; el cierre documental es posterior al código.
- Revisión independiente local: importación y suite headless en copia temporal
  sin caché con Godot 4.6.3, salida 0; 34 comprobaciones, 0 fallos. Inspección de
  escena, controlador, Input Map, límites, cámara y capturas de inicio/esquina.
- Implementador: prueba gráfica automatizada X11/Compatibility, 22 comprobaciones
  y 0 fallos. Evidencia y comandos en `docs/ESTADO.md` y `docs/validacion/`.
- No se declara revisión remota de GitHub, PR creada ni GitHub Actions ejecutado.
  `gh` devuelve `Forbidden` en la API; el transporte Git sí permite publicar ramas.
- **Windows pendiente**: no se exportó ni ejecutó un `.exe`. Manejo humano
  prolongado y GPU física pendientes. Siguiente incremento: T03.

## Entrega de programación T03
- Base exacta `f436099969a70df498ee46c92b3fba60d30c6ba9`; nueva rama
  `feat/v0.1-t03-combate-y-enemigo`, sin merge ni force push.
- Código `973e989096a602814c34d7fff4241f9ee0ab14c3`; cierre documental posterior.
  Encargo recuperado de main en `54dba3b`, conservando código/estado T02.
- Revisión independiente en copia sin caché: importación/arranque salida 0,
  núcleo 51/0, integración entonces 51/0, regresión T02 34/0. Detectó un objetivo
  vivo fuera del árbol aceptado por la IA: se reprodujo en una prueba persistente,
  se añadió validación `is_inside_tree()` y el implementador repitió las suites.
- Resultado final del implementador: núcleo 51/0, integración 52/0, T02 34/0;
  ventana T03 34/0 y regresión gráfica T02 22/0. Sin errores de scripts; aviso
  V-Sync del driver virtual documentado. Tres capturas de combate inspeccionadas.
- Evidencia en `docs/validacion/T03-linux.log` y tres imágenes T03; comandos,
  decisiones y defectos corregidos en ESTADO.md. Sin revisión remota repetida,
  PR ni CI nuevas. No se modificaron permisos para sortear el bloqueo API previo.
- **Windows pendiente**, junto a GPU física y manejo humano prolongado. Siguiente: T04.
