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

## Entrega candidata T06 — 17 de noviembre de 2026
- Base `036553c7a9bd364f2e6d865a3d17b3ce46254ab1`; rama publicada
  `feat/v0.1-t06-entrega-windows`, sin merge ni force push. Encargo main `a19f7d0`.
  Código/configuración exportados `e40276a5cb769e53794cd1f64832796772ec060f`;
  cierre documental posterior. No cambian scripts/escenas/project.godot de T01–T05.
- Agentes de validación: copias limpias git archive, importación/arranque limpios,
  lógica365/0 y gráfica de fuentes250/0. Godot4.6.3 Compatibility en Linux.
- Exportación real release Windows x86_64 con plantilla oficial4.6.3 verificada
  contra SHA512. ZIP35 977 332bytes; SHA256
  `aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`.
- Revisión independiente de preset/script/guía/paquete: sin hallazgos. Extracción
  propia, CRC/hashes/manifest correctos; PE32+ AMD64 idéntico a plantilla; PCK37
  entradas con rangos y MD5 correctos, sin tests ni archivos innecesarios.
- Prueba adicional del PCK exportado con Godot Linux: arranque120 y ventana
  T05 145/0 en ambos tamaños. Seis capturas inspeccionadas; hash PCK intacto.
  **No se ejecutó el EXE ni Windows nativo**; no hubo manejo humano/laptop.
- Publicación Git aprobada; release preliminar bloqueada por API `Forbidden`
  en consulta HEAD previa a crear/adjuntar. No tag nuevo ni URL remota de ZIP
  verificados. Artefacto/sidecar conservados en builds/t06 y entregados por chat;
  sin binarios grandes en Git ni cambios de permisos/red para eludir el bloqueo.
- **T06 parcial:** Windows nativo, laptop, release alojada y descarga remota/hash
  pendientes. Corregir fallos de esa prueba antes de V0.2; no declarar V0.1 aceptada.

## Continuidad T06 — 17 de noviembre de 2026
- Encargo main `c33bad1`; misma rama T06 desde `d1cc1ac`. Cambios de documentación
  únicamente; e40276a y ZIP originales conservados. Sin merge ni reexportación.
- Verificación independiente del candidato: tamaño/SHA256/sidecar exactos, CRC 6/6,
  VERSION y cinco hashes internos correctos; T01–T05 intactas. Sin hallazgos.
  Las suites previas no se repitieron ni se acreditó ejecución nueva de Godot.
- Una única consulta API `gh api .../releases/tags/v0.1-rc1-t06`: salida 1,
  `Get "https://api.github.com/repos/JoseB-H/The-Dragons-and-titans/releases/tags/v0.1-rc1-t06": Forbidden`.
  Sin nuevos intentos de adjuntar ni URL inventada; release/descarga remota bloqueadas.
- Registro Windows/laptop preparado con campos pendientes y guía vigente. Sin
  Windows accesible ni informe nativo incorporado: no se declara prueba ejecutada
  o V0.1 aceptada. Esperar resultados reales y corregir fallos antes de V0.2.

## Entrega V0.2 T01 — 17 de noviembre de 2026
- Usuario reportó prueba del prototipo en laptop y valoración «decente». No indicó
  OS/GPU, SHA o resultados individuales: no se marcan comprobaciones como aprobadas.
  La misma petición autoriza V0.2 y prevalece sobre el encargo anterior de main.
- Base `b42ceef776ce81b6af704466afb842f4959acd80`, rama nueva
  `feat/v0.2-t01-seleccion-dragones`, sin merge ni force push. Código
  `bc22940449b532d53789b29720237549a2de835c`; cierre documental posterior.
  Rama/candidato V0.1 conservados; ZIP e40276a y sidecar con hash original intacto.
- Implementador: importación/arranque limpios, perfiles 93/0, selector 64/0,
  partida 46/0; regresiones headless 365/0. Ventana V0.2 777/0 en ambos tamaños,
  dieciséis resultados y doce reinicios; regresiones gráficas 250/0.
- Revisión independiente en copia de fuentes sin caché: importación y tres
  suites nuevas 93/0, 64/0, 46/0. Revisión estática final de producción y pruebas
  aprobada sin hallazgos. Datos separados, Cobre preservado, materiales/estado
  aislados y navegación/reinicio por perfil comprobados.
- Corregidos dos fallos reproducidos con cobertura: señal inicial transitoria de
  salud al aplicar Jade y foco diferido sobre un botón retirado al navegar rápido.
  Suites finales sin errores. No se retiraron aserciones ni se cambiaron tests heredados.
- Revisión visual independiente de las dieciséis capturas nativas: sin hallazgos,
  1280×720/960×540 correctos, selector/HUD/dragones/finales y botones legibles.
  No ejecutó gráficos; inspeccionó imágenes de automatización Linux.
- Evidencia en `docs/validacion/V02-T01-*` y capturas V02. No se exportó ni probó
  V0.2 en Windows; la valoración general anterior no se atribuye al selector nuevo.
  Selección de arma y ampliaciones quedan para otro incremento autorizado.
