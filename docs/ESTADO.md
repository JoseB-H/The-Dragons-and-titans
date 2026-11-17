# Estado del proyecto

## Situación actual — candidato T06 (17 de noviembre de 2026)
**T01–T05 conservadas y regresiones repetidas en Linux** con Godot 4.6.3
Compatibility. T06 prepara un candidato **V0.1 RC1 Windows x86_64**, exportado
realmente en release desde un commit identificado, con ZIP íntegro y guía española.
El PCK exportado también pasó el ciclo gráfico completo en Godot Linux.
**Windows nativo y manejo humano/laptop siguen pendientes**; T06 no está validada
íntegramente. La release preliminar está bloqueada por `Forbidden` en la API:
el ZIP se conserva en el entorno y se entrega mediante enlace de archivo del chat,
sin URL estable de release verificada. Rama de código publicada, sin merge.
Continuidad del encargo main `c33bad1`: candidato e40276a/ZIP conservados,
integridad comprobada de nuevo y una única consulta API todavía `Forbidden`.
Registro Windows preparado en `docs/validacion/T06-prueba-windows.md`, pendiente
de resultados nativos del usuario; no se ha reexportado ni iniciado V0.2.

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
| T06 Validación y entrega | Candidato preparado; cierre parcial | Lógica Linux 365/0, gráfica de fuentes 250/0; exportación Windows/ZIP verificados; PCK en Linux 145/0. Windows nativo y release alojada pendientes |

## Próxima acción
Completar **T06** antes de V0.2: probar el candidato en Windows nativo/laptop con
la guía incluida y registrar sistema/GPU, resultados y capturas. Si aparece un
fallo, corregirlo antes de ampliar mecánicas. Publicar el mismo ZIP y sidecar en
una release preliminar ligada a `e40276a` cuando el acceso a GitHub API lo permita;
descargar ese artefacto y comparar el SHA256. No se hizo merge ni se modificó la
configuración de red para sortear el bloqueo. Conservar T01–T05 y esta rama T06.

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

## Limitaciones conocidas
- **Windows nativo pendiente:** se exportó un `.exe` release desde Linux, pero no
  se ejecutó en Windows. Editor, GPU/controladores Windows y guía de PowerShell
  siguen sin verificación nativa; exportación no equivale a compatibilidad probada.
- Validación gráfica mediante renderizado por software y entrada automatizada en
  Linux, con inspección de capturas. No hubo sesión humana prolongada de manejo,
  prueba de GPU física ni interacción con el escritorio compartido. El seguimiento
  se verificó por fotograma; la sensación de manejo requiere evaluación del usuario.
- T05 completa el ciclo offline; T06 aporta un candidato exportado, con ZIP y
  datos comprobados en Linux. La aceptación integral de V0.1 sigue pendiente.
- La prueba en laptop y Windows nativo siguen pendientes; release alojada
  bloqueada por acceso API. El ZIP local se entrega en el chat y no está en Git.
- Chat compartido no accesible durante la preparación inicial; no se presupone su contenido.
- Wiki pendiente de investigar y contrastar.
- Cinco capturas de referencia del usuario pendientes de incorporar al repositorio;
  la imagen de validación de T01 es propia y no sustituye esas referencias.

## Formato de actualización
Por cada incremento registrar: tarea, cambio, archivos, comprobaciones y resultados, limitaciones, decisiones provisionales y siguiente paso. Actualizar las filas de seguimiento sin borrar limitaciones aún vigentes.
