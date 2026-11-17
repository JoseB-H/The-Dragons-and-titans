# Continuidad T06 — publicación y prueba nativa pendientes

Encargo leído de main `c33bad1b072a7138d06f86a2c6cc38279893b003`.
Se conserva `feat/v0.1-t06-entrega-windows` desde d1cc1ac y el candidato exportado
`e40276a5cb769e53794cd1f64832796772ec060f`, sin merge ni reexportación.
ZIP original de 35 977 332 bytes, SHA256
`aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`,
sidecar/CRC/hashes internos comprobados de nuevo. No hay un fallo nuevo reproducido.

La única consulta API de esta continuación devuelve Forbidden: release y descarga
remota/hash siguen pendientes. No reiterar intentos mientras el acceso siga igual.
El ZIP local sigue en builds/t06 y se facilita mediante enlace de archivo del chat.
Windows nativo/laptop: pendiente de informe real; usar LEEME y registrar resultados
en docs/validacion/T06-prueba-windows.md. Su matriz está pendiente, no ejecutada.
Corregir fallos antes de V0.2; no atribuir pruebas anteriores a un candidato nuevo.
Ver ESTADO.md y docs/validacion/T06-continuidad.log para evidencia.

## Encargo original de main

### Completar entrega T06

## Base
Continuar desde feat/v0.1-t06-entrega-windows; conservar todos sus cambios y leer su ESTADO, README, AGENTS y documentos obligatorios. Código exportado e40276a5cb769e53794cd1f64832796772ec060f. No volver a partir de T05 ni hacer merge, force push o ampliar V0.2.

## Trabajo
1. Conservar el ZIP y sidecar existentes. Publicar una release preliminar asociada al SHA exportado cuando el acceso API lo permita; si sigue Forbidden, registrar el error exacto sin reiterar intentos ni inventar URL. No sustituir el paquete por fuentes.
2. Verificar descarga remota, tamaño 35977332 bytes y SHA256 aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda. Registrar URL estable en README y ESTADO.
3. Usar docs/entrega/LEEME-WINDOWS.txt para prueba Windows nativa: arranque, movimiento/apuntado, básico/Q/E, victoria/derrota, bloqueo y tres reinicios por botón/R; tamaños 1280×720 y 960×540. Registrar Windows/GPU, resultados y errores reales. Sin Windows disponible, mantener pendiente y facilitar prueba humana del candidato.
4. Corregir fallos reproducidos antes de V0.2; si cambia el código, exportar e identificar un candidato nuevo y su hash. No reexportar sin motivo ni atribuirle pruebas anteriores.

## Aceptación
Enlace al ZIP descargable comprobado y registro de prueba Windows/laptop, o bloqueos explícitos. Exportación y PCK ejecutado en Linux no acreditan Windows. Actualizar ESTADO con rama y SHA, sin declarar aceptación integral mientras falte la prueba humana/nativa.

## Revisión remota
Comparación contra 036553c: base preservada, sin cambios listados en lógica/escenas. ESTADO y reporte T06-paquete.json publicados concuerdan con exportación y hashes reportados. Pruebas publicadas: lógica365/0, gráfica fuentes250/0 y PCK Linux145/0. No repetidas aquí; ZIP y capturas no inspeccionados nuevamente. Publicación estable bloqueada y Windows nativo/manejo humano pendientes.
