# Siguiente encargo — V0.2 T02: armas e integración de equipamiento

## Base y continuidad
Crear una rama descriptiva desde 95337f228532ca7ae0abb18cb3bb0e9805225dc3, cierre de V0.2 T01. Leer AGENTS.md y sus documentos obligatorios en esa base. Este encargo reemplaza el antiguo seguimiento exclusivo de T06: V0.2 fue autorizado por el usuario.
Conservar Cobre/Jade, V0.1 y su candidato e40276a; sin merge, rebase ni force push.

## Objetivo del encargo completo
Entregar selección de dos armas propias, sus cuatro combinaciones con los dos dragones y una presentación clara del equipamiento. Ejecutar los pasos y corregir fallos entre ellos sin esperar mensajes intermedios cuando las comprobaciones pasen.

1. Definir dos perfiles de arma en recursos separados: una rápida de menor daño y otra lenta de mayor daño, con nombres, cifras y apariencia provisionales propios. La diferencia debe sentirse en el ataque básico. Mantener Q/E como habilidades del dragón para este incremento; no atribuir esta división al juego original.
2. Documentar una regla única y sencilla para combinar el básico del dragón y los modificadores del arma. Mantener salud, movimiento y Q/E del perfil de dragón; evitar duplicar fuentes de balance o modificar recursos compartidos. Incluir una configuración que conserve el básico actual.
3. Ampliar la selección previa con ratón y teclado: dragón, arma, estadísticas resultantes y Jugar. Recordar ambas elecciones en memoria; no guardar en disco. HUD identifica ambos. Al terminar, permitir volver a equipamiento; R/botón reinician con la misma combinación. Impedir cambios en combate y navegación duplicada.
4. Añadir identificación visual propia y ligera de las armas y proyectiles, e impacto legible sin ocultar al jugador. No renovar todo el arte ni ampliar el catálogo. Comprobar foco, textos y paneles en 1280×720 y 960×540.
5. Validar las cuatro combinaciones con impactos y recargas reales, victoria/derrota, bloqueo al terminar, cambio posterior y al menos tres reinicios consecutivos. Comprobar aislamiento de recursos y entradas retenidas. Ejecutar las regresiones pertinentes de V0.1/T01 sin eliminar cobertura para acomodar errores.
6. Actualizar README, IMPLEMENTACION, ESTADO y continuidad en la rama de entrega. Registrar decisiones, comandos, resultados, evidencia visual y limitaciones. Si el entorno permite exportar, preparar un candidato Windows V0.2 separado, con instrucciones, tamaño y SHA256; no reemplazar el ZIP V0.1. Si no permite, documentar el bloqueo sin frenar código validado.

## Criterios de cierre
Dos armas con diferencias reales, cuatro combinaciones funcionales y UI coherente con el balance ejecutado; sin regresiones conocidas, acumulación de nodos o mutación de datos compartidos. Recursos propios o con licencia registrada. Publicar rama, SHA de código, SHA de cierre y enlace real al paquete si existe, sin merge.
No implementar todavía forja, inventario, persistencia, aventura, titanes, online ni más dragones.
Exportación no equivale a ejecución Windows. Windows V0.2 y prueba humana quedan pendientes hasta evidencia específica. No repetir llamadas de publicación que dieron Forbidden sin cambio de acceso.

## Revisión remota de T01
Comparación b42ceef..95337f2: base conservada y dos commits añadidos. ESTADO y V02-T01-linux.log concuerdan: 203 comprobaciones nuevas de lógica, 777 gráficas; regresiones 365 de lógica y 250 gráficas sin fallos reportados. Esta revisión leyó documentación, registro y lista de cambios; no ejecutó pruebas, auditó íntegramente el código ni inspeccionó las capturas. La valoración «decente» pertenece al prototipo anterior y no aprueba V0.2.
