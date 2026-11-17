# T04 — Q/E con recargas e indicadores

> Ejecución por IA: TDD, tareas independientes delegadas, integración y revisión
> final. Especificación: `docs/SIGUIENTE_TAREA.md` recuperado de main.

**Objetivo:** Q potente direccional y E pulso instantáneo, con recargas propias,
indicadores y efectos temporales; conservar T01–T03. Godot 4.6.3 Compatibility.

**Base:** nueva rama `feat/v0.1-t04-habilidades` desde `b9da1e4`, sin merge.
No se sustituye el ESTADO más reciente por el de main.

## Composición e interfaces

- Q: nodo `Dragon/PowerWeapon`, mismo `weapon.gd` con PackedScene exportada.
  Escena `power_projectile.tscn`, mismo `projectile.gd`: conserva barrido inicial
  y continuo, facciones, impacto único y caducidad. Visual magenta mayor.
- E: `Dragon/PulseAbility`, `try_activate()`, `cooldown_remaining` y
  `effects_parent`. Grupo `combat_actors` registrado por CombatActor; comprueba
  validez/facciones/vida y distancia de centros XZ **d² <= radio²**. Frontera incluida,
  ignorando altura. Efecto de anillo solo visual, sin aplicación tardía de daño.
- Input Q/E físico: pulsación con latch hasta soltar, ignora eco; no repetición
  al terminar recarga con tecla mantenida. Actores muertos no activan habilidades.
- Arena asigna Projectiles a PowerWeapon y Effects a PulseAbility. HUD muestra
  disponibilidad/tiempo Q/E y controles. R recarga la escena, limpiando todo estado.

Datos provisionales exportados: Q daño45, velocidad36, vida2s, recarga2.5s;
E daño30, radio4, recarga4s y efecto0.5s. E sin objetivos es activación válida;
rechazos por muerte/recarga/configuración no consumen recursos ni crean nodos.
Nada de T05, servicios ni exportación Windows en este incremento.

## Pasos

- [x] Leer encargo de main y crear rama en la base exacta sin merge.
- [x] Q reutilizable y sus pruebas físicas reales (agente dedicado).
- [x] E y efecto temporal con pruebas de selección/recarga (agente dedicado).
- [x] Prueba de integración fallida antes de conectar Input/HUD/escenas.
- [x] Integrar entrada por pulsación, indicadores y restauración de habilidades.
- [x] Importación, suites nuevas y regresión T02/T03 sin relajar comprobaciones.
- [x] Pruebas gráficas y capturas Q/E, HUD y restauración; inspección visual.
- [x] Revisión independiente, correcciones y commit de código.
- [x] README/ESTADO/encargo con resultados, limitaciones y T05; commit y publicación.

## Foco de revisión

- Q usa la misma colisión al cambiar escena: no saltar objetivos cercanos/rápidos.
- E: múltiples cuerpos, frontera exacta, otra altura, inválidos y callbacks de daño.
- Activación rechazada no consume recarga ni crea efectos; independencia básico/Q/E.
- Eco y pulsación mantenida tras recarga no reactivan habilidades; nueva pulsación sí.
- Tres R con todas las recargas/efectos activos: sin nodos o conexiones heredadas.
- Indicadores legibles no equivalen a manejo humano ni a Windows probado; V0.1
  aún requiere T05/T06 y prueba en laptop, con límites de validación explícitos.
