# Dragones · Vuelo y combate 2D

Proyecto independiente del prototipo 3D. Importa este project.godot y pulsa F5. Las formas son Polygon2D con la fuente incluida en Godot.

## Árbol del nivel

```text
TestLevel (Node2D)
  Ground (Node2D)
    Field, GridH y GridV (Polygon2D)
  Player (CharacterBody2D)
    Collider (CollisionShape2D)
    Model (Node2D)
      Wings, Body (Polygon2D)
    Weapon (Node)
  Camera (Camera2D)
  ImpactFeedback (Node)
  Targets (Node2D)
    Centro, Izquierda, Derecha, Aislado (StaticBody2D cada uno)
      Body, Center (Polygon2D)
      Collider (CollisionShape2D)
      Readout (Label)
  UI (CanvasLayer)
    Controls (Label)
  AimMarker (Polygon2D)
```

Durante el disparo aparecen Bolt (Area2D → Spark, Polygon2D) e Impact (Node2D → Flash y nubes, Polygon2D). Cada blanco añade un Label temporal para la cifra de daño.

## Scripts completos

- scripts/player/dragon_player.gd controla inercia, orientación, retícula y banking.
- scripts/camera/top_down_camera.gd combina adelanto y suavizado de Camera2D.
- scripts/combat/dragon_weapon.gd controla entrada, recargas y creación de proyectiles.
- scripts/combat/bolt.gd resuelve el barrido básico y la consulta circular de Q.
- scripts/combat/practice_target.gd registra el daño y crea cifras flotantes.
- scripts/combat/impact.gd anima el destello y el humo independientemente del daño.
- scripts/combat/impact_feedback.gd aplica la pausa y el temblor mediante Camera2D.offset.
- tests/test_prototipo.gd ejecuta las comprobaciones de vuelo y combate.

## Inspector y equivalencia

La escala es 24 px por metro. Los tiempos y las proporciones de alcance, movimiento y radio proceden del paso 2.

| Nodo | Ajustes iniciales |
|---|---|
| Player | max_speed 336 px/s, acceleration 960 px/s², deceleration 720 px/s², turn_speed 10, bank_amount 0,17 rad, bank_speed 6 |
| Camera | position_smoothing_enabled activo, position_smoothing_speed 6, look_ahead 72 px, look_ahead_speed 3 |
| Weapon | basic_damage 12, basic_interval 0,28 s, burst_damage 30, burst_interval 2,5 s, burst_radius 81,6 px, reach 840 px, speed 672 px/s |
| ImpactFeedback | hit_pause 0,045 s, shake_strength 3,12 px, shake_duration 0,16 s |

## Prueba en el editor

1. Pulsa F5. Mantén S, apunta al grupo y dispara con clic izquierdo. El dragón puede retirarse mientras sigue mirando al enemigo. Suelta S para observar la frenada.
2. Desde el inicio, un clic breve al centro da 12. Q sobre el mismo objetivo deja los contadores centro/izquierda/derecha/aislado en 42/30/30/0.
3. Lanza Q y mueve la mira. La explosión ocurre en el punto capturado (hasta el límite de alcance), incluso si el proyectil pasó por otro blanco. Observa la pausa breve, el temblor y las cifras.
4. Apunta a suelo vacío cerca del grupo para probar el borde del radio. Pulsa Q dos veces seguidas para comprobar la recarga. F8 y F5 reinician la práctica.

Con el ejecutable de Godot en el PATH, desde esta carpeta:

```sh
godot --headless --editor --import
godot --headless --fixed-fps 60 --script res://tests/test_prototipo.gd
```

## Paso 3 · Vida, muerte y reaparición

Cada actor lleva un nodo HealthComponent con max_health, current_health, invulnerable, take_damage(amount), health_changed(actual, maximum) y died. El daño se limita a la vida restante. Al llegar a cero se emite died una vez por vida. Los impactos consultan el componente y avisan al grupo opcional impact_feedback cuando se aplica daño.

### Nodos añadidos

- TestLevel/Spawn (Marker2D) fija la posición de reaparición.
- Player/HealthComponent (Node) y Player/Aura (Line2D) controlan la vida y señalan la protección.
- Cada blanco de Targets/ incorpora HealthComponent y HealthBar (ProgressBar).
- TestLevel/Turret usa la escena del blanco y añade Barrel (Polygon2D). Sus proyectiles solo impactan en la capa del piloto.
- UI (CanvasLayer) incorpora HealthBar (ProgressBar) con Text (Label).

### Prueba manual

