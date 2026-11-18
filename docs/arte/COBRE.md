# Cobre — primer incremento visual V0.2 T03

Diseño original generado para este proyecto, sin modelos, texturas o animaciones
extraídos del juego de referencia. No usa servicios ni bibliotecas de pago.
Fuente editable: `game/scripts/dragon_presentation.gd` y
`game/scenes/dragon_visual.tscn`. Mallas de Godot y SurfaceTool; materiales planos.

Dirección provisional: dragón cobrizo con placas ámbar, membranas oscuras,
cuernos marfil, cuatro extremidades y hocico alargado. Silueta aérea conservada.
La geometría adicional se crea solo para el jugador Cobre, después de aplicar
su paleta local. Jade, el enemigo y las colisiones no cambian. El indicador de
arma se reduce y pasa al flanco para dejar despejada la cabeza.

Animación procedural, sin esqueleto importado: alas alrededor de sus hombros,
cola, flotación leve, mandíbula al disparar/activar E, reacción al daño y
pliegue/descenso visual al morir. Señales de ataques aceptados evitan animar
intentos bloqueados por recarga. La animación solo transforma los hijos de
Facing: el nodo de orientación permanece en el plano XZ. Reinicio reconstruye
geometría, materiales y conexiones, sin conservar reacciones anteriores.

Límites: no hay texturas de escamas, rig, clips exportables ni animación facial;
las patas y placas son geometría estilizada. No es calidad final ni una copia
del arte original. Las vistas cercanas sirven para inspección, no sustituyen
la revisión a tamaño jugable. No se han medido GPU física, FPS de laptop,
consumo energético ni Windows nativo. Próximo trabajo visual: refinar membranas,
cuello y articulación, validar con el usuario antes de llevar ese nivel a Jade.
