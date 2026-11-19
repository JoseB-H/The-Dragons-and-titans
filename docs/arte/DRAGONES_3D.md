# Dragones 3D — V0.2 T05

Este incremento sustituye los modelos de primitivas/CSG por tres recursos GLB
propios: Cobre, Jade y Sentinela. Se conservan las entregas anteriores en Git.
La dirección es fantasía estilizada de geometría moderada para cámara aérea;
no se atribuye fidelidad al arte original ni acabado cinematográfico.

## Producción y edición
Fuente completa y reproducible: `tools/art/build_dragons.py`.
Ejecutar desde la raíz: `blender -b --python tools/art/build_dragons.py`.
Probado con Blender 4.3.2; genera `game/assets/dragons/{cobre,jade,sentinela}.glb`.
Blender solo interviene al producir/editar arte; el jugador necesita únicamente
el paquete Windows. Godot importa los GLB y exporta sus recursos derivados.
Las texturas de escamas se generan y empaquetan dentro de cada GLB. No se usan
servicios, bibliotecas adicionales de pago ni arte/modelos/texturas externos.

## Modelos
Cobre: tórax ancho, cuello curvo, cuernos altos barridos, placas superpuestas,
gama cobre/ámbar y membranas rojizas. Jade: tórax más estrecho, mayor envergadura,
cuernos menores, cresta más baja, gama esmeralda y vientre claro. Sentinela:
variante acorazada azul/cian con ojos luminosos que identifica al enemigo.
Los tres tienen mandíbula separada, órbitas, iris y pupilas, fosas nasales,
dientes, cuatro patas recogidas con dedos y garras, membranas combadas y cola.

Por modelo: una malla skinned, siete materiales (piel con escamas, vientre,
membrana de doble cara, marfil, ojo emisivo, pupila y placas). Esqueleto de
16 huesos: raíz, torso, cuello, cabeza, mandíbula, tres de cola, dos por ala
y cuatro de extremidades. Las cifras exactas de GLB están en la evidencia.
Se mantiene una dirección -Z. Los pesos son por regiones rígidas; el cuello y
las uniones no equivalen a un rig de deformación orgánica de producción AAA.

## Animación e integración
Clips importados Flight, Attack, Hit y Death, muestreados a 24 fps en Blender.
Vuelo con hombros y puntas desfasados, cola y patas; ataque abre mandíbula;
impacto sacude raíz visual; muerte pliega alas, baja cabeza y sostiene pose.
El AnimationPlayer solo anima el modelo hijo de Facing. Ni cuerpo físico,
colisiones, velocidad, datos de balance ni eje de apuntado se animan.
Se duplican materiales y Animation por instancia. Las señales de ataques
aceptados activan el clip; las recargas bloqueadas no lo reinician.

Galería accesible desde «Ver dragones 3D» en el selector: tres modelos,
cuatro animaciones, arrastre horizontal, zoom y vuelta al menú conservando
selección/equipo. Es el mismo GLB usado por el combate, con luz de inspección.

## Límites de aceptación
El acabado de este lote queda implementado como candidato estilizado completo,
sujeto a valoración humana. No se han medido FPS o consumo en laptop/GPU física,
ni probado Windows nativo. Las texturas de 256×256 y animaciones de pesos por
región pueden ampliarse si la dirección artística del usuario lo requiere.
No confundir exportación Windows con prueba nativa, ni pruebas de lógica con
aceptación de calidad artística.
