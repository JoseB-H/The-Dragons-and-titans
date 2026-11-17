# Estado del proyecto

## Situación actual — 16 de noviembre de 2026 (America/Bogota)
T01 conservada y sincronizada; **T02 implementada y comprobada en Linux** con
Godot 4.6.3 estable. La arena incluye dragón provisional propio, movimiento WASD,
orientación hacia el cursor, límites y cámara de seguimiento. La siguiente tarea
es T03: todavía no hay combate ni ciclo de victoria/derrota/reinicio.
La validación nativa de Windows sigue **pendiente**.

## Lectura
- AGENTS.md: instrucciones para agentes.
- docs/CONTEXTO_IA.md: objetivo, fuentes y límites de conocimiento.
- docs/PLAN_INICIAL.md: visión general.
- docs/IMPLEMENTACION.md: tareas y aceptación.

## Seguimiento V0.1
| Tarea | Estado | Evidencia |
| --- | --- | --- |
| T01 Proyecto ejecutable | Terminada (Linux) | Importación y arranque headless con salida 0; renderizado Compatibility e imagen inspeccionada, ver registro abajo |
| T02 Dragón y cámara | Terminada (Linux) | 34 comprobaciones headless y 22 de ventana; capturas de inicio/esquina inspeccionadas |
| T03 Combate y enemigo | Pendiente | Sin ejecución registrada |
| T04 Habilidades | Pendiente | Sin ejecución registrada |
| T05 Ciclo e interfaz | Pendiente | Sin ejecución registrada |
| T06 Validación y entrega | Pendiente | Sin ejecución registrada |

## Próxima acción
Implementar **T03 — Combate y enemigo**, tras leer los documentos y verificar el
árbol real. Reutilizar el dragón y la cámara de T02. Añadir salud, facciones,
proyectil básico con recarga y enemigo que persigue/ataca según IMPLEMENTACION.md.
Probar daño único, salud no negativa, muerte y restauración de entidades. No
implementar aún habilidades ni servicios online. Windows continúa pendiente.

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

## Registro del incremento T02

### Referencias y conservación
- T01 conservada en `dba0564` y publicada en
  `feat/v0.1-t01-proyecto-ejecutable`; punta sincronizada `35954f2`, que incorpora
  los documentos remotos recibidos sin modificar `main` ni forzar pushes.
- Rama T02: `feat/v0.1-t02-dragon-y-camara`, basada en `35954f2`.
- Commit de código T02: `66815e5f1d9ccd899baea84f76bce0ef9f5301b9`.
  La documentación de cierre se conserva en un commit posterior de la misma rama.
- La creación de PR mediante `gh` no fue posible: la API de GitHub devolvió
  `Forbidden`, tanto al leer como al crear. El acceso Git y el push de T01 sí
  funcionaron; no se solicitaron ni copiaron credenciales.

### Archivos y decisiones provisionales
- `game/scenes/dragon_visual.tscn`: cuerpo, cabeza/hocico -Z, alas con membranas
  CSG, cola, patas, cuernos y ojos. Geometría y materiales propios sin descargas.
  Comprobación de vértices: radio XZ máximo 1.95; mínimo Y local −0.44.
- `game/scenes/dragon.tscn`: controlador, hijo `Facing` y cámara de T01. Solo
  `Facing` gira: cámara y movimiento no cambian con el apuntado.
- `game/scripts/dragon_controller.gd`: movimiento en física, diagonal normalizada,
  límites y apuntado. Velocidad 6 unidades/s, altura 1.5, semitamaño 12×12 y
  margen 2 exportados. Centro limitado a [−10,10] en X/Z, incluyendo esquinas.
- `game/project.godot`: Input Map físico WASD e interpolación física activada.
- `game/scenes/arena.tscn`: conserva suelo/luz/entorno, instancia el dragón y
  muestra controles visibles; solo anuncia movimiento y orientación.
- Cámara: conserva posición relativa (18,22,18) y ángulo de T01; tamaño
  ortográfico 18 para legibilidad. Hereda traslación sin retardo. W/S se mueve
  arriba/abajo en pantalla y A/D a izquierda/derecha, independientemente del hocico.
