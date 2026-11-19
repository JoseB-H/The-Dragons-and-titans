# V0.2 T01 — Selección de dos dragones

**Autorización:** petición actual del usuario; prevalece sobre el encargo T06
antiguo de main `c33bad1`. Base T06 `b42ceef776ce81b6af704466afb842f4959acd80`;
rama `feat/v0.2-t01-seleccion-dragones`, sin merge/force push.

**Objetivo:** elegir antes de combatir entre Cobre y Jade, mantener la elección
al reiniciar y permitir volver a elegir después de victoria/derrota. Conservar
V0.1 y el ZIP e40276a sin atribuirle pruebas del incremento nuevo.

## Diseño y decisiones provisionales

- Godot 4.6.3 Compatibility; recursos geométricos propios existentes con paletas
  locales por instancia. No arte original, dependencias, cuentas ni guardado en disco.
- `dragon_profile.gd` Resource + `game/data/dragons/{cobre,jade}.tres` almacenan
  identidad, descripción, salud, velocidad, básico/Q/E, tiempos y colores. La
  lógica aplica datos, sin ramas de balance específicas por nombre.
- Cobre conserva V0.1: salud100, velocidad6, básico20/0.4s, Q45/2.5s,
  E30/radio4/4s. Jade: salud70, velocidad8, básico15/0.3s, Q35/2s,
  E20/radio3.5/3s. No son estadísticas originales; balance aún no calibrado.
- Ambos: básico velocidad28/vida2/origen1.9; Q velocidad36/vida2/origen1.9;
  efecto E0.5s. Los valores residen en los recursos, no en el selector/HUD.
- Autoload `DragonRoster` (`dragon_roster.gd`): `get_profiles()->Array[Resource]`,
  `selected_profile()->Resource`, `select_dragon(id:StringName)->bool`,
  `selected_id:StringName`, predeterminado `cobre`; rechazar id desconocido sin
  cambiar selección. Los perfiles se consultan sin mutarlos durante la partida.
- `dragon_controller.gd` aplica el recurso ANTES de inicializar salud; expone
  `profile_id`, `profile_name`. Conserva controles, límites, cámara y bloqueo.
- Nueva escena principal `dragon_selection.tscn`/script: dos botones de elección,
  comparación y botón Jugar, foco/ratón/teclado. API `select_profile(id)->bool`,
  `selected_profile_id()->StringName`, `start_match()->Error`; guardia de navegación.
  Variables públicas `copper_button`, `jade_button`, `play_button`, `details`.
- Arena continúa como escena independiente para regresiones. R/botón Reiniciar
  recargan Arena conservando selección en sesión. Nuevo botón final Elegir dragón
  emite `hud.selection_requested`; `arena.return_to_selection()->Error` rechaza
  durante juego y comparte guardia de navegación con reinicio. No cambio en combate.
- Reiniciar no repite menú. Volver al menú conserva elección, enfoca su tarjeta y
  permite cambiarla; no debe arrastrar clic/Enter ni duplicar escena o conexiones.
- HUD anuncia nombre del dragón sin quitar objetivo/salud/controles/recargas ni
  tapar al jugador. Comprobar menú/ambos modelos/finales en 1280×720 y 960×540.

## Tareas y evidencia

- [x] Leer instrucciones, conservar T06 y registrar valoración humana literal.
- [x] Datos/catálogo/controlador: pruebas primero; valores aplicados y no compartidos.
- [x] Selector accesible y pruebas de selección/entrada/navegación única.
- [x] Integración principal/HUD/retorno final y pruebas de combate/reinicio por perfil.
- [x] Importación, arranque y regresiones V0.1; suites nuevas headless y ventana.
- [x] Capturas propias, revisión independiente y corrección de fallos reproducidos.
- [x] Commit código, continuidad/evidencia, commit cierre y push rama/SHA sin merge.

Código `bc22940449b532d53789b29720237549a2de835c`; cierre documental posterior.
Nuevas headless 93/64/46 sin fallos, ventana 777/0; regresiones365/0 y250/0.
Dieciséis capturas revisadas. Detalle de correcciones y límites en ESTADO.md.

## Registro humano y límites

El usuario indica que probó el prototipo en su laptop y lo consideró «decente».
No informó OS/versión/GPU, SHA ni resultados individuales: esos campos permanecen
pendientes. La petición autoriza comenzar V0.2 sin declarar T06 íntegramente aceptada.
La nueva selección no hereda una validación Windows por esa valoración general.
