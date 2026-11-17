# Estado del proyecto

## Situación actual — entrega T03
**T03 implementada y comprobada en Linux**, conservando T01/T02 y Godot 4.6.3
Compatibility. Hay salud, facciones, ataque básico con recarga, proyectiles con
barrido físico, enemigo que persigue/ataca y restauración completa con R.
La siguiente tarea es T04 (dos habilidades); la interfaz completa de fin de partida
y sus estados siguen siendo T05. No se implementaron Q/E ni servicios online.
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
| T03 Combate y enemigo | Terminada (Linux) | Núcleo 51/0, integración 52/0, gráfica T03 34/0; regresión T02 34/0 y 22/0; importación/arranque sin errores |
| T04 Habilidades | Pendiente | Sin ejecución registrada |
| T05 Ciclo e interfaz | Pendiente | Sin ejecución registrada |
| T06 Validación y entrega | Pendiente | Sin ejecución registrada |

## Próxima acción
Implementar **T04 — Dos habilidades**, tras leer los documentos y verificar la
rama y el código reales. Reutilizar salud, facciones, armas y limpieza de T03:
Q proyectil potente y E pulso de área con recargas propias y datos configurables,
según IMPLEMENTACION.md. Probar daño válido, bloqueo durante recarga y efectos
temporales sin acumulación, manteniendo la regresión T02/T03. Windows continúa pendiente.

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

## Registro del incremento T03

### Base, rama y conservación
- Base exacta: `f436099969a70df498ee46c92b3fba60d30c6ba9`, entrega T02 publicada.
- Nueva rama: `feat/v0.1-t03-combate-y-enemigo`.
- Código de T03: `973e989096a602814c34d7fff4241f9ee0ab14c3`; el cierre documental es un commit posterior.
- Encargo leído y recuperado mediante `git show origin/main:docs/SIGUIENTE_TAREA.md`,
  desde `main` en `54dba3bf4aebca80343175faf6c5cf962d3cb504`. No se sustituyó el
  ESTADO de T02 ni se hizo merge, rebase o force push. T02 permanece en su rama.
- No se modificaron permisos ni se exigió PR: la entrega anterior registró
  `Forbidden` en la API de GitHub; este incremento se publica mediante Git.

### Archivos y decisiones provisionales
- `game/scripts/combat_actor.gd`: raíz CharacterBody3D compartida para salud y
  facciones; salud limitada a [0,máxima], máximo mínimo 1, rechazo de daño negativo,
  cero, aliado o posterior a muerte. Señal de muerte única incluso con daño
  reentrante desde una señal. Cambiar el máximo no cura ni revive.
- `game/scripts/weapon.gd`: parámetros exportados y recarga física. Solo dispara
  con propietario vivo, dirección XZ válida y contenedor activo.
- `game/scripts/projectile.gd` y `game/scenes/projectile.tscn`: esfera luminosa
  propia y rayquery continuo del tramo físico. El primer barrido incluye actor→hocico;
  excluye RID del emisor, aliados y muertos, y daña solo al primer hostil válido.
  Vida restante limita el último desplazamiento; impacto o caducidad eliminan el nodo.
- `game/scripts/enemy_controller.gd` y `game/scenes/enemy.tscn`: enemigo cian propio,
  objetivo jugador, persecución XZ sin sobrepasar alcance, altura/límites y recarga;
  sin acciones si él o su objetivo son muertos, inválidos o aliados.
- `game/scripts/dragon_controller.gd`/`game/scenes/dragon.tscn`: conservan
  movimiento, Facing y cámara T02; incorporan salud, collider central y arma.
  Clic izquierdo mantenido dispara hacia -Z de Facing; un jugador muerto no actúa.
- `game/scripts/arena.gd`, `arena.tscn`, `project.godot`: composición, contenedor
  Projectiles, HUD mínimo de salud/recarga y acción física R para recargar escena.
  R restablece actores, posiciones, orientación, vida, recargas y objetivo, sin
  conservar proyectiles ni conexiones del árbol anterior. Sin pantalla final T05.
- Balance exportado: salud jugador/enemigo 100/80, daño 20/10, recarga 0.4/1 s;
  proyectil 28 unidades/s y 2 s de vida, origen visual a 1.9 unidades. IA velocidad
  3 y alcance 7. Colisión central esférica de radio 0.8; alas/cola cosméticas.
  Los actores pueden cruzarse: sus límites se controlan por posición, no por
  bloqueo mutuo. Todos estos datos son provisionales, no hechos del juego original.
- `game/tests/test_combat_core.gd`, `test_t03.gd`, `test_t03_window.gd`: pruebas
  reales sin mocks; UID versionados. Las suites T02 solo añaden una pausa de la IA
  en su montaje; no se retiró ni relajó ninguna de sus aserciones de comportamiento.
- README actualizado y frase obsoleta de versión pendiente corregida en CONTEXTO_IA.
  Geometría, materiales y capturas propios, sin arte original ni descargas externas.

