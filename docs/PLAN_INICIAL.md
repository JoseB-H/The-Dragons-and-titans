# DRAGONS AND TITANS — Plan inicial

## Objetivo acordado
Centralizar en este repositorio la recreación progresiva del juego Dragons and Titans: código, diseño, documentación, pruebas y recursos propios. Estado: inicio del proyecto; este documento no constituye un juego ejecutable.

## Referencias
- Steam: https://store.steampowered.com/app/263500/Dragons_and_Titans/
- Wiki: https://dragonsandtitans.fandom.com/wiki/Dragons_and_Titans_Wiki
- Cinco capturas aportadas en la conversación inicial; pendientes de catalogar en el repositorio.

Steam confirma que el título ya no está disponible y describe más de 30 dragones, más de 30 armas, equipos 5v5, aventura, cooperativo, forja y modos MOBA, Captura y Conserva y ARAM. La wiki está pendiente de consulta. No se han verificado controles, estadísticas, habilidades individuales ni reglas exactas.

## Primer hito propuesto: combate offline
- Arena 3D pequeña y cámara aérea.
- Un dragón controlable con movimiento y orientación.
- Ataque básico y dos habilidades con tiempos de recarga.
- Vida, daño, muerte y reinicio.
- Un enemigo con IA sencilla.
- Objetivo de arena y victoria/derrota.

Aceptación: iniciar una partida, controlar al dragón, combatir, ganar o perder y reiniciar sin errores bloqueantes. Documentar controles e instrucciones de ejecución.

## Hitos posteriores
1. Selección de dragón y arma; parámetros separados del código.
2. Estructuras, objetivos, titán y equipos con bots.
3. Progresión, inventario, forja y guardado local.
4. Aventura y misiones.
5. Multijugador con servidor autoritativo; después validar partidas 5v5.
6. Ampliar catálogo de dragones, armas y mapas tras validar el combate.

## Propuestas técnicas pendientes de validar
- Godot 4 estable y GDScript; fijar una versión concreta al iniciar el prototipo.
- PC Windows como plataforma inicial.
- Recursos provisionales propios para comprobar jugabilidad antes de producir arte detallado.
- No agregar servicios de pago sin acuerdo explícito.

## Investigación pendiente
- Controles originales y comportamiento del vuelo.
- Cámara, apuntado, alcance, colisiones y altura visual frente a altura jugable.
- Habilidades del dragón frente a habilidades del arma.
- Condiciones exactas para liberar al titán y ganar.
- Progresión durante la partida frente a progresión persistente.
- Catálogo verificable de dragones, armas, mapas y misiones con fuente por entrada.

## Continuidad
Distinguir hechos verificados, propuestas y pendientes. Actualizar el estado real al terminar cada incremento. Registrar decisiones de motor, plataforma, arquitectura y controles con motivo y fecha. Mantener los recursos con su autoría y licencia; las capturas sirven como referencia visual y no implican permiso para redistribuir recursos originales. El proyecto es independiente y no presupone acceso al código ni a los servidores originales.
