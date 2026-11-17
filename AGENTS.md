# Instrucciones para agentes de programación

## Proyecto
DRAGONS AND TITANS. Recreación independiente y progresiva del juego de referencia. Este repositorio es la fuente de continuidad entre el usuario, ChatGPT, Codex y otras IA. No dependas de historiales de chat externos para entender las tareas.

## Lectura obligatoria
1. docs/CONTEXTO_IA.md
2. docs/PLAN_INICIAL.md
3. docs/IMPLEMENTACION.md
4. docs/ESTADO.md

## Ejecución
- Implementa la primera tarea pendiente del hito autorizado, verificando antes el estado real del código. El primer hito es el prototipo offline.
- Trabaja por incrementos ejecutables. No implementes todo el catálogo, servicios online ni sistemas de cuenta antes de validar el combate.
- Usa una rama de trabajo descriptiva; no fuerces pushes ni reemplaces trabajo ajeno. Si el usuario indica otra rama, respétala.
- Lee las instrucciones locales adicionales y conserva los cambios existentes.
- Las decisiones provisionales permiten avanzar en el prototipo: documéntalas sin atribuirlas al juego original.
- Motor base aceptado para planificar: Godot 4 y GDScript; plataforma inicial PC Windows. Selecciona y registra una versión estable concreta al preparar el proyecto, tras comprobar disponibilidad y compatibilidad.
- Mantén el diseño sencillo. Separa datos de balance y lógica; evita abstracciones sin uso actual.
- No añadas dependencias o servicios de pago sin acuerdo del usuario.
- Usa recursos propios o con licencia compatible y registra procedencia. No presupongas acceso a código, modelos o servidores originales.
- No inventes controles, cifras, estadísticas ni habilidades del juego original. Marca cada dato como verificado, provisional o pendiente.

## Validación y cierre
- Ejecuta importación y comprobaciones con la versión de Godot fijada; prueba la escena principal cuando exista.
- Prueba daño, recargas, fin de partida y reinicio cuando esos sistemas se modifiquen.
- Si no puedes ejecutar Godot o una prueba visual, informa la limitación y no declares validación completa.
- Actualiza docs/ESTADO.md con tareas terminadas, archivos relevantes, pruebas realizadas, limitaciones y siguiente tarea.
- Añade instrucciones de ejecución al README cuando haya código ejecutable.
- No marques una tarea terminada sin evidencia. Un commit no prueba que el juego funcione.
