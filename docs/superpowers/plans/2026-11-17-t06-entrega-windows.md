# T06 — Candidato Windows y validación de entrega

**Objetivo:** preparar un ZIP Windows x86_64 autocontenido para prueba en laptop,
con exportación real e identificación verificable, conservando T01–T05.
**Especificación:** docs/SIGUIENTE_TAREA.md leído de main `a19f7d0`.
**Base:** `036553c7a9bd364f2e6d865a3d17b3ce46254ab1`.
**Rama:** `feat/v0.1-t06-entrega-windows`; sin merge ni force push.

## Decisiones de ejecución

- Godot 4.6.3 estándar/GDScript, Compatibility. Plantillas oficiales 4.6.3,
  verificadas contra SHA512 publicado; instalar solo Windows release x86_64.
- Preset versionado con exportación de recursos del juego y exclusión de tests.
  EXE y PCK externos, LEEME español, licencias, VERSION.json y SHA256SUMS.txt.
- Script Python estándar para exportar desde `git archive` del SHA indicado,
  generar manifiesto/ZIP y verificar extracción limpia, nombres y hashes.
  Binarios y cachés solo bajo builds/ o /tmp; no se añaden a Git.
- Repetir suites headless y gráficas en copias limpias mediante agentes con
  directorios propios. No modificar mecánicas si no aparece un fallo real.
- Este entorno es Linux y no tiene Windows nativo. La exportación no equivale a
  ejecución Windows. No usar Wine para acreditar ese pendiente.
- Intentar release preliminar ligada al SHA exportado. Si la API impide publicar,
  conservar ZIP y checksum con enlace local descargable y registrar el bloqueo
  exacto; no presentar un enlace de fuentes como descarga del ejecutable.

## Tareas y comprobaciones

- [x] Leer encargo/continuidad y crear rama desde base exacta sin sustituir ESTADO.
- [x] Copia limpia: importar, ejecutar T02/núcleo/T03/Q/E/T04/estados y arranque120.
- [x] Copia limpia: ventana T02/T03/T04/T05 y seis capturas en ambos tamaños.
- [x] Preset Windows release x86_64 y script de paquete; guía de usuario/licencias.
- [x] Commit de código/configuración; exportar ese SHA con plantillas verificadas.
- [x] Revisar PE/PCK, exclusión de tests, ZIP/listado/extracción/hashes y manifiesto.
- [x] Revisión independiente de entrega; sin hallazgos.
- [x] Intentar publicación de ZIP; bloqueada por API Forbidden antes de adjuntar.
- [x] README/ESTADO/REVISIONES/encargo y evidencia; commit cierre y push sin merge.
- [ ] Completar publicación estable y descarga remota/hash tras desbloquear API.
- [ ] Ejecutar candidato en Windows nativo y validar manejo humano en laptop.

## Foco de revisión

- Paquete incompleto: EXE/PCK juntos y sin rutas absolutas ni archivos de pruebas.
- SHA ambiguo: VERSION identifica el commit exportado, preset y versión exacta.
- ZIP corrupto o manipulado: verificación CRC y SHA256 tras extraer a carpeta vacía.
- Laptop: instrucciones de extracción, controles, tamaños y reporte de error claras.
- Alcance: distinguir Linux, inspección visual, exportación, Windows nativo y humano.

## Registro

- Lectura inicial de releases con `gh release list`: API GraphQL `Forbidden`.
  Se continuará con el paquete y se intentará publicar el artefacto concreto.
- Código exportado `e40276a5cb769e53794cd1f64832796772ec060f`. Lógica365/0,
  gráfica fuentes250/0; PCK final Linux145/0. ZIP íntegro/hash identificado en ESTADO.
- Creación concreta de release: consulta HEAD a API GitHub `Forbidden`, salida1,
  sin tag nuevo. Enlace local entregado en chat; no se inventa URL estable.
- T06 cierra como candidato parcial. Windows nativo y usuario siguen pendientes;
  exportación y carga de PCK con Godot Linux no equivalen a ejecutar EXE Windows.
