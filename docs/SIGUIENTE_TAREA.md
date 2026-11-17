# Siguiente encargo para Codex — T02: Dragón y cámara

## Informe recibido y comprobación remota
El usuario transmite una entrega de Codex: T01 implementada con Godot 4.6.3 Compatibility, importación, arranque y renderizado comprobados en Linux; docs/ESTADO.md actualizado localmente. Windows pendiente. La versión específica comunicada por el usuario es Godot 4.6.3; comprobarla contra los archivos locales antes de fijarla como hecho del repositorio.

IMPORTANTE: en la revisión remota que originó este encargo, GitHub solo devolvió la rama main y docs/ESTADO.md todavía mostraba T01 pendiente. No se pudo contrastar el informe local ni sus pruebas. No se declara T01 validada independientemente.

## Paso previo: conservar y sincronizar T01
Lee AGENTS.md y todos sus documentos obligatorios. Inspecciona rama, estado Git y archivos reales antes de modificar. Si T01 existe localmente, conserva sus cambios y revisa su evidencia; no recrees el proyecto. Recupera este encargo sin sobrescribir archivos locales. Si no existe T01 en tu entorno, localiza la entrega o informa el bloqueo antes de construir T02 sobre una base inexistente. Publica la entrega mediante la rama de trabajo y PR cuando el flujo autorizado lo permita; no hagas merge ni force push. Incluye SHA y rama en el informe para que la siguiente revisión pueda consultar el código.

## Implementación T02
1. Reutiliza la arena, luz y cámara de T01 y su versión real de Godot. No actualices motor sin necesidad.
2. Añade un dragón provisional propio reconocible por cuerpo, cabeza, alas y cola. Sin descargas de recursos originales.
3. Implementa movimiento WASD sobre XZ, altura visual fija, velocidad configurable y diagonal normalizada. Usa el paso de física para movimiento y aplica límites coherentes con la arena existente.
4. Orienta al dragón hacia el punto del cursor proyectado sobre el plano jugable. Maneja rayos sin intersección y evita inclinaciones involuntarias.
5. Añade cámara aérea oblicua que siga al jugador sin perderlo. El movimiento debe tener una relación clara con la pantalla; documenta la convención elegida.
6. Configura Input Map para movimiento y muestra controles visibles. Ataques, Q/E y reinicio de fin de partida pertenecen a tareas posteriores: no anunciarlos como funcionales todavía.
7. Mantén controlador, representación visual y parámetros simples de ajustar; evita construir sistemas de combate para completar T02.

## Aceptación
- Proyecto importa y escena principal arranca sin errores con la versión fijada.
- Dragón reconocible y visible desde la cámara de juego.
- WASD funciona y la velocidad diagonal no supera la axial.
- El dragón permanece dentro de los límites, incluidas esquinas.
- Apuntado estable con cursor en centro, bordes y cerca del dragón.
- Cámara sigue al jugador sin saltos perceptibles ni pérdida del personaje.
- Documentar resultados reales: las comprobaciones headless no prueban calidad visual o manejo interactivo.
- Windows sigue pendiente hasta probarlo realmente; no bloquea por sí solo el avance del prototipo en Linux.

## Cierre
Actualiza README y docs/ESTADO.md con controles, archivos, comandos reales, resultados, limitaciones y siguiente tarea T03. Adjunta captura si puedes obtenerla y referencia de commit/rama. Actualiza este encargo como completado solo tras cumplir la aceptación; no borres la evidencia de lo que queda sin comprobar.
