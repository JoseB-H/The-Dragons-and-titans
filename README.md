# DRAGONS AND TITANS

Recreación independiente y progresiva. El primer hito es una arena offline;
el estado actual incorpora **T01 y T02**, con arena iluminada, dragón provisional,
movimiento, apuntado y cámara aérea oblicua de seguimiento. El combate sigue pendiente.

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
cobrizo con alas y cola, y un panel de controles.

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

## Controles provisionales de T02

| Entrada | Función implementada |
| --- | --- |
| W / S | Mover hacia arriba / abajo en pantalla |
| A / D | Mover hacia izquierda / derecha en pantalla |
| Ratón | Orientar el hocico hacia el cursor sobre el plano de vuelo |

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
**provisionales**. No funcionan todavía ataques, Q/E ni reinicio de partida.

## Comprobaciones reproducibles

Desde la raíz, con Godot 4.6.3:

```bash
godot --headless --path game --import
godot --headless --path game --script res://tests/test_t02.gd
godot --headless --path game --quit-after 120
```

En PowerShell, usar `& $Godot` en lugar de `godot` y `--path .\game`.
Los comandos deben terminar con código 0 y sin errores. La suite ejecuta 34
comprobaciones de movimiento, límites, apuntado y cámara sobre la escena real.
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
- `game/tests/`: pruebas de integración headless y de ventana.
- `docs/IMPLEMENTACION.md`: tareas y aceptación de V0.1.
- `docs/ESTADO.md`: resultados, limitaciones y siguiente paso para cualquier IA.

La geometría y los materiales de la arena y del dragón se crearon para este
repositorio con primitivas de Godot y polígonos CSG para las membranas de las alas;
no contienen arte del juego original ni recursos de terceros.
Las dimensiones, colores y cámara son decisiones **provisionales** del prototipo,
no datos verificados de Dragons and Titans. Los datos de combate y recursos
adicionales se añadirán cuando las siguientes tareas los necesiten.
