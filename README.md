# DRAGONS AND TITANS

Recreación independiente y progresiva. El primer hito es una arena offline;
el estado actual incorpora **T01–T03**: arena iluminada, dragón provisional,
movimiento, apuntado, cámara de seguimiento y combate básico contra un enemigo.
Las habilidades y la interfaz completa de fin de partida siguen pendientes.

## Requisitos

- **Godot 4.6.3 estable**, edición estándar con GDScript (no hace falta .NET).
  Versión usada: `4.6.3.stable.official.7d41c59c4`.
- Renderizador **Compatibility** (`gl_compatibility`), configurado en el proyecto.
- Plataforma objetivo: PC Windows. Las comprobaciones de esta entrega se realizan
  en Linux; no hay exportación ni ejecución nativa en Windows verificada todavía.

Descargar la edición correspondiente al sistema desde la
[publicación oficial de Godot 4.6.3](https://github.com/godotengine/godot/releases/tag/4.6.3-stable).
Extraer el ZIP en una carpeta local. No requiere paquetes, plugins ni credenciales.

## Abrir y ejecutar

En el gestor de proyectos de Godot, elegir **Importar**, seleccionar
`game/project.godot` y abrirlo. Pulsar **F6** para ejecutar la escena abierta o
**F5** para la escena principal. Deben aparecer la arena azul grisácea, un dragón
cobrizo con alas y cola, un enemigo cian y un panel de controles y salud.

Desde la raíz del repositorio, con `godot` en el `PATH` (Linux):

```bash
godot --version
godot --editor --path game
godot --path game
```

En PowerShell (Windows), ajustar la ruta a la carpeta extraída:

```powershell
# Ejecutar desde la raíz del repositorio.
$Godot = 'C:\Herramientas\Godot_v4.6.3-stable_win64.exe'
& $Godot --version
& $Godot --editor --path .\game
& $Godot --path .\game
```

Cerrar la ventana para terminar. No se ha generado un ejecutable Windows.

## Controles provisionales de T02–T03

| Entrada | Función implementada |
| --- | --- |
| W / S | Mover hacia arriba / abajo en pantalla |
| A / D | Mover hacia izquierda / derecha en pantalla |
| Ratón | Orientar el hocico hacia el cursor sobre el plano de vuelo |
| Clic izquierdo mantenido | Disparar un proyectil por intervalo de recarga |
| R | Restaurar la arena completa en cualquier momento (recarga de escena) |

WASD usa teclas físicas mediante `move_forward`, `move_back`, `move_left` y
`move_right` en Input Map. El movimiento usa los ejes horizontales de la cámara,
independientemente de dónde apunte el dragón. La diagonal no aumenta la velocidad.
La altura es fija: no hay ascenso ni descenso. El cursor muy próximo al centro
del dragón conserva la orientación anterior para evitar giros indeterminados.

La raíz del dragón solo se traslada en física; el hijo `Facing` gira. La cámara
hereda la traslación sin girar y usa interpolación física. El controlador exporta
velocidad (6 unidades/s), altura (1.5), semitamaño de arena (12×12) y margen (2).
El centro queda limitado a X/Z entre −10 y 10, suficiente para la silueta actual
de radio máximo 1.95. La cámara conserva el ángulo de T01 y ajusta su tamaño
ortográfico a 18 para hacer legible el personaje. Todos estos valores son
**provisionales**. Q/E todavía no están implementadas.

## Combate provisional de T03

El jugador cobrizo y el enemigo cian pertenecen a facciones rivales. El enemigo
persigue y ataca dentro de alcance; se detiene si él o el jugador mueren. Los
actores muertos no se mueven ni generan nuevos ataques. El panel muestra salud,
recarga y si un actor ha caído; no hay todavía pantalla de victoria/derrota (T05).

| Parámetro exportado | Jugador | Enemigo |
| --- | --- | --- |
| Salud máxima | 100 | 80 |
| Daño básico | 20 | 10 |
| Recarga | 0.4 s | 1 s |
| Velocidad de proyectil | 28 unidades/s | 28 unidades/s |
| Duración del proyectil | 2 s | 2 s |
| Velocidad de movimiento | 6 unidades/s | 3 unidades/s |
| Alcance de ataque de IA | — | 7 unidades |

Son valores **provisionales**, no estadísticas originales. Se ajustan en los
actores y sus nodos `Weapon`; no hay balance embebido en la interfaz.
La colisión usa una esfera central de radio 0.8 por actor; alas y cola son
cosméticas. Los actores se limitan a la arena por posición, sin bloquearse entre sí.
El proyectil hace un raycast continuo de todo su trayecto físico, incluido el
tramo inicial entre el actor y el hocico, para evitar saltarse objetivos cercanos
o atravesarlos por velocidad. Ignora emisor, aliados y muertos; aplica daño una
sola vez al primer hostil válido y se elimina. También caduca si no impacta.
Un proyectil ya disparado puede terminar su vuelo tras morir su emisor.

**R** recarga `res://scenes/arena.tscn`: restablece salud, posiciones, orientación,
recargas y objetivo de IA; elimina todos los actores y proyectiles anteriores.
Es la restauración mínima de T03, no un sistema de estados de partida.

## Comprobaciones reproducibles

Desde la raíz, con Godot 4.6.3:

```bash
godot --headless --path game --import
godot --headless --path game --script res://tests/test_t02.gd
godot --headless --path game --script res://tests/test_combat_core.gd
godot --headless --path game --script res://tests/test_t03.gd
godot --headless --path game --quit-after 120
```

En PowerShell, usar `& $Godot` en lugar de `godot` y `--path .\game`.
Los comandos deben terminar con código 0 y sin errores. La regresión T02 conserva
34 comprobaciones de movimiento, límites, apuntado y cámara. El núcleo añade 51
comprobaciones de salud, facciones, recargas y barridos físicos reales (incluido
un proyectil a 600 unidades/s); la integración T03 añade 52 comprobaciones de
entrada, IA, muerte y tres restauraciones de la escena completa.
En headless no hay cursor OS: las pruebas de apuntado dan coordenadas explícitas
al mismo método que usa el controlador. El último comando carga la escena
principal durante 120 iteraciones; **headless no valida la imagen ni el manejo**.
Comprobar también visualmente con `godot --path game` (o F5).

Con un servidor gráfico disponible en Linux se puede ejecutar la prueba de ventana:

```bash
godot --path game --audio-driver Dummy --script res://tests/test_t02_window.gd -- --output-dir=/tmp/dragons-t02
```

Usa el Input Map con eventos de teclas físicas, el paso de física real y el cursor
de la ventana; recorre las cuatro esquinas, comprueba seguimiento/apuntado y guarda
dos capturas. Debe terminar con 22 comprobaciones y 0 fallos. Es automatizada;
no sustituye una sesión humana de manejo prolongada ni la validación Windows.

Combate gráfico T03, con el mismo servidor gráfico disponible:

```bash
godot --path game --audio-driver Dummy --script res://tests/test_t03_window.gd -- --output-dir=/tmp/dragons-t03/graphics
```

Esta prueba usa eventos de clic y R, el cursor de la ventana y física real:
dispara, recibe daño, abate al enemigo, restaura tres veces y deja que la IA
derrote al jugador. Guarda capturas de combate, enemigo abatido y jugador caído.
La regresión T02 pausa únicamente la IA en su montaje para aislar movimiento y
cámara; conserva todas sus aserciones. La prueba de T03 cubre la IA activa.

La caché `game/.godot/` se regenera y está excluida de Git. Si un contenedor Linux
no permite escribir en el directorio de usuario, preparar directorios escribibles
antes de ejecutar los comandos anteriores:

```bash
mkdir -p /tmp/dragons-t01/cache /tmp/dragons-t01/data /tmp/dragons-t01/config
export XDG_CACHE_HOME=/tmp/dragons-t01/cache
export XDG_DATA_HOME=/tmp/dragons-t01/data
export XDG_CONFIG_HOME=/tmp/dragons-t01/config
```

## Estructura y recursos

- `game/project.godot`: configuración y escena de entrada.
- `game/scenes/arena.tscn`: suelo, entorno, luz, dragón y panel de controles.
- `game/scenes/dragon.tscn`: composición del controlador, representación y cámara.
- `game/scenes/dragon_visual.tscn`: geometría provisional propia, sin lógica.
- `game/scripts/dragon_controller.gd`: movimiento, límites y orientación.
- `game/scripts/combat_actor.gd`: salud, facciones y señales de daño/muerte.
- `game/scripts/weapon.gd` y `projectile.gd`: recarga, disparo y barrido físico.
- `game/scripts/enemy_controller.gd` y `game/scenes/enemy.tscn`: IA y visual cian propio.
- `game/scripts/arena.gd`: composición, salud visible y restauración mínima.
- `game/tests/`: pruebas de integración headless y de ventana.
- `docs/IMPLEMENTACION.md`: tareas y aceptación de V0.1.
- `docs/ESTADO.md`: resultados, limitaciones y siguiente paso para cualquier IA.

La geometría y los materiales de la arena, los dos actores y el proyectil se crearon para este
repositorio con primitivas de Godot y polígonos CSG para las membranas de las alas;
no contienen arte del juego original ni recursos de terceros.
Las dimensiones, colores y cámara son decisiones **provisionales** del prototipo,
no datos verificados de Dragons and Titans. Los datos de combate y recursos
adicionales se añadirán cuando las siguientes tareas los necesiten.
