# Siguiente encargo — T03: Combate y enemigo

## Base y contexto
Entrega T02 publicada en `feat/v0.1-t02-dragon-y-camara`: código `66815e5f1d9ccd899baea84f76bce0ef9f5301b9`, cierre `f436099969a70df498ee46c92b3fba60d30c6ba9`. T01 está conservada en su historial. Partir de esta entrega en una rama descriptiva para T03; main aún contiene planificación. Recuperar este encargo sin sustituir el ESTADO ni el código más recientes de la rama. No hacer merge ni force push.

Leer AGENTS.md, docs/CONTEXTO_IA.md, PLAN_INICIAL.md, IMPLEMENTACION.md, ESTADO.md y README de la rama. Revisar game/scenes/arena.tscn, dragon.tscn, dragon_visual.tscn, game/scripts/dragon_controller.gd y las dos suites T02. Conservar Godot 4.6.3 Compatibility.

## Encargo concreto
1. Incorporar salud máxima/actual, facciones y recepción de daño sencilla para jugador y enemigo. Salud limitada a [0,máxima], señal de muerte una sola vez; actores muertos no se mueven ni atacan.
2. Clic izquierdo dispara proyectil hacia el hocico -Z de Facing, con daño, velocidad, duración y recarga configurables. Cámara y movimiento siguen independientes del apuntado.
3. Proyectil con colisión real: ignorar emisor y aliados, aplicar daño una sola vez, retirarse al impactar o agotar duración. Evitar atravesar objetivos a la velocidad configurada; comprobarlo con pasos de física reales.
4. Enemigo provisional distinguible que persigue al jugador y ataca dentro de rango con recarga. Respetar arena/altura y detenerse cuando cualquiera de los actores ya no sea objetivo válido.
5. Añadir restauración mínima reproducible de arena para comprobar T03: restablecer vida, posiciones, recargas y eliminar proyectiles. Puede usarse recarga de escena; documentar cómo invocarla. La interfaz completa de victoria/derrota pertenece a T05.
6. Mostrar controles y salud suficientes para observar combate. No implementar Q/E, forja, cuentas ni multijugador. Valores marcados como provisionales.

## Criterios de aceptación
- Importación y arranque sin errores con la versión fijada; regresión de movimiento, límites, orientación y cámara T02. Adaptar pruebas solo si cambian legítimamente las escenas, conservando sus comprobaciones de comportamiento.
- Ataque respeta intervalo, dirección y facciones. Un impacto no duplica daño; salud nunca negativa; muerte única y sin nuevas acciones.
- Probar persecución, entrada/salida de rango, límites y muerte del objetivo; proyectiles caducan y no quedan nodos acumulados.
- Restauración completa repetida tres veces sin duplicar actores/conexiones y sin conservar daño, recargas o proyectiles anteriores.
- Pruebas de integración de lógica crítica y colisión con física real; comprobación gráfica de combate, controles y cámara. Registrar comandos, salidas y limitaciones; no confundir headless con validación visual.
- Si aparece regresión o fallo, corregirlo antes de ampliar alcance. Windows pendiente hasta ejecución real; no bloquea por sí solo T03 en Linux.

## Cierre
Actualizar README y ESTADO.md con archivos, decisiones, pruebas reales, evidencia, limitaciones y siguiente paso T04. Corregir la frase obsoleta de CONTEXTO_IA.md sobre versión pendiente, usando la versión ya fijada. Publicar rama y SHA de código y cierre. No es obligatorio crear PR para continuar si sigue Forbidden; documentar el bloqueo sin cambiar permisos ni hacer merge.

## Alcance de la revisión de T02
Se revisaron por GitHub el diff de código, las suites y el registro T02-linux.log: constan 34 comprobaciones headless y 22 gráficas con salida 0. Son resultados registrados por la entrega, no pruebas repetidas por esta revisión. Sin CI ni PR publicados. No se inspeccionaron nuevamente las imágenes ni se ejecutó Godot aquí. Windows, manejo humano prolongado y GPU física siguen sin probar.
