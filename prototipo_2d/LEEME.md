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
- tests/test_step2.gd ejecuta las comprobaciones de vuelo y combate.

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
godot --headless --fixed-fps 60 --script res://tests/test_step2.gd
```

El paso 3 de vida y reaparición continúa pendiente.