### Comprobaciones y resultados
Godot `4.6.3.stable.official.7d41c59c4`, desde `/workspace/The-Dragons-and-titans`.
Directorios XDG escribibles en `/tmp/dragons-t03/{cache,data,config}`; para gráficos,
Xorg temporal `:93` con driver dummy y OpenGL 4.5 Compatibility, Mesa llvmpipe.

| Prueba | Comando real | Resultado final |
| --- | --- | --- |
| Importación | `godot --headless --path game --import` | Salida 0, sin errores de scripts/recursos |
| Núcleo | `godot --headless --path game --script res://tests/test_combat_core.gd` | Salida 0; 51 comprobaciones, 0 fallos |
| Integración | `godot --headless --path game --script res://tests/test_t03.gd` | Salida 0; 52 comprobaciones, 0 fallos |
| Regresión T02 | `godot --headless --path game --script res://tests/test_t02.gd` | Salida 0; 34 comprobaciones, 0 fallos |
| Arranque | `godot --headless --path game --quit-after 120` | Salida 0, sin errores |
| Regresión gráfica | `DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/test_t02_window.gd -- --output-dir=/tmp/dragons-t03/graphics` | Salida 0; 22 comprobaciones, 0 fallos |
| Combate gráfico | `DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/test_t03_window.gd -- --output-dir=/tmp/dragons-t03/graphics` | Salida 0; 34 comprobaciones, 0 fallos |
| Higiene | `git diff --check`; revisión de historial desde `f436099` | Sin errores de espacios ni merges nuevos; `.godot/` excluido |

Núcleo: impacto único a 600 unidades/s cruzando emisor, aliado y muerto; primer
hostil y objetivo cercano dentro del tramo al hocico; caducidad fraccionaria y
proyectil inmóvil; recarga real, salud/facciones y muerte única reentrante.
Integración: entrada, daño en ambos sentidos, persecución en pasos reales,
entrada/salida de alcance, límites/altura, objetivo nulo/aliado/muerto/retirado, actores
muertos inmóviles y tres recargas completas comprobando salud, posiciones,
recargas, eliminación de nodos antiguos y ausencia de conexiones heredadas.
Gráficos: clic/cursor/R reales de ventana, cámara, daño, enemigo abatido,
tres restauraciones mediante R y jugador caído por ataques reales de IA.

Se inspeccionaron `docs/validacion/T03-combate-linux.png`,
`T03-enemigo-abatido-linux.png` y `T03-jugador-caido-linux.png`: actor cian
distinguible, disparo visible, cámara funcional y HUD legible con salud coherente.
Transcripción final en `docs/validacion/T03-linux.log`. La prueba gráfica es
automatizada y las capturas son estáticas; no equivalen a manejo humano prolongado.

Antes del resultado final se reprodujeron y corrigieron cuatro defectos: muerte
duplicada por daño reentrante, salto de objetivos entre actor y origen del disparo,
acceso a viewport retirado al pulsar R y persecución de un objetivo vivo fuera del árbol. Se corrigió además el montaje de la
prueba gráfica para pausar la IA tras `_ready` mediante `scene_changed`, evitando
que disparase antes de comprobar la restauración limpia. Después se repitieron
las pruebas afectadas: sin errores de script; único aviso gráfico de V-Sync no
soportado por el driver virtual. No se cambiaron assertions para ocultar fallos.

Revisión independiente en copia temporal sin caché: importación, núcleo 51/0,
integración entonces 51/0, T02 34/0 y arranque sin errores. Identificó el objetivo
vivo fuera del árbol; tras reproducirlo (52 comprobaciones, 1 fallo), se corrigió
y la integración final pasó 52/0 junto a las demás suites headless. La corrección
solo añade una condición de validez y no altera el recorrido gráfico ya comprobado.

## Limitaciones conocidas
- **Windows pendiente:** no se ejecutó el editor ni se exportó/probó un `.exe` en
  Windows. Los comandos de Windows están documentados, no verificados en esta máquina Linux.
- Validación gráfica mediante renderizado por software y entrada automatizada en
  Linux, con inspección de capturas. No hubo sesión humana prolongada de manejo,
  prueba de GPU física ni interacción con el escritorio compartido. El seguimiento
  se verificó por fotograma; la sensación de manejo requiere evaluación del usuario.
- Q/E y estados completos de victoria/derrota/reinicio T05 todavía no implementados.
  T03 incluye combate y recarga mínima de escena, no la aceptación completa de V0.1.
- Chat compartido no accesible durante la preparación inicial; no se presupone su contenido.
- Wiki pendiente de investigar y contrastar.
- Cinco capturas de referencia del usuario pendientes de incorporar al repositorio;
  la imagen de validación de T01 es propia y no sustituye esas referencias.

## Formato de actualización
Por cada incremento registrar: tarea, cambio, archivos, comprobaciones y resultados, limitaciones, decisiones provisionales y siguiente paso. Actualizar las filas de seguimiento sin borrar limitaciones aún vigentes.
