# T01 — Plan de implementación

> Ejecución por IA: aplicar `superpowers:executing-plans` y comprobar el resultado con Godot real.

**Objetivo:** entregar únicamente T01 de V0.1: un proyecto que importe y abra una arena con suelo, luz y cámara.

**Especificación:** `AGENTS.md`, `docs/IMPLEMENTACION.md` (T01) y `docs/CONTEXTO_IA.md`.

**Arquitectura:** escena declarativa `Arena` en `game/scenes/arena.tscn`, referenciada por `game/project.godot`. No hace falta lógica de juego para este incremento; los scripts GDScript se incorporarán cuando tengan comportamiento que implementar.

**Tecnología:** Godot 4.6.3 estable, edición estándar (GDScript), Compatibility. Versión disponible en el entorno: `4.6.3.stable.official.7d41c59c4`.

## Restricciones y decisiones

- Reutilizar el checkout aislado en la nube; rama `feat/v0.1-t01-proyecto-ejecutable`.
- Plataforma objetivo inicial: PC Windows. Validar ahora en Linux y distinguir las comprobaciones no realizadas en Windows.
- Recursos: geometría y materiales propios, provisionales, sin descargas de arte ni servicios externos.
- No implementar T02–T06 ni atribuir dimensiones o cámara al juego original.
- No añadir directorios vacíos ni scripts sin comportamiento.

## Incremento único

Archivos: crear `.gitignore`, `game/project.godot` y `game/scenes/arena.tscn`; actualizar `README.md` y `docs/ESTADO.md`.

- [x] Leer los documentos, comprobar árbol limpio y sincronizar por avance rápido con `origin/main`.
- [x] Comprobar versión de Godot y observar que la importación falla antes de existir `game/`.
- [x] Configurar escena principal, viewport y Compatibility explícito; crear suelo, luz y cámara activa.
- [x] Añadir exclusiones y documentar versión, comandos Linux/Windows y procedencia de geometría.
- [x] Ejecutar `godot --headless --path game --import` y `godot --headless --path game --quit-after 120`; esperar salida 0 y ausencia de errores.
- [x] Abrir/renderizar la escena con OpenGL Compatibility e inspeccionar una captura si el entorno lo permite; registrar el método o la limitación.
- [x] Revisar cambios, exclusiones y documentación con un revisor independiente; actualizar `docs/ESTADO.md` con evidencia y T02 como siguiente tarea.

## Foco de revisión

- Escena principal ausente o ruta incorrecta: la ejecución debe abrir la arena sin selección manual.
- Renderizador inesperado: comprobar `gl_compatibility` configurado y el backend gráfico real cuando sea posible.
- Suelo fuera del encuadre o sin iluminar: inspección visual, no deducirlo de una ejecución headless.
- Caché local en Git: comprobar que `game/.godot/` está ignorado después de importar.
- Instrucciones que confundan Linux con Windows: comandos explícitos y limitaciones de plataforma registradas.