- El cursor se proyecta al plano de vuelo Y=1.5. Un rayo sin intersección, cursor
  fuera del viewport o punto a menos de 0.01 unidades conserva el giro anterior;
  el dragón solo gira alrededor de Y. No se implementaron ataques, Q/E ni reinicio.
- `game/tests/test_t02.gd` y `test_t02_window.gd`: integración real sin mocks ni
  plugins externos. Los UID de GDScript generados por Godot están versionados.
- `README.md`, este estado y el encargo: controles, convenciones y continuidad.
- Evidencia propia: `docs/validacion/T02-inicio-linux.png`,
  `T02-esquina-linux.png` y `T02-linux.log`.

### Pruebas realizadas con Godot 4.6.3 en Linux
Directorio: `/workspace/The-Dragons-and-titans`. Se usaron los directorios XDG
escribibles del README y Xorg temporal `:93` con driver `dummy` para la ventana.

| Prueba | Comando real | Resultado final |
| --- | --- | --- |
| Importación | `godot --headless --path game --import` | Salida 0; sin errores de scripts ni recursos |
| Integración | `godot --headless --path game --script res://tests/test_t02.gd` | Salida 0; 34 comprobaciones, 0 fallos |
| Escena principal | `godot --headless --path game --quit-after 120` | Salida 0; sin errores |
| Ventana | `DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/test_t02_window.gd -- --output-dir=/tmp/dragons-t02` | Salida 0; 22 comprobaciones, 0 fallos; OpenGL 4.5 Compatibility, Mesa llvmpipe |
| Higiene | `git diff --check` | Sin errores de espacios; `.godot/` continúa excluido |

La suite headless prueba desplazamiento axial/diagonal, altura, teclas opuestas,
ausencia de deriva, cuatro esquinas, offset/encuadre de cámara, orientación sin
inclinación y casos degenerados. En headless no hay cursor OS: las coordenadas
se pasan al mismo método de apuntado usado en física. La prueba de ventana sí
lee el cursor real y recorre las cuatro esquinas con eventos de teclas físicas a
través de Input Map durante 360 ticks por tecla. Comprueba encuadre interpolado
y offset por fotograma. Las dos capturas se inspeccionaron: silueta reconocible,
controles legibles y personaje centrado tanto al inicio como en la esquina.

Las primeras ejecuciones detectaron errores del montaje de pruebas: proyección
interpolada consultada fuera de física, cursor inexistente en headless y duración
insuficiente para cruzar la arena. Se corrigieron esos supuestos y se repitieron
las pruebas, sin desactivar comprobaciones ni alterar el movimiento para pasarlas.
El único aviso gráfico final fue V-Sync no soportado por el driver virtual.
La importación y las 34 comprobaciones también pasaron en una copia temporal
sin caché durante la revisión independiente.
La revisión final aprobó T02 sin hallazgos funcionales ni bloqueantes. Se
actualizaron las casillas de avance del plan señaladas durante la revisión.

## Limitaciones conocidas
- **Windows pendiente:** no se ejecutó el editor ni se exportó/probó un `.exe` en
  Windows. Los comandos de Windows están documentados, no verificados en esta máquina Linux.
- Validación gráfica mediante renderizado por software y entrada automatizada en
  Linux, con inspección de capturas. No hubo sesión humana prolongada de manejo,
  prueba de GPU física ni interacción con el escritorio compartido. El seguimiento
  se verificó por fotograma; la sensación de manejo requiere evaluación del usuario.
- Combate, daño, recargas, muerte y reinicio siguen sin implementar y sin probar.
- Chat compartido no accesible durante la preparación inicial; no se presupone su contenido.
- Wiki pendiente de investigar y contrastar.
- Cinco capturas de referencia del usuario pendientes de incorporar al repositorio;
  la imagen de validación de T01 es propia y no sustituye esas referencias.

## Formato de actualización
Por cada incremento registrar: tarea, cambio, archivos, comprobaciones y resultados, limitaciones, decisiones provisionales y siguiente paso. Actualizar las filas de seguimiento sin borrar limitaciones aún vigentes.
