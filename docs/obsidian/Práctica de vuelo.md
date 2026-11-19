# Práctica de vuelo · v0.7.1

Fichas 13 (6:45) y 16 (8:45). En esta iteración se comprueba que la trayectoria y la dirección de la cabeza pueden ser opuestas. La escena usa mallas primitivas de Godot. Los valores iniciales son ajustes propios.

## Árbol del nivel

```text
FlightLab (Node3D, flight_lab.gd)
  Sky (WorldEnvironment)
  Sun (DirectionalLight3D)
  Floor (MeshInstance3D)
  Beacons (Node3D)
    Beacon1 … Beacon8 (MeshInstance3D cada una)
  FlightPilot (CharacterBody3D, flight_pilot.gd)
    Facing (Node3D)
      Hull (MeshInstance3D, cápsula)
      Wings (MeshInstance3D, prisma)
      Nose (MeshInstance3D, esfera dorada)
    Camera (Camera3D, flight_camera.gd)
  UI (CanvasLayer)
    Instructions (Label)
    Status (Label)
    Atlas (Button)
```

## Ajustes en el inspector

Abre scenes/player/flight_pilot.tscn. En FlightPilot, Speed indica unidades por segundo (6), Flight Height fija la altura (1,5) y Half Extents define el límite en los ejes X y Z (20 y 14). En Camera, Follow Rate controla la rapidez del seguimiento (7). Un valor menor deja que el piloto se adelante más antes de que la cámara lo alcance. Size controla el encuadre ortográfico (16). La posición inicial de Camera (0, 16, 9) define el ángulo oblicuo.

## Prueba en el editor

1. Importa game/project.godot. Pulsa F5 y entra en Práctica de vuelo desde el atlas. También puedes abrir scenes/levels/flight_lab.tscn y pulsar F6.
2. Coloca el cursor sobre una baliza situada delante de la nariz dorada. Mantén S para alejarte. La nariz debe seguir orientada hacia el cursor.
3. Cambia a A o D mientras mueves el cursor alrededor del piloto. Comprueba que la cámara conserva su orientación y alcanza al piloto suavemente cuando sueltas las teclas.
4. Mantén dos teclas de movimiento. La diagonal debe conservar la velocidad máxima y la figura la misma altura. Vuela hasta un borde y comprueba el límite.
5. Pulsa F12 para guardar el fotograma real en PNG. La ruta aparece en pantalla. Para recuperar la imagen desde el editor, abre Proyecto → Abrir carpeta de datos del usuario. Compara el encuadre con la ficha 13 y la orientación de retirada con la 16.

Los scripts completos están en game/scripts/flight_pilot.gd, flight_camera.gd, flight_geometry.gd y flight_lab.gd. El laboratorio y el dragón de combate comparten el cálculo horizontal de movimiento y el rayo de apuntado. El seguimiento suave se evalúa en el laboratorio. Siguiente sistema: disparo y efecto de impacto con geometría básica, después de evaluar el movimiento.
