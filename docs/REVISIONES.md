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

## Entrega de programación T04 — 17 de noviembre de 2026
- Base exacta `b9da1e4ddaa3b138b41275961d2144c8de72a5a9`; nueva rama
  `feat/v0.1-t04-habilidades`, sin merge ni force push. Encargo de main `27918fc`.
- Código `c0a02d1e2bf9b78d78164d764918c34bdaeaf0a0`; cierre documental posterior.
- Revisión independiente en copia temporal sin caché, Godot4.6.3: importación y
  arranque limpios; Q57/0, E78/0, integración42/0, T02 34/0, núcleo51/0 y T03 52/0.
  Sin hallazgos de aceptación en juego/input/recargas/selección/limpieza. No gráficos repetidos por el revisor.
- Implementador: gráficas T04 49/0, T02 22/0 y T03 34/0. Inspección de dos
  capturas Q/E y HUD; transcripción en `docs/validacion/T04-linux.log`.
- Primera gráfica T04: 49/1 por leer HUD antes de `_process`. Sincronizado el
  montaje con `frame_post_draw`, manteniendo y reforzando la comprobación de segundos.
  Repetición sin errores de script; solo aviso V-Sync del driver virtual.
- No CI ni PR nuevas ni cambios de permisos. **Windows, GPU física y manejo humano
  prolongado pendientes**. V0.1 aún requiere T05/T06 y entrega para laptop.

## Entrega de programación T05 — 17 de noviembre de 2026
- Base exacta `37e1ee96e41023bb28965dcd87c90abdf0e706e8`, conservando T01–T04.
  Rama `feat/v0.1-t05-ciclo-partida`, sin merge ni force push. Encargo de main
  `a5ea2f1cfa392625bcc7177039be078ce6f587f4` recuperado sin sustituir ESTADO.
- Código `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`; cierre documental posterior.
- Revisión independiente local, código e integración en copia sin caché:
  importación/arranque limpios, estados51/0, T02 34/0, núcleo51/0, T03 52/0,
  Q57/0, E78/0 y T04 42/0. Sin hallazgos de aceptación. No gráficos repetidos
  por el revisor ni revisión remota/CI nuevas.
- Implementador: ventana T05 145/0 en tamaños nativos 1280×720 y 960×540;
  regresiones gráficas T02 22/0, T03 34/0 y T04 49/0. Seis capturas inspeccionadas,
  legibles y sin paneles sobre el jugador; estado, foco y botón inequívocos.
  La automatización alternó victoria/derrota y tres reinicios por resolución
  mediante R/Enter/clic; también controles retenidos y bloqueo completo al final.
- Montajes legacy T03/T04 adaptados para pausar solo resolución de partida,
  conservando todas sus aserciones. T05 ejercita el cierre real. Se corrigieron
  sincronización del montaje, captura de ventana nativa y texto de salud con
  resolución pausada; detalle y comandos en ESTADO.md y `T05-linux.log`.
- Sin permisos nuevos ni PR/merge. **Windows, GPU física y manejo humano
  prolongado pendientes**. Siguiente T06: validación integral y entrega comprobable
  para laptop; T05 no acredita el paquete ni V0.1 completa.
