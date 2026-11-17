# Siguiente encargo — T04: Dos habilidades

## Base y lectura
Crear rama descriptiva desde `b9da1e4ddaa3b138b41275961d2144c8de72a5a9` de `feat/v0.1-t03-combate-y-enemigo`; código T03 `973e989096a602814c34d7fff4241f9ee0ab14c3`. Conservar T01–T03. Recuperar este encargo de main sin sustituir el ESTADO ni código de la rama. No merge ni force push.
Leer AGENTS.md y sus documentos obligatorios, README, game/scripts/{combat_actor,weapon,projectile,dragon_controller,arena}.gd, escenas relacionadas y suites T02/T03. Mantener Godot 4.6.3 Compatibility y arquitectura sencilla.

## Implementación
1. Q: proyectil potente direccional con recarga propia, reutilizando barrido, facciones y daño único de T03. Diferenciarlo visualmente del ataque básico con recursos propios.
2. E: pulso instantáneo centrado en jugador; daño una sola vez por objetivo hostil vivo dentro del radio XZ, incluida frontera definida explícitamente. Ignorar emisor, aliados, muertos y nodos inválidos. Sin daño repetido por duración del efecto.
3. Exportar daño, velocidad/duración del proyectil, radio y recargas según corresponda; documentar valores provisionales. Ataque básico, Q y E tienen recargas independientes; intento rechazado no consume recarga ni crea efectos.
4. Configurar Q/E físicos con activación por pulsación, sin repetición por eco del teclado. Bloquear habilidades del jugador muerto. Mantener movimiento, apuntado y cámara.
5. HUD con controles, disponibilidad y tiempo restante de Q/E legibles. Efecto temporal propio para pulso, eliminado al terminar; R limpia efectos/proyectiles y restablece todas las recargas y entidades.
6. No añadir estados finales T05 ni sistemas posteriores. Corregir primero cualquier regresión encontrada.

## Aceptación
- Importación y arranque sin errores. Regresión T02 y T03 con comprobaciones conservadas.
- Q respeta dirección, impacto único, facciones, caducidad y recarga; comprobar colisión real a alta velocidad y objetivo cercano.
- E probado con varios hostiles, aliado, muerto, objetivo fuera y exactamente en límite; cada hostil válido recibe solo el daño previsto.
- Pruebas de activación durante recarga, independencia entre habilidades/básico, jugador muerto, pulsación mantenida/eco y repetición después de recarga.
- Tres reinicios con habilidades, recargas y efectos activos: estado limpio, sin nodos ni conexiones acumulados.
- Validación gráfica de Q/E, indicadores y legibilidad; evidencia propia y resultados reales. Registrar comandos/salidas y separar pruebas automatizadas, inspección visual y manejo humano.
- Windows sigue pendiente hasta probarlo realmente. No afirmar ejecutable Windows validado por exportarlo desde Linux.

## Cierre y objetivo de prueba en laptop
Actualizar README, ESTADO.md y evidencia; publicar rama, SHA de código y cierre. Siguiente incremento T05, después T06. El usuario quiere ser avisado cuando V0.1 sea jugable y visualmente clara en su laptop: preparar en T06 paquete Windows descargable e instrucciones, con limitaciones explícitas y comprobaciones nativas pendientes si no se dispone de Windows. No declarar todavía listo el hito por completar T04.

## Revisión de base
Revisión remota de código de salud/arma/proyectil, comparación con T02 y log publicado: núcleo 51/0, integración 52/0, gráfica 34/0, regresión 34/0 y 22/0 registrados por la entrega. No se ejecutó Godot ni reinspeccionaron imágenes en esta revisión. El log indica gráfica anterior a la última guardia de objetivo fuera del árbol; pruebas headless repetidas después. Mantener esta distinción.
