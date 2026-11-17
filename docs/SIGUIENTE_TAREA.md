# Continuidad — V0.2 T01 completado en Linux

La petición actual del usuario autorizó selección de dos dragones y prevalece
sobre el encargo antiguo T06 de main c33bad1. Se conserva V0.1 en su rama T06 y
el ZIP e40276a sin cambios; no se hizo merge ni reexportación de ese candidato.

Rama: `feat/v0.2-t01-seleccion-dragones` desde `b42ceef`.
Código: `bc22940449b532d53789b29720237549a2de835c`; cierre documental posterior.
Implementado: selector Cobre/Jade con datos de balance separados, diferencias
reales de salud/velocidad/ataques, reinicio con perfil conservado y botón final
para regresar al selector. Nombres, valores y paletas son propios y provisionales.

## Validación y evidencia
- Perfiles 93/0, selector 64/0, partida 46/0; regresiones headless 365/0.
- Ventana nueva 777/0 en 1280×720 y 960×540; regresiones gráficas 250/0.
- Dieciséis capturas propias inspeccionadas, revisiones independientes sin hallazgos.
- Comandos y límites en ESTADO.md y `docs/validacion/V02-T01-linux.log`.

## Valoración humana y pendientes
El usuario probó el prototipo anterior en su laptop y lo consideró «decente».
No informó OS/GPU, SHA o casos individuales. Se registra la valoración general,
sin aprobar las filas no reportadas de T06-prueba-windows.md. No se atribuye esa
prueba a V0.2. El selector nuevo no se exportó ni se ejecutó en Windows.
La publicación estable del ZIP V0.1 continúa bloqueada por API; no reiterar sin
cambio de acceso ni inventar URL. No sustituir el ejecutable por fuentes.

## Próximo incremento
Recoger observaciones sobre ambos perfiles y corregir cualquier fallo reproducido.
Siguiente alcance propuesto: elección de arma y datos asociados, previo encargo.
No ampliar catálogo, guardado, online o arte antes de autorizar ese incremento.
Conservar rama/código/evidencia y distinguir los paquetes V0.1 y V0.2.
