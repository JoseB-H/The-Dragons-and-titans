# Plan de implementación para Codex

## Hito V0.1: arena offline
Realizar las tareas en orden y actualizar ESTADO.md tras cada entrega. Este plan define comportamiento propuesto para el prototipo, no reglas confirmadas del juego original.

### T01 — Proyecto ejecutable
Crear proyecto Godot 4 con GDScript y renderizador Compatibility como punto de partida. Fijar versión exacta en README. Estructura sugerida: game/project.godot, game/scenes/, game/scripts/, game/data/, game/assets/. Añadir exclusión de .godot/ y archivos temporales.
Aceptación: importar sin errores de scripts y abrir escena principal con suelo, luz y cámara. Registrar comando de ejecución real.

### T02 — Dragón y cámara
Crear representación provisional reconocible mediante cuerpo, cabeza, alas y cola. Movimiento en plano XZ y altura visual fija; cámara aérea oblicua que sigue al jugador. Propuesta de controles: WASD para mover, ratón para orientar, clic izquierdo para ataque, Q/E para habilidades, R para reiniciar al terminar. Registrar Input Map y controles visibles.
Aceptación: movimiento diagonal normalizado, límites de arena, orientación coherente y cámara sin perder al dragón. El vuelo vertical queda fuera de este hito.

### T03 — Combate y enemigo
Definir salud máxima/actual, facciones y recepción de daño. Ataque básico direccional con proyectil y recarga. Enemigo que persigue y ataca dentro de rango, con límites de arena. Retirar proyectiles al impactar o agotar su duración; impedir daño propio y acciones de actores muertos.
Aceptación: daño una vez por impacto; salud nunca menor a cero; muerte detiene ataques; reinicio restaura entidades.

### T04 — Dos habilidades
Q: proyectil potente con recarga propia. E: pulso de daño en área centrado en el jugador. Valores de daño, velocidad, radio y recarga configurables mediante recursos o datos exportados.
Aceptación: no activar durante recarga; objetivos válidos reciben el daño previsto; recargas visibles; efectos temporales se eliminan.

### T05 — Ciclo de partida e interfaz
Estados de partida: jugando, victoria y derrota. Objetivo provisional: vencer al enemigo; derrota al morir. Mostrar salud, objetivo, controles y recargas. Al terminar, bloquear combate y ofrecer reinicio completo sin duplicar nodos ni conexiones.
Aceptación: se puede ganar, perder y reiniciar repetidamente. La victoria por liberar al titán se implementará en otro hito cuando se definan sus reglas.

### T06 — Entrega comprobable
Documentar instalación, versión, importación y ejecución en Windows. Comprobar arranque, movimiento, orientación, límites, daño, recargas, victoria, derrota y tres reinicios consecutivos. Usar pruebas automatizadas para lógica crítica cuando aporten cobertura real; revisión visual para cámara, legibilidad y controles.
Aceptación: registrar resultados reales y limitaciones. No generar ejecutables supuestamente probados si no se exportaron y ejecutaron.

## V0.2 — primer incremento autorizado

### T01 — Selección entre dos dragones y datos de balance
Selector previo al combate con Cobre (balance V0.1) y Jade (más velocidad, menos
salud/daño por impacto y recargas menores). Datos autoritativos en recursos
separados de controladores y UI; materiales locales y geometría propia existente.
Reiniciar conserva elección; al terminar se puede volver al selector y cambiar.
Aceptación: selección con ratón/teclado, valores reales de salud/movimiento/daño/
recargas, aislamiento de instancias, combate y reinicio por perfil, navegación
única y regresiones V0.1; interfaz legible en1280×720 y960×540. Registrar pruebas
y límites en ESTADO. Los nombres y cifras son provisionales, no datos originales.
Armas elegibles, más dragones, guardado y ampliaciones requieren otro incremento.

## Arquitectura mínima sugerida
- Arena: composición de escena y ciclo de partida.
- DragonController: entrada y movimiento.
- EnemyController: decisiones simples de persecución/ataque.
- Health: estado de vida y señales de daño/muerte.
- Projectile: desplazamiento, colisión y duración.
- HUD: presentación del estado.
Ajustar nombres y composición a las necesidades; evitar un framework complejo.

## Después de V0.1
V0.2: elección de dragón/arma y datos de balance.
V0.3: estructuras, objetivos y titán con bots.
V0.4: progreso, guardado local y forja.
V0.5: misión de aventura.
Multijugador: diseñar autoridad del servidor, sincronización y desconexiones antes de implementar; validar primero una sesión pequeña y después 5v5.

## Prompt de inicio
Lee AGENTS.md y los documentos indicados. Verifica el código y la rama actuales. Implementa la primera tarea pendiente de V0.1 con recursos provisionales propios, ejecuta las comprobaciones disponibles y actualiza docs/ESTADO.md. Continúa con el siguiente incremento si el anterior queda validado; informa con precisión lo no probado. No dependas del chat compartido.

## V0.2 T02 — Armas y equipamiento reimplementados
Dos recursos de arma independientes: Ascua (multiplicadores 1/1) y Martillo astral
(1.8 daño/2 recarga). Resultado calculado desde el perfil del dragón, sin mutarlo.
Selector, HUD, marca geométrica, proyectil e impacto propios.
Código y pruebas de lógica implementados; validación gráfica, entradas físicas,
revisión de foco en ventana, exportación y Windows pendientes en esta entrega.
No iniciar T03 antes del cierre de esas comprobaciones.
