# Estado del proyecto

## Situación actual — V0.2 T03, primer incremento visual de Cobre

Rama local `feat/v0.2-t03-cobre-animado`, creada desde la entrega publicada T02
`38c9fa5d76b799841cf8d6673cbf8ee0c3d76f42`. Código exportado `f5a5dcc`.
Cobre con detalle y animación propios; Jade conserva su modelo previo.
La publicación GitHub fue rechazada por revisión automática por considerar
insuficiente la autorización de publicación de estos cambios. No se usó otro
canal para evitar ese rechazo. Rama y commits T03 son LOCALES, sin merge.
La descarga del candidato sí está disponible para el usuario.

[Descargar candidato Windows T03](https://chatgpt.com/library?file_id=libfile_dfab7f1a5ecc81918d65d854f1b25c94&account_id=personal).

## Histórico — V0.2 T02, candidato Windows preparado
Rama `feat/v0.2-t02-armas-equipamiento-reimplementacion`. Código exportado:
`daa8a1bdbd9e597f919ef04111ce89f068142b01`. Armas y cuatro combinaciones
validadas en Linux, con revisión gráfica y paquete Windows comprobable.
Windows nativo y prueba humana V0.2 siguen pendientes. Sin merge ni T03.
La sección de reimplementación registra el bloqueo gráfico inicial; el cierre
posterior de este documento lo resuelve. Los reportes previos son históricos.

[Descargar candidato Windows V0.2 T02](https://chatgpt.com/library?file_id=libfile_6075c6e6f5888191af9a8cba50e5ff3c&account_id=personal).

## Histórico — entrega V0.2 T01 (17 de noviembre de 2026)
**Selección de dos dragones implementada y validada en Linux** con Godot4.6.3
Compatibility: Cobre conserva V0.1; Jade tiene menos salud/daño por impacto y más
velocidad/menor recarga. Balance en recursos separados, selector previo, reinicio
con la elección actual y retorno al selector tras victoria/derrota.

El usuario informó que **probó el prototipo en su laptop y lo consideró «decente»**.
Se registra como valoración humana general. No reportó sistema operativo, GPU,
SHA ni resultados de controles, combate, resoluciones o reinicios individuales;
esas comprobaciones permanecen pendientes. No equivale a aceptación integral T06.
La petición actual autoriza el primer incremento V0.2, aunque el encargo antiguo
de main sigue indicando completar T06. Rama nueva `feat/v0.2-t01-seleccion-dragones`,
desde `b42ceef`, conservando V0.1 y su candidato exportado e40276a.

### Continuidad V0.1 conservada
**T01–T05 conservadas y regresiones repetidas en Linux** con Godot 4.6.3
Compatibility. T06 prepara un candidato **V0.1 RC1 Windows x86_64**, exportado
realmente en release desde un commit identificado, con ZIP íntegro y guía española.
El PCK exportado también pasó el ciclo gráfico completo en Godot Linux.
**Los casos individuales de Windows/laptop siguen pendientes**; existe la valoración
general del usuario, pero T06 no está validada íntegramente. La release preliminar
está bloqueada por `Forbidden` en la API:
el ZIP se conserva en el entorno y se entrega mediante enlace de archivo del chat,
sin URL estable de release verificada. Rama de código publicada, sin merge.
Continuidad del encargo main `c33bad1`: candidato e40276a/ZIP conservados,
integridad comprobada de nuevo y una única consulta API todavía `Forbidden`.
Registro Windows preparado en `docs/validacion/T06-prueba-windows.md`, pendiente
de resultados individuales. No se ha reexportado el candidato V0.1.

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
| T04 Habilidades | Terminada (Linux) | Q 57/0, E 78/0, integración 42/0, ventana 49/0; regresión T02/T03 y arranque sin errores |
| T05 Ciclo e interfaz | Terminada (Linux) | Estados 51/0, ventana 145/0 en dos tamaños; regresiones T02–T04 sin fallos y seis capturas inspeccionadas |
| T06 Validación y entrega | Candidato conservado; valoración general recibida | Pruebas Linux/exportación previas conservadas. Usuario: probado en laptop, «decente». Casos individuales/datos Windows y release alojada pendientes |

## Seguimiento V0.2
| Incremento | Estado | Evidencia |
| --- | --- | --- |
| T01 Selección de dos dragones y balance | Terminado (Linux) | Perfiles93/0, selector64/0, partida46/0; ventana777/0; regresiones V0.1 y revisión independiente |

## Próxima acción
Recoger observaciones del usuario sobre la selección y diferencias entre perfiles;
corregir cualquier fallo reproducido. El siguiente incremento propuesto de V0.2
es selección de arma y sus datos; requiere su encargo antes de implementarlo.
Mantener los casos individuales no reportados pendientes. Conservar como
pendientes de T06 el informe Windows detallado y la publicación del mismo ZIP/sidecar en
una release preliminar ligada a `e40276a` cuando el acceso a GitHub API lo permita;
descargar ese artefacto y comparar el SHA256. No se hizo merge ni se modificó la
configuración de red para sortear el bloqueo. Conservar la rama/candidato V0.1
y la nueva rama `feat/v0.2-t01-seleccion-dragones`.

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

## Registro del incremento T04

### Base y archivos
- Base exacta: `b9da1e4ddaa3b138b41275961d2144c8de72a5a9`, conservada en la rama T03.
  Nueva rama: `feat/v0.1-t04-habilidades`. Sin merge, rebase ni force push.
- Código T04: `c0a02d1e2bf9b78d78164d764918c34bdaeaf0a0`; cierre documental posterior.
- Encargo recuperado de `origin/main` en `27918fc8276b5900818d5768aa4b69879a0c2c18`
  mediante `git show`, sin sustituir este ESTADO por el de main.
- `weapon.gd`: PackedScene exportada, básica por defecto. `PowerWeapon` usa
  `power_projectile.tscn` y el mismo `projectile.gd` de T03, sin modificar su barrido.
  Escena nula/vacía/incompatible se rechaza sin efectos ni consumo de recarga.
- `power_projectile.tscn`: esfera magenta propia, radio visual 0.3 frente a 0.15
  amarilla del básico. Q exportada: daño45, velocidad36, vida2s, recarga2.5s.
- `pulse_ability.gd`: daño instantáneo, radio4 inclusivo por centros XZ
  (**d² <= radio²**, sin usar altura Y), daño30, recarga4s y efecto0.5s.
  Excluye emisor, aliados, muertos, retirados, encolados y otros nodos inválidos.
  Revalida cada objetivo después de callbacks; reserva la activación para impedir
  reentrada incluso con recarga configurada a cero. E sin objetivos es válida.
- `pulse_effect.gd`/`pulse_effect.tscn`: anillo propio cian verde, radio visual
  coincidente con el daño y duración configurada. No tiene autoridad de daño:
  permanecer en él no causa impactos repetidos; se elimina al terminar.
- `combat_actor.gd`: registra actores en `combat_actors`. `dragon.tscn` compone
  PowerWeapon/PulseAbility; `dragon_controller.gd` recibe Q/E físicos por pulsación,
  ignora eco y mantiene latch hasta soltar. Pérdida de foco limpia el latch.
- `arena.gd`/`arena.tscn`: conecta contenedores Projectiles/Effects y HUD de
  disponibilidad, segundos restantes y bloqueo por muerte. R recarga todo el árbol,
  restaurando salud, posiciones, armas, habilidades y efectos sin acumulación.
- `project.godot`: acciones `ability_q` (Q físico) y `ability_e` (E físico).
- Pruebas nuevas: `test_power_projectile.gd`, `test_pulse.gd`, `test_t04.gd`,
  `test_t04_window.gd`, con UID versionados. No se modificaron las aserciones ni
  montajes de las suites T02/T03 respecto a la base de este incremento.
- Balance, materiales y geometría son propios y provisionales, no datos originales.
  Sin dependencias nuevas, servicios online ni implementación de T05/T06.

### Comprobaciones reales
Godot `4.6.3.stable.official.7d41c59c4`, desde `/workspace/The-Dragons-and-titans`.
XDG_CACHE_HOME/DATA_HOME/CONFIG_HOME apuntaron a directorios escribibles bajo
`/tmp/dragons-t04/`; gráficos con Xorg temporal `:93`, OpenGL 4.5 Compatibility
por Mesa llvmpipe. Estas son comprobaciones Linux, no ejecución Windows.

| Suite/comando | Resultado final |
| --- | --- |
| `godot --headless --path game --import` | Salida 0, sin errores |
| `godot --headless --path game --script res://tests/test_power_projectile.gd` | 57 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --script res://tests/test_pulse.gd` | 78 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --script res://tests/test_t04.gd` | 42 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --script res://tests/test_t02.gd` | 34 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --script res://tests/test_combat_core.gd` | 51 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --script res://tests/test_t03.gd` | 52 comprobaciones, 0 fallos, salida 0 |
| `godot --headless --path game --quit-after 120` | Salida 0, sin errores |

Cada suite de ventana se ejecutó con:
`DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/<suite>.gd -- --output-dir=/tmp/dragons-t04/graphics`.

| Suite gráfica | Resultado final |
| --- | --- |
| `test_t04_window` | 49 comprobaciones, 0 fallos, salida 0 |
| `test_t02_window` | 22 comprobaciones, 0 fallos, salida 0 |
| `test_t03_window` | 34 comprobaciones, 0 fallos, salida 0 |

Q verifica dirección, datos, recarga, escenas rechazadas, facciones, impacto único,
objetivo cercano y barrido a 600 unidades/s, caducidad y visual distinto. E verifica
varios hostiles, frontera exacta, fuera del radio, otra altura, aliado, muerto,
candidatos invalidados por callbacks, daño instantáneo sin repetición, recarga,
rechazos sin consumo y eliminación del VFX. La integración usa entradas físicas,
independencia entre básico/Q/E, eco, hold tras terminar CD, nueva pulsación,
foco simulado, muerte y tres reinicios con estado activo.

La ventana usa teclas Q/E/R y cursor reales de la ventana con entrada automatizada;
IA pausada solo en el montaje de T04. Q impacta al enemigo inicialmente en Z=-7;
para E se coloca en Z=-3. Se acortan esperas de recarga únicamente en la prueba
de hold, sin modificar datos de producción. La regresión T03 ejercita IA activa.
Se inspeccionaron las capturas propias `docs/validacion/T04-proyectil-potente-linux.png`
y `T04-pulso-y-recargas-linux.png`: Q magenta distinguible, anillo visible y HUD
legible con salud/tiempos coherentes. Transcripción: `docs/validacion/T04-linux.log`.

La primera ventana dio 49 comprobaciones/1 fallo al leer el HUD antes de
`Arena._process`; la captura posterior ya mostraba los tiempos correctos. Se
corrigió solo la sincronización del montaje con `frame_post_draw` y se reforzó
la comprobación de ambos segundos. Repetición: 49/0 y regresiones gráficas 22/0,
34/0, sin errores de script. Único aviso: V-Sync no soportado por el driver virtual.

Revisión independiente de código e integración: sin hallazgos de aceptación.
En copia temporal sin caché se repitieron importación, Q57/0, E78/0, integración42/0,
T02 34/0, núcleo51/0, T03 52/0 y arranque, todos con salida 0. Esa revisión no
repitió gráficos. `git diff --check` limpio; sin merges nuevos desde `b9da1e4`.

## Registro del incremento T05

### Base, referencias y archivos
- Base exacta: `37e1ee96e41023bb28965dcd87c90abdf0e706e8`, cierre T04 conservado.
  Nueva rama: `feat/v0.1-t05-ciclo-partida`. Sin merge, rebase ni force push.
- Código T05: `a9be6e5e31d0d6fe8c2c7acfb85264f72393f44d`; el cierre documental
  está en un commit posterior de la misma rama.
- Encargo recuperado mediante `git show origin/main:docs/SIGUIENTE_TAREA.md`
  desde main en `a5ea2f1cfa392625bcc7177039be078ce6f587f4`. Se conservaron
  ESTADO y código de T04; no se incorporó main mediante merge.
- `arena.gd`: estados explícitos y señal final única; resolución con prioridad
  física 100 después de actores/proyectiles (0). El cierre deshabilita combate y
  pone velocidad cero en ambos actores, neutraliza y retira proyectiles/efectos.
  La interfaz continúa activa sin pausa global. Guardia de recarga contra
  solicitudes repetidas y eco de R.
- `combat_actor.gd`, controladores, `weapon.gd` y `pulse_ability.gd`: acciones y
  daño rechazan actores bloqueados, incluido el ganador vivo. El controlador
  registra solo las entradas mantenidas al crear la escena y exige soltarlas
  antes de actuar; nuevas pulsaciones no prolongan esa lista inicial.
- `hud.gd`/`hud.tscn`, instanciados por `arena.tscn`: objetivo, controles,
  salud/recargas, panel VICTORIA/DERROTA y botón Reiniciar con foco visible.
  Clic, Enter/Espacio y R; una sola petición del botón por final. El HUD anuncia
  cuándo hay que soltar entradas retenidas. Panel superior compacto para evitar
  cubrir al jugador y reducir la superposición sobre el enemigo.
- `test_match_state.gd` y `test_t05_window.gd`: suites nuevas con UID versionados.
  Los montajes T03/T04, headless y ventana, pausan solo la resolución de partida
  para conservar sus casos que continúan tras una muerte. No se retiraron ni
  relajaron aserciones; T05 comprueba el cierre real con resolución activa.
  Las suites aisladas de salud/proyectiles/habilidades y T02 se conservan.
- README, este ESTADO, REVISIONES, encargo, plan y evidencia actualizados.
  Sin dependencias nuevas ni ampliación de catálogo, arte u online.

### Reglas provisionales
- Si ambos actores mueren durante el mismo paso de resolución, **derrota tiene
  prioridad**, independientemente del orden del daño. Un resultado final no
  cambia ni vuelve a emitir la señal. No se atribuye esta regla al juego original.
- R se conserva durante el juego y al terminar. Reiniciar recarga la escena
  completa: salud, posiciones/orientación, objetivo, recargas, indicadores,
  estados, proyectiles, efectos y conexiones; no arrastra acciones mantenidas.

### Pruebas realizadas
Godot `4.6.3.stable.official.7d41c59c4`, desde `/workspace/The-Dragons-and-titans`.
Directorios XDG escribibles bajo `/tmp/dragons-t05/{cache,data,config}`.
Gráficos: Xorg temporal `:93` con driver dummy, Compatibility OpenGL 4.5,
Mesa llvmpipe. Todas las pruebas siguientes finalizaron con salida 0.

| Comando/suite | Resultado final |
| --- | --- |
| `godot --headless --path game --import` | Sin errores de scripts/recursos |
| `godot --headless --path game --script res://tests/test_match_state.gd` | 51 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_t02.gd` | 34 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_combat_core.gd` | 51 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_t03.gd` | 52 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_power_projectile.gd` | 57 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_pulse.gd` | 78 comprobaciones, 0 fallos |
| `godot --headless --path game --script res://tests/test_t04.gd` | 42 comprobaciones, 0 fallos |
| `godot --headless --path game --quit-after 120` | Arranque sin errores |

Cada suite gráfica se ejecutó con:
`DISPLAY=:93 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/<suite>.gd -- --output-dir=/tmp/dragons-t05/graphics`.

| Suite gráfica | Resultado final |
| --- | --- |
| `test_t05_window` | 145 comprobaciones, 0 fallos; ventanas nativas 1280×720 y 960×540 |
| `test_t02_window` | 22 comprobaciones, 0 fallos |
| `test_t03_window` | 34 comprobaciones, 0 fallos |
| `test_t04_window` | 49 comprobaciones, 0 fallos |

Estados: victoria y derrota por proyectiles reales; empate en ambos órdenes;
transición/señal única; bloqueo de movimiento, básico, Q/E y daño directo o
pendiente en ambos actores; eliminación de transitorios y árbol sin pausa.
También peticiones rápidas de reinicio, salud/posiciones/objetivo/recargas
restaurados y liberación de WASD/clic/Q/E/R/aceptar retenidos antes de volver a jugar.

Ventana: jugar→victoria→derrota→victoria en cada resolución, seguido cada final
de reinicio, alternando R, botón con Enter y botón con clic nativo. Comprueba
foco, bounds, texto, bloqueo posterior, tres restauraciones limpias por tamaño,
conexiones únicas y ausencia de acciones heredadas con varias teclas/clic
mantenidos. La automatización usa eventos físicos y colisiones reales.

Se inspeccionaron las seis capturas propias `docs/validacion/T05-{jugando,victoria,derrota}-{1280x720,960x540}-linux.png`:
objetivo/controles/salud/recargas legibles, resultado inequívoco, botón enfocado,
sin texto cortado ni panel sobre el jugador. La captura lee la pantalla del
servidor X11 y recorta la región de la ventana nativa; no redimensiona una imagen
para simular otra resolución. Transcripción final: `docs/validacion/T05-linux.log`.

Durante la validación se corrigieron sincronización de colliders en el montaje
de estados y envío de Enter lógico además de físico. Se detectó que capturar la
textura del viewport no acredita el tamaño nativo: se cambió al tamaño de Window
y captura de pantalla, con comprobaciones explícitas de dimensiones. También se
compactó el HUD tras inspección visual. Ninguna aserción se suprimió para pasar.
Se reprodujo y corrigió además el texto de salud del HUD en montajes legacy que
pausan la resolución: 4 comprobaciones/2 fallos antes, 4/0 después, sin cambiar
las reglas de final. Resultados finales anteriores sin errores de scripts;
único aviso gráfico: V-Sync no soportado por el driver virtual.

Revisión independiente en copia temporal sin caché: importación, estados51/0,
T02 34/0, núcleo51/0, T03 52/0, Q57/0, E78/0, T04 42/0 y arranque, todo con
salida 0; sin hallazgos de aceptación. No repitió gráficos. El implementador
ejecutó las suites gráficas e inspeccionó las capturas. No hubo manejo humano
prolongado ni prueba Windows. `git diff --check` limpio y caché Godot excluida.
La revisión documental final no encontró contradicciones entre alcance, pruebas,
referencias SHA y pendientes de T06/Windows.

## Registro del incremento T06 — candidato Windows

### Referencias y conservación
- Base exacta: `036553c7a9bd364f2e6d865a3d17b3ce46254ab1`, cierre T05 conservado.
  Nueva rama: `feat/v0.1-t06-entrega-windows`, publicada mediante Git sin merge,
  rebase ni force push. T01–T05 no tienen cambios de lógica, escenas ni balance.
- Código/configuración exportados: `e40276a5cb769e53794cd1f64832796772ec060f`.
  El cierre documental es un commit posterior; **el ZIP identifica e40276a**,
  no el commit documental. `git diff 036553c..e40276a` confirma que scripts,
  escenas y project.godot del juego están intactos.
- Encargo leído de main en `a19f7d0255c7ca997099d59cfc913d564339db6d` mediante
  `git show origin/main:docs/SIGUIENTE_TAREA.md`, conservando ESTADO de T05.

### Exportación y paquete
- `game/export_presets.cfg`: preset **Windows x86_64**, release, Compatibility,
  EXE/PCK externos, `tests/*` excluidos. Sin firma ni modificación de recursos EXE.
- `tools/package_windows.py`: Python 3.12+, biblioteca estándar; exporta un
  `git archive` del SHA indicado con XDG/caché temporales, sin cambios locales.
  Comprueba versión exacta de Godot y plantillas, incluye guía/licencias/manifiesto,
  verifica PE x86_64, PCK, CRC y extracción limpia con SHA256 de los archivos.
  Genera ZIP, sidecar SHA256, reporte JSON y log, sin reemplazar un ZIP existente.
- `docs/entrega/LEEME-WINDOWS.txt`: extracción completa, EXE sin instalar Godot,
  controles/objetivo, dos tamaños, ganar/perder/bloqueo y tres reinicios R/botón,
  entradas retenidas y reporte con Windows/GPU/captura/log/SHA. No recomienda
  desactivar protecciones del sistema ni promete rendimiento/requisitos medidos.
- `docs/entrega/LICENCIAS-GODOT.txt`: copia completa de COPYRIGHT.txt oficial de
  Godot `4.6.3-stable`, incluidos motor y terceros. SHA256:
  `b3330849267d56ddd3d62a513817506606c2195034411fe05859f0140bff9d8a`.
  Fuente: `https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/COPYRIGHT.txt`.
- Plantillas estándar oficiales de `godotengine/godot-builds`, versión4.6.3:
  `Godot_v4.6.3-stable_export_templates.tpz`, verificado contra SHA512 publicado:
  `da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68`.
  Solo se extrajeron `version.txt` y `windows_release_x86_64.exe`. ZIP/TPZ, EXE,
  PCK y cachés no se versionan; quedan bajo builds/ ignorado o /tmp.
- Comando final real, desde la raíz del repositorio:
  `python3 tools/package_windows.py --ref HEAD --templates /tmp/dragons-t06/templates --output-dir builds/t06`
  ejecutado cuando HEAD era `e40276a5cb769e53794cd1f64832796772ec060f`, salida0.
  El script ejecutó importación y `godot --headless --path <copia>/game --export-release "Windows x86_64" <paquete>/DragonsAndTitans.exe`, sin errores ni avisos de exportación.
  README contiene reproducción completa con SHA explícito y comprobación de plantillas.
  Se reproduce el proceso, sin prometer ZIP idéntico bit a bit por marcas temporales.

**Artefacto:** `builds/t06/DragonsAndTitans-v0.1-rc1-windows-x86_64-e40276a.zip`,
**35 977 332 bytes** (34.31 MiB).
SHA256: `aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`.
Sidecar: mismo nombre con sufijo `.sha256`. Enlace de archivo entregado en el chat;
no hay todavía URL estable de GitHub Release. Los fuentes de la rama no incluyen
el binario y no deben ofrecerse como sustituto de esa descarga.

| Archivo dentro de la carpeta del ZIP | Bytes |
| --- | ---: |
| DragonsAndTitans.exe | 104 659 456 |
| DragonsAndTitans.pck | 65 124 |
| LEEME.txt | 4 314 |
| LICENCIAS-GODOT.txt | 99 790 |
| VERSION.json | 551 |
| SHA256SUMS.txt | 415 |

VERSION.json identifica SHA exportado, versión exacta, release, arquitectura,
Compatibility y hashes de preset/plantilla. Declara `native_windows_tested=false`
y `human_laptop_tested=false`. Integridad: ZIP CRC correcto, seis archivos exactos,
cinco hashes internos distintos/correctos y extracción en carpeta vacía.

### Validación Linux repetida desde copias limpias
Godot `4.6.3.stable.official.7d41c59c4`, Python3.12.14, Linux x86_64.
Dos copias creadas mediante `git archive` del SHA base036553c, inicialmente sin
`.godot`; los 81 archivos tracked coinciden antes y después. Ese código de juego
es idéntico al exportado en e40276a. Variables XDG propias en /tmp para cada copia.
Gráficos: Xorg1.21.1.16 dummy temporal `:94`, Compatibility OpenGL4.5, Mesa25.0.7
llvmpipe. Todas las suites finalizaron con salida0, sin errores de scripts.

| Suite/comprobación | Resultado |
| --- | --- |
| `godot --headless --path game --import` y `--quit-after 120` | Importación y arranque limpios |
| `test_t02.gd` | 34/0 |
| `test_combat_core.gd` | 51/0 |
| `test_t03.gd` | 52/0 |
| `test_power_projectile.gd` | 57/0 |
| `test_pulse.gd` | 78/0 |
| `test_t04.gd` | 42/0 |
| `test_match_state.gd` | 51/0 |
| Total lógica | **365 comprobaciones, 0 fallos** |
| `test_t02_window.gd` | 22/0 |
| `test_t03_window.gd` | 34/0 |
| `test_t04_window.gd` | 49/0 |
| `test_t05_window.gd` | 145/0 |
| Total gráfica de fuentes | **250 comprobaciones, 0 fallos** |

Comandos headless: `godot --headless --path game --script res://tests/<suite>.gd`.
Ventana: `DISPLAY=:94 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/<suite>.gd -- --output-dir=/tmp/dragons-t06-graphics/capturas`.
Comandos, versiones y salidas conservados en `docs/validacion/T06-headless-linux.log`
y `T06-graficas-linux.log`. Único aviso Godot gráfico: V-Sync no soportado por
driver virtual; Xorg también registró ausencia del bus D-Bus. Servidores temporales
propios detenidos al terminar. No se cambiaron ni relajaron aserciones.

### Comprobación del contenido exportado y revisión independiente
- PCK final extraído del ZIP: SHA256
  `9d51e43f92bb8645fbb1271cdfdc16564f14f2b154182e080e4d4f47508c4dfd`.
  Inspección de 37 entradas, formato3/Godot4.6.3, rangos y MD5 internos correctos;
  arena presente y sin tests, preset, docs, caché del editor ni rutas del desarrollador.
  Los remaps/recursos internos `.godot` del paquete son datos de ejecución necesarios.
- Carga del PCK final fuera del proyecto con
  `godot --headless --main-pack <extraído>/DragonsAndTitans.pck --quit-after 120`:
  salida0 sin errores. **Godot Linux cargando datos exportados, no el EXE Windows**.
- Se ejecutó además `test_t05_window.gd` como script externo al PCK final, con
  `--main-pack`, servidor X11 y los dos tamaños: **145/0**, salida0. Comprueba
  victoria/derrota, bloqueo, foco/botón/R y tres reinicios por tamaño sobre los
  recursos exportados. Hash PCK intacto antes/después. Registro específico en
  `docs/validacion/T06-pck-graficas-linux.log`; tampoco acredita Windows nativo.
- Se inspeccionaron seis capturas nativas del PCK en 1280×720 y 960×540, jugando,
  victoria y derrota: HUD legible/sin recorte, jugador visible, resultado y botón
  enfocado claros. Evidencia propia `docs/validacion/T06-pck-*-linux.png`.
  Entrada automatizada e inspección estática, sin sesión humana prolongada.
- Revisión independiente de script/preset/guía y ZIP final: sin hallazgos.
  Verificó extracción propia, PE32+ AMD64 idéntico a plantilla, hashes/tamaños,
  VERSION/LEEME/licencias/preset frente a `git show e40276a`, y PCK internamente.
  No ejecutó Windows ni repitió las suites; agentes separados ejecutaron lógica
  y gráficos. Reporte del paquete en `docs/validacion/T06-paquete.json`.
- Revisión documental final sin contradicciones entre artefacto, SHA/hash,
  resultados y pendientes. `git diff --check` limpio, caché y binarios excluidos.

### Publicación y pendientes de T06
- Rama publicada por Git con código e40276a. El intento concreto fue:
  `gh release create v0.1-rc1-t06 <ZIP> <ZIP.sha256> --repo JoseB-H/The-Dragons-and-titans --target e40276a5cb769e53794cd1f64832796772ec060f --prerelease --title <título> --notes-file <notas>`.
- Salida1 antes de crear/adjuntar:
  `error checking for existing release: Head "https://api.github.com/repos/JoseB-H/The-Dragons-and-titans/releases/tags/v0.1-rc1-t06": Forbidden`.
  Una comprobación HTTPS directa también recibió `CONNECT tunnel failed, response 403`.
  La política de red observada no incluye `api.github.com` ni `uploads.github.com`;
  no se acredita permiso del servicio ni se modifica la política para eludirlo.
  `git ls-remote --tags origin v0.1-rc1-t06` no devolvió un tag nuevo.
- ZIP/sidecar conservados y enlazados desde el chat. **Publicación estable y
  comprobación de descarga remota/hash pendientes**. Registro exacto en
  `docs/validacion/T06-publicacion.log`; no se inventa URL ni se adjunta binario a Git.
- **Windows nativo pendiente:** no hay entorno Windows disponible; este es Linux,
  no se ejecutó el EXE, ni con Wine ni en Windows. **Prueba humana en laptop pendiente**.
  Candidato listo para que el usuario descargue/extraiga y pruebe con LEEME;
  no declarar T06 validada íntegramente ni V0.1 aceptada hasta registrar esa prueba.

### Continuación del encargo de main c33bad1 — 17 de noviembre de 2026
- Leído `origin/main:docs/SIGUIENTE_TAREA.md` en
  `c33bad1b072a7138d06f86a2c6cc38279893b003`. Se continúa sobre la misma rama
  `feat/v0.1-t06-entrega-windows`, desde su cierre documental `d1cc1ac`, sin
  volver a T05, merge, force push ni cambios de juego o V0.2.
- Código exportado e40276a y artefacto original conservados. Nueva comprobación
  de tamaño 35 977 332 bytes, SHA256
  `aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`,
  sidecar, CRC 6/6, VERSION.source_commit y cinco hashes internos: correctos.
  Verificación independiente sin hallazgos; no se reexportó ni se sustituyó ZIP.
  Los resultados Linux 365/0 y 250/0, y PCK 145/0 anteriores se conservan como evidencia
  histórica: no se repitieron suites ni se ejecutó Godot en esta continuación.
- Política actual observada y aplicada: restringida: `api.github.com` y
  `uploads.github.com` siguen fuera de la lista efectiva. Una sola consulta de
  disponibilidad: `gh api repos/JoseB-H/The-Dragons-and-titans/releases/tags/v0.1-rc1-t06`,
  salida 1: `Get "https://api.github.com/repos/JoseB-H/The-Dragons-and-titans/releases/tags/v0.1-rc1-t06": Forbidden`.
  No se repiten llamadas API ni intentos de crear/adjuntar; publicación, URL
  estable y verificación de descarga remota/hash siguen bloqueadas. No se cambió
  la configuración de red ni se inventó URL. Evidencia en `T06-continuidad.log`.
- Entorno disponible: Linux 6.18.57 x86_64; sin Windows nativo accesible ni informe
  humano incorporado. Se solicitó al usuario Windows/GPU y resultados concretos.
  `docs/validacion/T06-prueba-windows.md` prepara metadatos, comandos y matriz de
  controles/combate/final/reinicio en ambos tamaños, todos **pendientes**. No es
  un informe de prueba ejecutada y no cambia las instrucciones del ZIP existente.
- README y encargo actualizados para facilitar la prueba humana del mismo ZIP.
  Cualquier fallo real debe reproducirse y corregirse antes de V0.2; si cambia
  código, exportar un candidato nuevo con SHA/hash propios y repetir lo afectado.
  T06/V0.1 continúan sin aceptación integral.

## Registro del incremento V0.2 T01 — selección de dragones

### Base y autorización
- Rama nueva: `feat/v0.2-t01-seleccion-dragones`, desde
  `b42ceef776ce81b6af704466afb842f4959acd80`, conservando la entrega T06 y T01–T05.
- Código: `bc22940449b532d53789b29720237549a2de835c`; cierre documental posterior.
  Sin merge, rebase ni force push. La instrucción actual del usuario autoriza
  V0.2 y prevalece sobre el encargo antiguo T06 de main `c33bad1`.
- El usuario indicó que probó el prototipo en su laptop y lo consideró «decente».
  Es una valoración general reportada; no especificó OS/GPU, SHA ni casos. No se
  marcan aprobadas las filas de `T06-prueba-windows.md` ni se extrapola a V0.2.
- Candidato V0.1 e40276a, ZIP y sidecar conservados. SHA256 comprobado de nuevo:
  `aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`.
  No se reexportó ni se modificó ese paquete. No se reiteraron llamadas API.

### Comportamiento, datos y recursos propios
- `game/scripts/dragon_profile.gd` y `game/data/dragons/{cobre,jade}.tres`:
  identidad, descripción, salud, velocidad, daños/recargas de básico/Q/E,
  velocidades/vida/origen de proyectiles, radio/duración del pulso y colores.
  El controlador aplica el recurso sin ramas de balance por nombre. La salud
  actual, las recargas y los materiales de cada instancia no mutan esos recursos.
- **Valores provisionales propios:** Cobre conserva salud100/velocidad6,
  básico20 cada0.4s, Q45 cada2.5s, E30/radio4/cada4s. Jade usa salud70/velocidad8,
  básico15 cada0.3s, Q35 cada2s y E20/radio3.5/cada3s. Jade cambia resistencia,
  velocidad y daño por golpe; no se afirma equilibrio final ni fidelidad original.
- `dragon_roster.gd`, autoload en `project.godot`: elección solo en memoria,
  Cobre inicial, rechazo de id desconocido sin cambiar selección. Sin guardado
  en disco, selección de armas, cuentas ni ampliación de catálogo.
- `dragon_selection.gd`/`dragon_selection.tscn`: nueva escena principal, tarjetas
  comparables con valores leídos del recurso y botón Jugar. Clic o Tab/flechas y
  Enter/Espacio; resaltado y foco visibles. Una sola navegación ante peticiones
  rápidas. Al regresar enfoca la elección anterior y no inicia combate por eco.
- `dragon_controller.gd`: aplica salud máxima al entrar en el árbol y el resto
  del perfil antes del ready heredado. Conserva movimiento, cámara, límites,
  bloqueo y snapshot de entradas retenidas de V0.1. Cobre conserva paleta original;
  Jade usa materiales locales verdes sobre la misma geometría propia. Ojos/cuernos,
  enemigo cian y otros dragones no se recolorean por compartir meshes.
- `arena.gd`, `hud.gd`/`hud.tscn`: HUD identifica el perfil. R/Reiniciar recargan
  Arena y conservan elección; el nuevo botón final Elegir dragón vuelve al selector.
  No se cambia durante combate. Guardia común impide duplicar escenas/conexiones.
  Los dos botones comparten fila sin agrandar el panel sobre el jugador.

### Pruebas realizadas y resultados
Godot `4.6.3.stable.official.7d41c59c4`, Compatibility, Linux x86_64. Directorio
del repositorio `/workspace/The-Dragons-and-titans`; XDG propios bajo
`/tmp/dragons-v02/headless/{cache,data,config}` y `window/{cache,data,config}`.
Todos los comandos finales terminaron con salida0, sin errores de scripts/recursos.

| Prueba | Comando o suite real | Resultado |
| --- | --- | --- |
| Importación | `godot --headless --path game --import` | Sin errores |
| Perfiles y aislamiento | `test_dragon_profiles.gd` | 93/0 |
| Selector e inputs | `test_dragon_selection.gd` | 64/0 |
| Selección/combate/reinicio/retorno | `test_v02_match.gd` | 46/0 |
| Regresión movimiento | `test_t02.gd` | 34/0 |
| Regresión núcleo | `test_combat_core.gd` | 51/0 |
| Regresión combate | `test_t03.gd` | 52/0 |
| Regresión Q | `test_power_projectile.gd` | 57/0 |
| Regresión E | `test_pulse.gd` | 78/0 |
| Regresión habilidades | `test_t04.gd` | 42/0 |
| Regresión estados | `test_match_state.gd` | 51/0 |
| Arranque del selector | `godot --headless --path game --quit-after 120` | Sin errores |
| Ventana V0.2 | `test_v02_window.gd` | 777/0 |
| Ventana T02/T03/T04/T05 | Suites heredadas `*_window.gd` | 22/0, 34/0, 49/0, 145/0 |

Cada suite headless usa `godot --headless --path game --script res://tests/<suite>.gd`.
Las gráficas usan `DISPLAY=:94 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/<suite>.gd -- --output-dir=/tmp/dragons-v02/graphics`.
Xorg temporal dummy, OpenGL4.5 Compatibility Mesa llvmpipe. Único aviso Godot
gráfico: V-Sync no soportado por el driver virtual. No se cambiaron las aserciones
ni montajes heredados para este incremento. Totales: nuevas headless203/0,
heredadas365/0; ventana nueva777/0 y heredadas250/0.

Perfiles prueba salud desde primera señal, movimiento real, impactos de básico/Q,
frontera del pulso, recargas y aislamiento de recursos/materiales/actores.
Selector prueba selección válida/inválida, texto de datos, mouse/Tab/Enter/Espacio,
foco y navegación única. Partida prueba daño real según ambos perfiles, victoria,
derrota, bloqueo, restauración completa, elección conservada y cambio posterior.
Ventana recorre dieciséis resultados reales y doce reinicios, ambas elecciones por
ratón/teclado, inputs retenidos/eco, vuelta al selector y cambio de perfil en los
dos tamaños nativos. Comprueba posiciones/salud/recargas y ausencia de acumulación.

### Evidencia, correcciones y revisión
- Pruebas escritas antes de producción: catálogo RED1/1→GREEN11/0; perfiles
  RED93/21→GREEN93/0; selector RED por escena ausente; integración RED por retorno
  ausente. Las cuentas crecieron al añadir cobertura, sin retirar aserciones.
- Se reprodujo una señal inicial transitoria de salud0/70 al aplicar Jade en
  ready (93/1). Preparar salud máxima en `_enter_tree` dejó primera señal70/70
  y suite93/0. Se reprodujo además foco diferido en un botón ya retirado al
  navegar inmediatamente (selector64/1 y ERROR de Godot); foco directo en ready
  corrigió el caso: selector64/0 y partida46/0, sin errores.
- Revisión independiente en copia completa de fuentes sin `.godot/builds`:
  importación y tres suites nuevas93/0,64/0,46/0. La revisión estática final del
  código y las cuatro suites nuevas no encontró defectos concretos. No repitió
  gráficos ni acredita Windows o manejo humano del selector.
- Dieciséis capturas nativas `docs/validacion/V02-*-linux.png`, ocho por tamaño,
  revisadas sin hallazgos: tarjetas, HUD, ambos dragones, finales y botones legibles,
  sin recortes ni paneles sobre el jugador. Informe visual independiente en
  `V02-T01-revision-visual.txt`. Es inspección estática de automatización Linux.
- Transcripción final `docs/validacion/V02-T01-linux.log`; metadatos/hashes de
  capturas y comprobaciones en `V02-T01-evidencia.json`. La pausa del entorno
  preservó los archivos; se recuperaron resultados y se registraron de nuevo los
  códigos de las regresiones gráficas antes del cierre, sin repetir implementación.
- No se exportó ni probó Windows de V0.2. La valoración de la laptop corresponde
  al prototipo anterior; no se atribuye a estos perfiles o a sus pruebas nuevas.
- Revisión documental final: se aclaró que el balance del jugador se modifica
  en `.tres`, mientras los nodos lo ejecutan. Sin contradicciones restantes entre
  resultados, código, evidencia y límites reportados.

## Limitaciones conocidas
- **Windows nativo pendiente:** se exportó un `.exe` release desde Linux, pero no
  se han reportado casos individuales de Windows. Editor, GPU/controladores y guía de PowerShell
  siguen sin verificación nativa; exportación no equivale a compatibilidad probada.
- Validación gráfica mediante renderizado por software y entrada automatizada en
  Linux, con inspección de capturas. El usuario reportó una prueba en laptop y
  valoración «decente» del prototipo anterior; no detalló duración, GPU, plataforma
  o casos. No hay prueba humana del nuevo selector reportada. No se acredita una
  sesión prolongada, rendimiento en GPU física ni comprobaciones individuales.
- T05 completa el ciclo offline; T06 aporta un candidato exportado, con ZIP y
  datos comprobados en Linux. La aceptación integral de V0.1 sigue pendiente.
- La prueba detallada Windows/laptop sigue pendiente; la valoración general sí
  está registrada. Release alojada bloqueada por acceso API. ZIP V0.1 conservado,
  fuera de Git; no se exportó un ZIP de V0.2 ni se le atribuye la prueba anterior.
- Chat compartido no accesible durante la preparación inicial; no se presupone su contenido.
- Wiki pendiente de investigar y contrastar.
- Cinco capturas de referencia del usuario pendientes de incorporar al repositorio;
  la imagen de validación de T01 es propia y no sustituye esas referencias.

## Formato de actualización
Por cada incremento registrar: tarea, cambio, archivos, comprobaciones y resultados, limitaciones, decisiones provisionales y siguiente paso. Actualizar las filas de seguimiento sin borrar limitaciones aún vigentes.

## V0.2 T02 — Reimplementación desde respaldo publicado
El entorno de la entrega anterior quedó inaccesible según el usuario. No se
recuperó ni verificó su commit 5a1f54a ni su ZIP. Durante esta recuperación se clonó
el remoto y no se encontró una rama T02 publicada. Se partió de 95337f2 en una
rama nueva; no se borró ni modificó el entorno anterior, main o entregas previas.

Implementados Ascua/Martillo astral, cuatro combinaciones, balance separado,
selector de armas con Tab/Enter y ratón, estadísticas combinadas, HUD, marca
geométrica sobre el dragón, proyectiles diferenciados e impacto temporal propio.
Ascua conserva básico anterior; Martillo multiplica daño ×1.8 y recarga ×2.
Q/E, salud y movimiento permanecen en los perfiles de dragón. Reinicios conservan
ambas elecciones y la arena impide cambiar de arma. No hay guardado en disco.

Validación: Godot 4.6.3 estable instalado. Importación headless aprobada. Las diez
suites heredadas de lógica aprobaron 568 comprobaciones antes del impacto visual.
La nueva suite test_equipment.gd aprobó inicialmente 225 comprobaciones: cuatro
combinaciones, impactos/recargas reales, finales alternados, tres reinicios por
combinación, vuelta al selector y aislamiento. Registro final de las once suites
en docs/validacion/V02-T02-reimplementacion.log, incluyendo los efectos finales.

Limitaciones: el servidor gráfico no pudo abrir sockets; no se ejecutaron suites
gráficas ni se inspeccionaron capturas en esta entrega. No se acredita foco real,
entradas físicas ni legibilidad en ventana. No hay plantillas Windows instaladas
ni se exportó ZIP nuevo. Windows nativo pendiente. T02 NO se declara cerrada:
siguiente paso validar gráficos a 1280×720/960×540, entradas retenidas y exportar.
Sin merge ni T03. El git push HTTPS local carecía de credenciales; se utiliza
el conector GitHub para publicar el respaldo si el acceso lo permite.

Se detectó durante regresión que los destellos contaban como efectos de habilidad
y alteraban las comprobaciones T04. Se corrigió su ubicación: ahora son hijos
visuales temporales del objetivo y se retiran también al terminar. No se modificó
ninguna aserción heredada.

Resultado final: once suites, 793 comprobaciones aprobadas (568 heredadas + 225
nuevas), cero fallos y sin errores de scripts en el registro final. Importación
final y git diff --check aprobados. Validación gráfica/exportación pendientes.

## V0.2 T02 — Cierre gráfico y candidato para laptop

### Evidencia final
- Código del juego sin cambios respecto a daa8a1b; solo se añadieron pruebas y
  documentación. Se conserva la evidencia de 793 comprobaciones de lógica.
- Se resolvió la indisponibilidad de pantalla ejecutando Xorg dummy y Godot en
  una misma sesión de comandos, mediante conexión TCP de loopback. OpenGL 4.5,
  Compatibility, Mesa llvmpipe; aviso esperado de V-Sync sin soporte.
- Regresiones gráficas: T02 22/0, T03 34/0, T04 49/0, T05 145/0 y V0.2 T01
  817/0. Las 40 comprobaciones extra de T01 provienen de sus inspecciones
  genéricas al encontrar los dos botones nuevos, sin cambiar aserciones.
  Total heredadas gráficas: **1067/0**, registro V02-T02-graficos.log.
- Nueva test_equipment_window.gd: **1745/0**, las cuatro combinaciones en
  1280×720 y 960×540; selección por ratón/Tab/Enter, datos combinados, impactos,
  recargas, bloqueo final, entradas mantenidas, tres reinicios por combinación
  y resolución, retorno y cambio posterior. 32 finales únicos por combate real.
  Reutiliza las comprobaciones previas y adapta salud/básico al recurso de arma;
  no cambia ni retira cobertura heredada.
- 32 capturas de selector, juego, victoria y derrota; todas inspeccionadas en
  cuatro láminas V02-T02-*-revision.png. Sin recortes, paneles sobre jugador o
  defectos visuales bloqueantes. Imágenes originales identificadas mediante
  tamaño y SHA256 en V02-T02-capturas.json. El arte sigue siendo provisional.
- Exportación release Windows x86_64 real con plantillas oficiales 4.6.3.
  V02-T02-exportacion.log. El PCK exportado pasó **225/0** de equipamiento en
  Godot Linux mediante --main-pack, con script externo (V02-T02-pck.log).
  El binario de plantilla Linux rechaza --main-pack; no se presenta como
  validado con esa plantilla, ni como ejecución Windows.

### Comandos reproducibles
Godot `4.6.3.stable.official.7d41c59c4`. Cada suite gráfica:
`DISPLAY=127.0.0.1:98 godot --path game --display-driver x11 --audio-driver Dummy --script res://tests/<suite>.gd -- --output-dir=/tmp/dragons-t02-graphics`.
Xorg dummy debe estar vivo en la misma sesión y aceptar TCP loopback. La suite
nueva utilizó display 99. El servidor y Godot deben compartir la sesión de red.
Exportación: `godot --headless --path game --export-release 'Windows x86_64' ../builds/v02-t02/windows/DragonsAndTitans.exe`.
PCK: `godot --headless --main-pack builds/v02-t02/windows/DragonsAndTitans.pck --script <ruta-absoluta>/game/tests/test_equipment.gd`.

### Paquete y límites
ZIP: `DragonsAndTitans-v0.2-t02-rc1-windows-x86_64-daa8a1b.zip`,
35 989 183 bytes; SHA256:
`0c67ede60e76449ed8026d5e93a01ff0bd12a859e1070d0ea5bf0a9cbf5872b7`.
PE x86_64, cabecera PCK, CRC ZIP, extracción limpia y hashes de cinco archivos
verificados con verify_package de tools/package_windows.py. Incluye EXE, PCK,
LEEME, VERSION.json, licencias Godot y SHA256SUMS.txt. Informe V02-T02-paquete.json.

La descarga del candidato está enlazada en el resumen actual y README. No es
una release de GitHub. Se conserva el paquete V0.1. No se han ejecutado pruebas
nativas Windows, sesión humana V0.2, GPU física ni rendimiento prolongado.
La aceptación de laptop sigue pendiente. Preparado V02-T02-prueba-windows.md.
Próximo hito acordado: T03 visual (primer dragón propio más detallado/animado).
No se inició en este cierre ni se hizo merge.

## V0.2 T03 — Presentación Cobre: evidencia y límites

Primer incremento propio y estilizado, no arte final: hocico facetado, placas,
escamas, cuernos, dientes, garras y nervaduras. Aleteo, cola, flotación, mandíbula
al atacar, impacto y pliegue/descenso visual al morir. Datos de balance y
colisiones intactos. Indicador de arma reducido y colocado al flanco. Fuente y
procedencia en docs/arte/COBRE.md. Sin dependencias nuevas ni servicios de pago.

Durante regresión se detectó que animar la raíz Facing introducía pitch al
apuntar. Se corrigió transformando exclusivamente sus hijos; test_t02 volvió
a aprobar sus 34 comprobaciones sin cambiar aserciones.

Pruebas Godot 4.6.3 Compatibility/Linux:
- Importación final sin errores de scripts.
- Once suites lógicas heredadas, 793/0; nueva test_presentation.gd 13/0.
  Total lógico 806/0. Registro docs/validacion/V02-T03/logica.log.
- Equipamiento en ventana: 1745/0. Cuatro combinaciones, dos resoluciones,
  controles de selección, daño, recargas, resultados, entradas y reinicios.
- Presentación en ventana: 13/0, incluida comprobación final tras cerrar la
  punta del hocico. Capturas de cámara normal en 1280×720 y 960×540 y vista
  cercana de inspección. Lámina de 32 capturas de integración inspeccionada:
  sin recortes visibles de HUD ni paneles que tapen al jugador.
- PCK del ZIP exportado: 225/0 de equipamiento mediante Godot Linux.
  Esto no prueba el ejecutable Windows. Registro pck.log.
- Métrica de geometría de Cobre: 80 MeshInstance3D visibles y 7998 triángulos
  en sus mallas, EXCLUYENDO CSG de membranas. 46 hijos adicionales en
  CobreDetails y seis nervaduras adicionales; radio físico medido 0.8.
  No equivale a draw calls, total GPU ni presupuesto final de polígonos.
- Mesa llvmpipe/OpenGL 4.5, Xorg dummy TCP. Aviso de V-Sync sin soporte.
  No se midieron FPS de GPU física, consumo ni rendimiento prolongado.

Comandos: `godot --headless --path game --script res://tests/test_presentation.gd`;
misma forma para suites heredadas. Para ventana, Xorg con configuración dummy
previa y `DISPLAY=127.0.0.1:94 godot --path game --display-driver x11
--audio-driver Dummy --script res://tests/test_equipment_window.gd --
--output-dir=/tmp/dragons-t03-graphics`. Evidencia en docs/validacion/V02-T03/.

Exportación real Windows x86_64 release con plantillas oficiales 4.6.3:
`python tools/package_windows.py --ref f5a5dcc --version-label 0.2-t03-rc1
--templates <directorio-plantillas-4.6.3> --output-dir builds/v02-t03`.
Paquete DragonsAndTitans-v0.2-t03-rc1-windows-x86_64-f5a5dcc.zip,
35 997 208 bytes; SHA256
`404c14e6c8e46cbfc3e1e72ce2e78767c84068e58ad4ce5bf362c41e3a47acb8`.
CRC, extracción, hashes, cabecera PE x86_64 y PCK comprobados.

Windows nativo y prueba humana de T03 pendientes. El escenario, Jade, materiales
avanzados, rig y clips importados no forman parte de este incremento. Siguiente:
publicar rama tras autorización y recoger la valoración visual del usuario en
laptop; después refinar anatomía/membranas y avanzar con arena/Jade. No iniciar
multijugador ni sustituir entregas anteriores.

## V0.2 T04 — Membranas y arena de piedra

T03 quedó publicada tras autorización del usuario: cb26867 en
feat/v0.2-t03-cobre-animado, contenido idéntico al árbol local d3793b2.
En esta continuación se crea feat/v0.2-t04-alas-y-arena, sin merge.

Cobre: membranas SurfaceTool dobles con borde cóncavo y comba; nervaduras
construidas con los mismos puntos y animadas con el mismo pivote. Se ocultan
las alas CSG anteriores solo en Cobre; cuatro placas conectan pecho/cuello.
Arena: juntas, roseta, marca +/-10 para centros, cuatro ruinas y rocas exteriores.
No se añaden colisiones, luces ni dependencias; arte original procedural.
Jade y enemigo conservan sus modelos, balance y controles intactos.

Godot 4.6.3 Compatibility/Linux: importación correcta; 810 comprobaciones
lógicas (793 heredadas + presentación ampliada 17), todas aprobadas.
Ventana X11/llvmpipe: presentación 17/0, equipamiento 1745/0 con cuatro
combinaciones, 1280x720 y 960x540, victoria/derrota y reinicios. 32 capturas y
las vistas cercana/jugables revisadas; sin recortes del HUD observados.
PCK exportado con script externo de equipamiento: 225/0 en Godot Linux.
Comandos: godot --headless --path game --script res://tests/<suite>.gd;
DISPLAY=127.0.0.1:97 godot --path game --display-driver x11 --audio-driver Dummy
--script res://tests/test_equipment_window.gd -- --output-dir=/tmp/dragons-t04-graphics.
Xorg dummy debe iniciarse y estar listo en la misma sesión. Los primeros
intentos X11 fallaron antes del arranque por disponibilidad del display;
se resolvió esperando su inicio. Aviso de V-Sync no soportado por llvmpipe.

Código local exportado: 2b4510b. ZIP Windows real preparado con
python tools/package_windows.py --ref 2b4510b --version-label 0.2-t04-rc1
--templates <plantillas-oficiales-4.6.3> --output-dir builds/v02-t04.
DragonsAndTitans-v0.2-t04-rc1-windows-x86_64-2b4510b.zip: 36000777 bytes;
SHA256 01bf3b6e4352dfff6f660d3075e4b40e0ba59c9143a7d229de71103743549b51.
CRC, extracción limpia, hashes y PE x86_64 verificados por empaquetador.
El ZIP está enlazado en README; conserva candidatos anteriores.
Evidencia: docs/validacion/V02-T04. Publicación por API (Git HTTPS sin
credenciales): commit remoto distinto, árbol de contenido idéntico al local.

Limitaciones: Windows nativo, valoración humana T04, GPU física y rendimiento
prolongado pendientes. No es arte final: geometría procedural sin rig importado
ni texturas. Próximo incremento visual: Jade; recoger feedback de laptop.

## V0.2 T05 — Acabado de Cobre, Jade y Sentinela

Autorización del usuario: completar el acabado visual de los dragones.
Rama feat/v0.2-t05-dragones-modelados, desde T04 local a158004. T04 remoto
f74b9c4 tiene ese mismo árbol. Se conservan las entregas previas; sin merge.

### Implementación
Se retiran los modelos de primitivas/CSG del jugador y enemigo. Se integran
GLB originales producidos con Blender 4.3.2: cuello curvo, cráneo/hocico,
mandíbula, ojos/iris/pupilas, fosas nasales, cuernos, placas, patas y dedos,
membranas combadas, cola. Cobre robusto, Jade esbelto de alas mayores y enemigo
Sentinela azul/cian. Son variantes de una anatomía compartida original.
Piel con textura de escamas de 256x256; siete materiales y una malla skinned
por GLB. 8669 vértices exportados, 15332 triángulos y 16 huesos por variante.
No se equiparan vértices Blender con vértices exportados ni materiales con
draw calls. Métricas/hash exactos: modelos.json.

Clips Flight/Attack/Hit/Death: alas y puntas desfasadas, cola/patas, mandíbula,
reacción y muerte sostenida. Los temporizadores de reacción usan la duración
real del clip. Señales de ataques aceptados disparan animación; las recargas
bloqueadas no la reinician. El rig nunca transforma actor físico ni Facing.
Materiales y animaciones locales por instancia. Se mantienen datos de balance.
La galería permite inspeccionar los tres modelos y cuatro clips, girar,
acercar y volver al menú con selección/equipo intactos.

Fuente reproducible: tools/art/build_dragons.py; recursos en game/assets/dragons.
Documentación/procedencia/límites: docs/arte/DRAGONES_3D.md. Sin modelos,
texturas ni animaciones extraídos de terceros; sin servicios o dependencias
de pago. Blender solo se requiere para editar/regenerar, no para jugar.

### Validación final Godot 4.6.3 Compatibility/Linux
- Importación limpia; doce suites de lógica: 806/0. La prueba de paletas antiguas
  se sustituyó por aislamiento de materiales GLB y comprobación del modelo real;
  las cuentas no son directamente comparables con T04.
- Presentación en ventana: 44/0. Comprueba hueso de ala animado, skin/textura,
  aislamiento físico, señales reales, muerte de ambos actores y reinicios.
- Galería en ventana: 58/0. Clic real en acceso/selección/clips, controles visibles
  en 1280x720 y 960x540, arrastre, rueda y vuelta conservando carga.
- Equipamiento en ventana final: 1777/0. Cuatro combinaciones en dos resoluciones,
  combate, victoria/derrota, entradas mantenidas y reinicios. La nueva parada de
  foco añade comprobaciones respecto al menú anterior. Total gráfico: 1879/0.
- 32 capturas de integración, seis de galería, ocho de presentación y dos de menú
  revisadas. Lámina comparativa basada en capturas reales; sin recortes del HUD
  o botones observados. Galería/cámara cercana no equivalen a FPS de laptop.
- Paquete exportado: equipamiento 225/0 y modelos 44/0 mediante Godot Linux
  --main-pack y scripts externos absolutos. No prueba el .exe nativo.

Durante revisión se corrigió oclusión del iris por la cuenca y se sustituyeron
placas esféricas por escudos facetados. La primera prueba de galería a 960 falló
por coordenadas sintéticas lógicas; se corrigió la simulación a píxeles nativos,
como las pruebas de UI existentes. Tras ajustar las reacciones a la duración
real de los clips, se amplió la espera de la prueba de vuelta al vuelo; versión
final sin fallos. No se recortaron clips para satisfacer un tiempo antiguo.

Comandos: blender -b --python tools/art/build_dragons.py;
godot --headless --path game --editor --import --quit;
godot --headless --path game --script res://tests/<suite>.gd.
Ventana: Xorg dummy TCP listo en la misma sesión;
DISPLAY=127.0.0.1:102 godot --path game --display-driver x11 --audio-driver Dummy
--script res://tests/test_equipment_window.gd -- --output-dir=/tmp/dragons-t05-final.
Galería/modelos: test_gallery.gd y test_presentation.gd con las mismas opciones.
Mesa llvmpipe/OpenGL 4.5; aviso de V-Sync no soportado. GPU física no probada.

### Entrega
Código local exportado 01646a3; publicación por API genera commit remoto distinto
con el mismo contenido. ZIP real Windows x86_64 release usando plantillas
oficiales Godot 4.6.3 y tools/package_windows.py, etiqueta 0.2-t05-rc1.
DragonsAndTitans-v0.2-t05-rc1-windows-x86_64-01646a3.zip: 36814955 bytes;
SHA256 178e2b0464d4f099c9b862722e264e5392ada18c399f8ba14c78db7cd4f489c4.
ZIP CRC, extracción limpia, hashes y cabeceras PE/PCK verificadas. Descarga en
README; evidencia completa en docs/validacion/V02-T05.

El lote visual solicitado queda implementado y validado como candidato
estilizado, sin afirmar arte final cinematográfico. Windows nativo, aceptación
artística humana y rendimiento físico/prolongado pendientes. El rig usa pesos
por regiones, no deformación orgánica avanzada. Próximo: prueba de laptop y
feedback antes de cambiar de dirección artística; después hito de objetivos/bots.

## V0.3 T01 — Captura de balizas

La arena adicional comparte el combate, equipo y dragones 3D del duelo.
Dos balizas se capturan al permanecer dos segundos dentro de cada zona.
Salir antes de completar la captura reinicia su progreso. Las zonas ya
capturadas se mantienen hasta reiniciar. La victoria exige capturar ambas
y abatir al Sentinela, en cualquier orden. Si cae el jugador, pierde.

Godot 4.6.3 Compatibility en Linux: importación limpia, objetivo 15/0 en
headless y en ventana de 960×540, selector 64/0, estados 51/0, partida 46/0,
equipamiento 225/0 y galería en ventana 58/0. El renderizado se ejecutó
con Mesa llvmpipe. Pendientes prueba nativa de Windows y rendimiento en GPU.

## V0.3 T02 — Asedio de la Caldera

Nuevo modo offline 2 contra 2 con un aliado IA, dos rivales IA y dos
núcleos vulnerables a las armas y habilidades existentes. Los bots eligen
amenazas cercanas o atacan el núcleo contrario. Victoria por destruir el
núcleo rival. Derrota si cae el jugador o su núcleo, con prioridad en empate.
El reinicio conserva el equipo elegido y recarga la arena. Posiciones, salud,
alcance y reglas del modo son provisionales y propios.

Arte original generado en Godot: terreno procedural de basalto y lava,
pavimento, rocas, núcleos, sombras, estelas e impactos. Los GLB existentes
añaden inclinación lateral puramente visual. El HUD táctico tiene reloj,
minimapa, estado de núcleos, salud por actor y recargas. La captura corresponde
al render del juego en Linux.

Godot 4.6.3 Compatibility, Linux: 20/0 en headless, 20/0 a 1280×720 y 20/0 a
960×540 con llvmpipe. Regresiones de selector, estados, equipamiento, balizas,
núcleo de combate, proyectil Q y pulso E: 541 comprobaciones sin fallos.
Validación nativa de Windows y rendimiento en laptop pendientes. Se entrega
proyecto fuente importable en Godot.

## V0.3 T03 — Torres y vuelo al cursor

Cada torre dispara a dragones rivales cercanos y protege su propio núcleo.
Cuando cae, los bots pasan a atacar el núcleo y el HUD cambia el objetivo.
Se agregaron clic derecho o Shift para avanzar hacia el cursor, Espacio para
retirarse y rueda para el zoom. WASD tiene prioridad mientras se pulsa.
Validado en Linux con 27 comprobaciones de asedio headless, 30 por resolución
en ventana y 325 regresiones headless, sin fallos. Windows sigue pendiente.
La bóveda de continuidad queda en `docs/obsidian`.

## V0.3 T04 — Arte de los dragones y la Caldera

Se regeneraron los GLB originales de Cobre, Jade y Sentinela con nuevas
siluetas de alas, armaduras y cuernos y texturas de piel y membranas de
512×512. Se conservaron 16 huesos y los clips de vuelo, ataque, impacto y
muerte. La Caldera incorpora acantilados, islas, bruma baja y basalto
agrietado. Las reglas de asedio y los límites jugables se conservan.

Asedio: 27/0 headless y 30/0 en cada resolución, 1280×720 y 960×540.
Galería: 58/0. Capturas Linux en `docs/validacion/V03-T04`. Windows y
rendimiento físico pendientes. Bóveda actualizada en `docs/obsidian`.

## V0.3 T05 — Relieve e impactos

Cobre, Jade y Sentinela reciben mapas de normales de 512×512 para piel
y membranas, además de cambios en la línea mandibular, ojos y cejas.
Las rocas de la Caldera reciben un mapa de relieve procedural. Los impactos
de proyectiles del asedio muestran destello, onda expansiva y nueve chispas
con un MultiMesh, agrupados para su limpieza al finalizar. Las reglas de
daño, escudo, vida y recarga se mantienen.

Validación Linux con Godot 4.6.3 Compatibility: asedio 29/0 headless,
32/0 a 1280×720 y 32/0 a 960×540; galería 58/0 y modelos 46/0.
Regresiones de combate, pulso, Q y balizas: 201/0. Capturas reales en
`docs/validacion/V03-T05`. Pendientes Windows nativo y medición en laptop.

## V0.4 T01 — Frontera de Ceniza 5v5 offline

Mapa original de hielo y lava de 101×58 unidades visuales, tres carriles
convergentes, seis torres, dos núcleos y diez dragones. El usuario juega
junto a cuatro bots contra cinco bots. Caen las tres torres de un lado
para abrir su núcleo; destruirlo decide la partida. Los dragones reaparecen
a los seis segundos con salud y recargas restauradas. HUD con bajas y
minimapa, vista táctica con M y cámara de seguimiento con zoom.

Godot 4.6.3 Compatibility en Linux: 16/0 a 1280×720 y 960×540. Simulación
automática de 35 s con 12 bajas y pico de cuatro proyectiles. Regresiones:
selector 64/0, asedio 29/0, balizas 15/0 y equipamiento 225/0. Windows,
rendimiento en laptop y balance humano pendientes. Afueras rocosas
decorativas, con límite de vuelo rectangular. Partida offline con IA.

## V0.4 T02 — Oleadas, retirada y Jade

Frontera recibe unidades ligeras por carril en ambos equipos. Avanzan,
atacan enemigos cercanos y desaparecen al morir, reiniciar o acabar la partida.
Primera oleada a 5 s, cadencia 12 s, máximo de dos unidades vivas por carril
y equipo. Los bots heridos interrumpen la persecución, regresan a su punto
de salida y se recuperan. Umbrales de retirada y regreso: 25 % y 75 %.
Jade usa un GLB original actualizado y conserva la selección de habilidades.

Godot 4.6.3 Compatibility en Linux: 22/0 en headless y 22/0 a 1280×720 y
960×540. Galería 58/0. Regresiones: asedio 29/0, T03 52/0, núcleo 51/0 y
balizas 15/0. Prueba humana de balance y rendimiento en Windows pendientes.

## V0.4 T03 — Cobre y ruptura del núcleo

Cobre lleva un jinete con yelmo, silla oscura, dos cuernos de basalto, espolón nasal y brazales con engastes turquesa. La membrana ámbar tiene bandas oscuras. El disparo básico produce una llamarada breve en la boca. Conserva el esqueleto y los cuatro clips de la versión anterior. La lámina original y el render del GLB están en `docs/arte`.

En Frontera de Ceniza, la lista lateral muestra la salud de los cinco aliados. Al caer un núcleo se cierra el combate, la cámara viaja hasta el objetivo y el cristal se rompe. Tras 2,7 s aparecen el resultado, las bajas, la duración y la oleada. La derrota usa el núcleo aliado. R permite reiniciar incluso durante la secuencia.

Validación en Linux con Godot 4.6.3 Compatibility sin ventana. Frontera 27/27, combate 51/51, equipamiento 225/225. El render procede del GLB en Blender. Quedan pendientes la inspección de la cinemática en pantalla y una partida completa con una persona en Windows.

## V0.4 T04 — Ángeles, demonios y anuncio de victoria

En Frontera de Ceniza, la primera oleada aparece a los cinco segundos. Los tres carriles aliados reciben ángeles con plumas, aureola y lanza. Los tres rivales reciben demonios con cuernos, cola y alas membranosas. Los modelos originales se generan en Blender con `tools/art/build_minions.py` y sus alas se animan durante el combate.

El estallido del núcleo rival muestra VICTORIA en el mismo instante. La ruptura del núcleo aliado muestra DERROTA. El cartel deja despejado el cristal y da paso al resumen con las bajas y la opción de reiniciar.

Godot 4.6.3 Linux sin ventana. Frontera 35/35. Inspección de ambos GLB en un render de Blender. Pendiente revisión en una partida en Windows.

## V0.5 T01 — Nethergate 5 contra 5

En el selector, elige Nethergate para volar entre islas sobre un barranco. En cada una de las tres runas, el equipo con más dragones vivos presentes avanza la captura. Las runas aceleran la carga del titán de su equipo. El titán marcha contra la puerta y su primer impacto desactiva el escudo. Escolta al aliado o intercepta al enemigo. Al romper la puerta aparece el resultado y emerge el titán liberado.

Inspiración visual y reglas generales: pantalla de carga y capturas de Nethergate aportadas por el jugador. Geometría, materiales, número y ubicación de las runas, tiempos, resistencia y daño son decisiones del prototipo. Juego local con nueve bots.

Código probado `4eae7b8`. Godot 4.6.3 Compatibility en Linux sin ventana. Nethergate 13/13 y Frontera 35/35. Una simulación con el jugador inactivo terminó en derrota a los 63,7 s. El servidor gráfico no pudo abrir la pantalla. Pendiente comprobar en Windows la legibilidad de las runas, el agua, el anuncio final y el ritmo de una partida humana.

## V0.5 T02 — Atlas y duelo LAN

F5 abre el atlas ilustrado. Elige un destino para leer el objetivo y entrar. Dragones y equipo abre el selector. Guía de modos resume los seis destinos jugables y explica los modos pendientes ARAM, Aventura y Capture Points de cinco puntos.

Para jugar entre dos PC, abre el mismo proyecto en ambos con Godot 4.6.3. En una misma red, elige Multijugador LAN → Abrir sala LAN. El anfitrión pulsa Crear sala y comparte la IP mostrada. El invitado introduce esa dirección y pulsa Unirme. La sala usa UDP 27940. Si Windows pide permiso al juego para la red local, permite redes privadas. WASD mueve al dragón, el cursor apunta y el clic izquierdo dispara. Cada dragón comienza con 100 PV. El primer derribo termina el duelo. Salir al atlas permite comenzar una sala nueva.

Las Agujas es un duelo entre Cobre y Jade con estadísticas iguales. El anfitrión resuelve movimiento, daño y resultado. Los mapas 5v5 mantienen sus nueve bots. Ilustración original generada para el atlas en esta entrega.

Código probado `ad7c032`, rama `feat/atlas-duelo`. Dos procesos Linux con ENet por 127.0.0.1 verificaron el selector, la conexión, movimiento, daño y resultados opuestos. Frontera 35/35 y Nethergate 13/13. Pendiente inspección gráfica y prueba entre dos PC Windows en una misma red.

## V0.6 — Códice y modos del atlas

Extrae el ZIP, importa `game/project.godot` en Godot 4.6.3 y pulsa F5. El Códice de los jinetes ofrece búsqueda por sección. El Pacto, Cinco bastiones, Halvalas y Mire Bog se seleccionan directamente en el mapa. Las cantidades de oro, tiempos y balance son provisionales.

Consulta `docs/obsidian/Wiki y cobertura jugable.md` para ver las fuentes, las diferencias y el alcance por modo.

## v0.7.1 · Laboratorio de vuelo

Escena de formas básicas conectada al atlas. Comparación y ajustes en [[Práctica de vuelo]]. Verificar el tacto con ratón en Windows. Siguiente sistema de la serie: disparo.

Pruebas en Godot 4.6.3 sin ventana: siete comprobaciones del laboratorio, treinta y cuatro del controlador previo y recorrido automatizado de Proving Grounds. La sesión carece de pantalla gráfica habilitada para guardar la comparación visual.
