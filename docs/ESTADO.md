# Estado del proyecto

## Situación actual — 16 de noviembre de 2026 (America/Bogota)
T01 implementada y validada en Linux con Godot 4.6.3 estable. Existe un proyecto
ejecutable con una arena estática: suelo, iluminación y cámara aérea oblicua.
Todavía no hay demo jugable: dragón, controles, combate y ciclo de partida siguen
pendientes. Esta entrega implementa únicamente la primera tarea solicitada.

## Lectura
- AGENTS.md: instrucciones para agentes.
- docs/CONTEXTO_IA.md: objetivo, fuentes y límites de conocimiento.
- docs/PLAN_INICIAL.md: visión general.
- docs/IMPLEMENTACION.md: tareas y aceptación.

## Seguimiento V0.1
| Tarea | Estado | Evidencia |
| --- | --- | --- |
| T01 Proyecto ejecutable | Terminada (Linux) | Importación y arranque headless con salida 0; renderizado Compatibility e imagen inspeccionada, ver registro abajo |
| T02 Dragón y cámara | Pendiente | Sin ejecución registrada |
| T03 Combate y enemigo | Pendiente | Sin ejecución registrada |
| T04 Habilidades | Pendiente | Sin ejecución registrada |
| T05 Ciclo e interfaz | Pendiente | Sin ejecución registrada |
| T06 Validación y entrega | Pendiente | Sin ejecución registrada |

## Próxima acción
Implementar **T02 — Dragón y cámara**, tras leer los documentos y verificar el
árbol real. Reutilizar `game/scenes/arena.tscn`: añadir representación provisional
propia del dragón, movimiento XZ normalizado, orientación, límites y cámara de
seguimiento. Registrar Input Map y controles provisionales. No empezar todavía
combate ni servicios online. Comprobar visualmente movimiento y cámara, además de
la importación con la versión fijada.

## Registro del incremento T01

### Cambios y archivos
- Rama de trabajo: `feat/v0.1-t01-proyecto-ejecutable`, creada desde
  `e357b74c210823b61db522fa0d3a1d575e67ae0f` después de incorporar por avance rápido
  los documentos de `origin/main`. El checkout estaba limpio antes de los cambios.
- `game/project.godot`: escena principal `res://scenes/arena.tscn`, viewport
  1280×720 y renderizador `gl_compatibility` explícito.
- `game/scenes/arena.tscn`: raíz `Arena`, suelo `BoxMesh`, `WorldEnvironment`,
  luz direccional y `Camera3D` activa. Escena declarativa sin lógica de juego.
- `.gitignore`: excluye `.godot/`, temporales y exportaciones locales en `builds/`.
- `README.md`: requisitos, versión exacta, importación y ejecución Linux/Windows,
  comprobaciones y procedencia de recursos.
- `docs/superpowers/plans/2026-11-16-t01-proyecto-ejecutable.md`: alcance y plan del incremento.
- `docs/validacion/T01-arena-linux.png`: fotograma del renderizado final, revisado
  visualmente; plataforma completa dentro del encuadre, iluminación y fondo visibles.

### Decisiones provisionales
- **Motor fijado:** Godot **4.6.3 estable**, edición estándar/GDScript, versión
  ejecutada `4.6.3.stable.official.7d41c59c4`. Disponible en el entorno y con
  [publicación oficial](https://github.com/godotengine/godot/releases/tag/4.6.3-stable)
  accesible. Importa y renderiza el proyecto con Compatibility; no requiere .NET.
- Suelo de 24×24 unidades con superficie en Y=0, cámara ortográfica fija y
  materiales simples propios. Son decisiones de prototipo, no parámetros del juego original.
- No se añadieron scripts GDScript vacíos, directorios de datos sin uso ni dependencias.
  Incorporarlos cuando T02 y las tareas siguientes necesiten comportamiento o balance.
- Geometría y materiales creados para el repositorio mediante primitivas de Godot;
  sin arte, código ni servidores del juego original, ni recursos externos.

### Comprobaciones realizadas
Comandos ejecutados desde `/workspace/The-Dragons-and-titans` con Godot 4.6.3:

| Comprobación | Comando real | Resultado |
| --- | --- | --- |
| Versión | `godot --version` | `4.6.3.stable.official.7d41c59c4` |
| Importación | `godot --headless --path game --import` | Salida 0, sin errores; repetida después del ajuste final de iluminación |
| Escena principal | `godot --headless --path game --quit-after 120` | Salida 0, 120 iteraciones sin errores; no implica revisión de imagen |
| Renderizado final | `DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --disable-vsync --quit-after 2 --write-movie /tmp/dragons-t01/final.png` | Salida 0; OpenGL 4.5, Compatibility, Mesa llvmpipe; 2 fotogramas de 1280×720, imagen inspeccionada |
| Higiene | `git diff --check` y `git check-ignore -v game/.godot/` | Sin errores de espacios; caché excluida por `.gitignore` |

Antes de ejecutar se prepararon `XDG_CACHE_HOME`, `XDG_DATA_HOME` y
`XDG_CONFIG_HOME` en `/tmp/dragons-t01/`, como explica el README, para evitar
directorios de usuario no escribibles y el aviso de caché de Fontconfig.
El renderizado se realizó con un Xorg temporal y driver `dummy` en `:93`, porque
no había herramientas accesibles para iniciar el escritorio compartido. Se usó
la captura `final00000001.png` como evidencia. También se ejecutó una primera
prueba gráfica de 120 fotogramas, antes del ajuste final de luz ambiental.

El driver virtual emitió un aviso de V-Sync no soportado incluso con
`--disable-vsync`; no hubo errores de carga de escena ni recursos. La documentación
oficial del motor se consultó para usar luz ambiental de color (sin recurso Sky)
y desactivar reflexiones del cielo. No existen scripts ni una suite de lógica de
juego en T01; no se presentan estas comprobaciones como pruebas de combate.

Revisión independiente del incremento: aprobada sin hallazgos. El revisor repitió
la importación y las 120 iteraciones en una copia temporal sin caché: ambas con
salida 0 y sin errores. También verificó que la captura guardada coincide con el
fotograma final del renderizado Compatibility.

## Limitaciones conocidas
- **Windows pendiente:** no se ejecutó el editor ni se exportó/probó un `.exe` en
  Windows. Los comandos de Windows están documentados, no verificados en esta máquina Linux.
- Validación visual limitada a una escena estática y renderizado por software en
  Linux. No se ha probado GPU física, interacción con el escritorio compartido,
  movimiento, controles, combate, daño, recargas ni reinicios (aún no implementados).
- Chat compartido no accesible durante la preparación inicial; no se presupone su contenido.
- Wiki pendiente de investigar y contrastar.
- Cinco capturas de referencia del usuario pendientes de incorporar al repositorio;
  la imagen de validación de T01 es propia y no sustituye esas referencias.

## Formato de actualización
Por cada incremento registrar: tarea, cambio, archivos, comprobaciones y resultados, limitaciones, decisiones provisionales y siguiente paso. Actualizar las filas de seguimiento sin borrar limitaciones aún vigentes.
