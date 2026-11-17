# DRAGONS AND TITANS

Recreación independiente y progresiva. El primer hito es una arena offline;
el estado actual implementa **T01: proyecto ejecutable**, con suelo, iluminación
y cámara aérea oblicua fija. Todavía no hay dragón, controles ni combate.

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
**F5** para la escena principal. Debe aparecer una plataforma cuadrada azul grisácea
iluminada, sobre fondo oscuro, vista desde arriba en diagonal.

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

Cerrar la ventana para terminar. Esta escena es estática; los controles pertenecen
a T02. No se ha generado un ejecutable Windows.

## Comprobaciones reproducibles

Desde la raíz, con Godot 4.6.3:

```bash
godot --headless --path game --import
godot --headless --path game --quit-after 120
```

En PowerShell, usar `& $Godot` en lugar de `godot` y `--path .\game`.
Ambos comandos deben terminar con código 0 y sin errores. La segunda comprobación
carga la escena principal durante 120 iteraciones; **headless no valida la imagen**.
Comprobar también visualmente con `godot --path game` (o F5).

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
- `game/scenes/arena.tscn`: suelo, entorno, luz y cámara.
- `docs/IMPLEMENTACION.md`: tareas y aceptación de V0.1.
- `docs/ESTADO.md`: resultados, limitaciones y siguiente paso para cualquier IA.

La geometría y los materiales de la arena se crearon para este repositorio con
primitivas de Godot; no contienen arte del juego original ni recursos de terceros.
Las dimensiones, colores y cámara son decisiones **provisionales** del prototipo,
no datos verificados de Dragons and Titans. Los scripts GDScript, datos de balance
y recursos adicionales se añadirán cuando las siguientes tareas los necesiten.