1. Lanza Q sobre un blanco y observa su barra. Al agotar sus 100 puntos desaparece con un destello y vuelve tras 3 s con vida completa. Los contadores de daño empiezan otra vez en cero.
2. Vuela hacia la derecha del punto de inicio. La torreta está en (335, 90) y abre fuego a 220 px. Quédate en su alcance: cuatro disparos de 25 agotan la barra del HUD.
3. El dragón desaparece, queda sin movimiento ni disparo y reaparece en Spawn tras 3 s. El anillo azul indica 2 s de invulnerabilidad. Puedes volar y disparar desde que reapareces.
4. Ajusta max_health en HealthComponent, respawn_time y protection_time en Player; en cada blanco, respawn_time. En Turret están shot_damage, shot_interval, attack_range y shot_speed. Los valores son locales al prototipo.
5. Ejecuta tests/test_prototipo.gd con el comando anterior. Ahora incluye las regresiones de vuelo, los dos intervalos de reaparición, daño real de la torreta, aura, HUD, impactos opcionales y transparencia. Q sigue detonando en la mira.

### Archivos de esta entrega

Nuevos: scripts/combat/health_component.gd, scripts/combat/practice_turret.gd y scripts/ui/player_health.gd.
Modificados: LEEME.md, scenes/combat/target.tscn, scenes/levels/test_level.tscn, scripts/combat/bolt.gd, scripts/combat/dragon_weapon.gd, scripts/combat/impact.gd, scripts/combat/practice_target.gd, scripts/player/dragon_player.gd y tests/test_prototipo.gd.

## Paso 4 · Defensa del obelisco

Desde F5, busca el cristal azul a la izquierda del punto inicial. Protege sus 180 puntos de vida durante tres oleadas de 3, 4 y 5 minions. Puedes atraerlos acercándote, retroceder y disparar hacia el grupo. Al alejarte o caer, los supervivientes vuelven al obelisco. El panel superior derecho cuenta los enemigos vivos de la oleada actual. Al acabar la última oleada aparece Victoria. La caída del cristal produce Derrota. Pulsa R en cualquiera de esos dos estados para empezar una partida nueva.

### Árbol añadido a TestLevel

- NavigationRegion (NavigationRegion2D) contiene el recurso horneado defense_navigation.tres.
- Obelisk (Node2D) incluye Crystal y Facet (Polygon2D), HealthComponent y HealthBar (ProgressBar).
- WaveSpawner (Node2D) usa los Marker2D North, West y South. Distribuye el tamaño indicado en wave_sizes entre los puntos. Para añadir entradas al mapa añade más hijos Marker2D.
- Cada Minion (CharacterBody2D, grupo minions) tiene Body, Collider, HealthComponent y Agent (NavigationAgent2D).
- UI/Objective (PanelContainer) contiene Text (Label). La barra de cada actor usa fondo oscuro, relleno verde y rojo por debajo del 30 %. El daño al piloto provoca un destello rojo en Model y cifras flotantes en el mundo. La torreta enemiga lleva una base violeta dentada y un cañón dorado.

### Inspector

En WaveSpawner ajusta minion_scene, wave_sizes y wave_pause (3 s al inicio y entre oleadas). En la escena minion.tscn ajusta velocidad (68 px/s), aggro_range (115 px), melee_range (32 px), damage (6) y attack_interval (1,1 s). HealthComponent controla los 36 puntos de vida del minion y los 180 del obelisco.

### Cómo volver a hornear la navegación

1. Abre scenes/levels/test_level.tscn en el editor 2D y selecciona NavigationRegion. En Navigation Polygon puedes editar el contorno del área transitable. Mantén los tres marcadores y el obelisco dentro del contorno.
2. Si añades paredes, colócalas como StaticBody2D bajo NavigationRegion, con una CollisionShape2D o CollisionPolygon2D y la capa de colisión **3** habilitada. El horneado lee la máscara 4 (el bit de la capa 3). Los actores móviles se excluyen de esa máscara.
3. Con la región seleccionada, pulsa **Bake NavigationPolygon** en la barra del editor 2D. Guarda la escena y el recurso scenes/waves/defense_navigation.tres. Activa la visualización de navegación y prueba F5 para comprobar que los minions rodean las paredes.

### Verificación

La prueba unificada en tests/test_prototipo.gd conserva las comprobaciones anteriores y valida barras al 30 % y por debajo, reacción al daño, navegación, aggro, cadencia, espera entre oleadas, conteo de bajas y reinicio de ambos resultados. Ejecuta los comandos de la sección de prueba del editor.
