# Siguiente encargo — T06: validación y entrega para laptop

## Base y contexto
Crear rama descriptiva desde `036553c7a9bd364f2e6d865a3d17b3ce46254ab1` de `feat/v0.1-t05-ciclo-partida` (código T05 `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`). Conservar T01–T05; sin merge ni force push. Leer este documento de main sin reemplazar ESTADO reciente. Leer AGENTS y documentos obligatorios, README, scripts/escenas de arena y HUD, suites T02–T05 y docs/validacion/T05-linux.log. Mantener Godot 4.6.3 Compatibility y recursos propios.

## Trabajo concreto
1. Repetir importación y suites críticas T02–T05 desde copia limpia; registrar comandos, versión y resultados. Corregir fallos antes de empaquetar, sin ampliar mecánicas ni arte.
2. Preparar preset reproducible Windows x86_64 con plantillas de la misma versión. Excluir pruebas y archivos innecesarios del paquete. No versionar cachés, credenciales ni binarios grandes en Git.
3. Exportar realmente una versión release y crear ZIP autocontenido (exe y PCK si es externo), instrucciones LEEME en español y SHA256. Registrar SHA exacto del código exportado, comando, versión, archivos y tamaño. Comprobar integridad/listado y extracción limpia; no depender de rutas del desarrollador.
4. Ejecutar el paquete en Windows si existe entorno disponible: arranque, WASD/ratón, límites, básico/Q/E/recargas, victoria/derrota, bloqueo y tres reinicios con R/botón. Comprobar 1280×720 y 960×540, foco y teclas retenidas. Registrar sistema/GPU y evidencia real. Wine o exportación Linux no sustituyen ejecución Windows nativa.
5. Si no hay Windows, entregar el paquete como candidato para prueba, con pendiente explícito y guía breve para el usuario: descargar, extraer todo, abrir exe, controles, ganar/perder/reiniciar y cómo reportar error/captura. No bloquear la preparación por falta de Windows ni declarar T06 validada íntegramente.
6. Publicar un enlace descargable estable al ZIP, preferentemente mediante release preliminar ligada al SHA de la rama, sin merge. Verificar disponibilidad y hash del artefacto descargado cuando sea posible. Si permisos impiden adjuntarlo, conservar paquete/evidencia e informar el bloqueo exacto; un enlace al código fuente no equivale a ejecutable descargable.

## Aceptación y cierre
- Regresiones aprobadas y sin errores de importación; evidencia de exportación real y paquete completo, reproducible e identificado por SHA/hash.
- README y ESTADO distinguen: lógica Linux, revisión gráfica, exportación Windows, ejecución Windows nativa y manejo humano. No prometer rendimiento ni requisitos mínimos no medidos.
- Entrega breve con enlace ZIP, controles, limitaciones y lista para prueba en laptop. V0.1 puede quedar como candidato jugable mientras Windows/usuario estén pendientes; no inventar resultados.
- Actualizar ESTADO y continuidad; publicar rama, SHA código/cierre y URL del artefacto, sin merge. Si falla una prueba, el siguiente encargo es corregir ese fallo antes de V0.2.

## Revisión de base
T05 conserva cierre T04 y añade dos commits. Revisados remotamente listado de cambios, ESTADO, arena.gd y log: estados51/0, gráfica145/0 y regresiones publicadas sin fallos. Revisión estática parcial; no se ejecutó Godot ni se reinspeccionaron capturas en este seguimiento. Windows y manejo humano pendientes.
