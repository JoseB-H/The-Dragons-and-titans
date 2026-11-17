# T06 — Registro de prueba Windows/laptop

**Estado: PENDIENTE.** Este documento prepara la recogida de resultados; ninguna
fila acredita una prueba ejecutada. El entorno de desarrollo disponible es Linux.
No hay todavía un informe de ejecución Windows nativa o manejo humano incorporado.

## Candidato que debe probarse

- Código exportado: `e40276a5cb769e53794cd1f64832796772ec060f`.
- ZIP: `DragonsAndTitans-v0.1-rc1-windows-x86_64-e40276a.zip`.
- Tamaño: 35 977 332 bytes.
- SHA256: `aded62eaf281846fba54e2cd5437d3df8911b4cf1b34589b409e6f33a3adacda`.
- Guía: [LEEME-WINDOWS.txt](../entrega/LEEME-WINDOWS.txt).
- Windows x86_64 release, Godot 4.6.3 Compatibility, exportado desde Linux.

## Datos de la prueba

| Dato | Valor real |
| --- | --- |
| Fecha y persona que prueba | Pendiente |
| Windows: edición, versión y compilación | Pendiente |
| Laptop/equipo | Pendiente |
| GPU y versión del controlador | Pendiente |
| ZIP descargado y SHA256 comprobado | Pendiente |
| source_commit de VERSION.json | Pendiente |
| Ejecución nativa en Windows | Pendiente |

Extraer todo el ZIP y conservar EXE/PCK juntos. Abrir PowerShell en esa carpeta
y ejecutar cada comando por separado, cerrando la ventana entre pruebas:

```powershell
.\DragonsAndTitans.exe --resolution 1280x720 --log-file .\prueba-1280x720.log
.\DragonsAndTitans.exe --resolution 960x540 --log-file .\prueba-960x540.log
```

## Resultados que deben registrarse

Usar «Pasa», «Falla» o «No probado» con una observación de lo que ocurrió.
No sustituir un resultado Windows por las pruebas Linux ya registradas.

| Comprobación | 1280×720 | 960×540 |
| --- | --- | --- |
| Arranca el EXE, carga arena y muestra ambos actores | Pendiente | Pendiente |
| WASD, diagonal, límites y cámara conservan al jugador visible | Pendiente | Pendiente |
| Ratón orienta el hocico de forma coherente | Pendiente | Pendiente |
| Clic básico causa daño y respeta recarga | Pendiente | Pendiente |
| Q causa daño, muestra recarga y exige nueva pulsación | Pendiente | Pendiente |
| E causa daño en área, muestra recarga y retira su efecto | Pendiente | Pendiente |
| Victoria por combate y panel inequívoco | Pendiente | Pendiente |
| Derrota por combate y panel inequívoco | Pendiente | Pendiente |
| Tras ambos finales nadie se mueve, ataca ni recibe daño | Pendiente | Pendiente |
| HUD y botón legibles, completos y sin tapar al jugador | Pendiente | Pendiente |
| Botón con foco visible, clic y Enter/Espacio operativos | Pendiente | Pendiente |
| R durante juego y final restaura escena completa | Pendiente | Pendiente |
| Tres reinicios alternando victoria/derrota y R/botón | Pendiente | Pendiente |
| Teclas/clic retenidos no actúan al reiniciar; soltar permite jugar | Pendiente | Pendiente |
| Pulsaciones rápidas/eco no duplican escenas o conexiones | Pendiente | Pendiente |

## Si aparece un fallo

Registrar pasos, resultado esperado, resultado observado y frecuencia. Añadir
Windows/GPU, tamaño de ventana, VERSION.json y el registro generado si existe.
Si Windows impide arrancar, copiar el mensaje exacto; no desactivar protecciones.
Las capturas y los logs deben revisarse antes de compartirlos para evitar datos
personales. Una IA puede ayudar a analizar la evidencia; no debe inventarla.

## Decisión de continuidad

**Pendiente:** no se acepta íntegramente T06/V0.1 ni se inicia V0.2 con este
registro vacío. Corregir cualquier fallo reproducido antes de ampliar el juego.
Si cambia el código, identificar y exportar un candidato nuevo con su propio hash
y repetir las pruebas afectadas; no atribuirle resultados de e40276a.
