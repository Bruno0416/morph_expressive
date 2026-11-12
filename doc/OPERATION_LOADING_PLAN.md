# Operación y placeholders — plan de trabajo

Alcance aprobado por la especificación del usuario: solo botón controlado y
skeleton/shimmer. Checkout actual 0.7.0; conservar todas las ediciones locales.

- [x] Inspeccionar interacción MorphButton, tema, renderer, AA y reportes recientes.
- [x] Escribir contratos focalizados y observar fallos antes de implementar.
- [x] Botón: una instancia MorphButton, estado externo, transición independiente
  del perfil de presión, superficie redondeada existente con fallback.
- [x] Skeleton: un reloj por grupo, coordenadas del grupo, shader por placeholder,
  fallback Canvas sin capturas; pulse y estático; intercambio accesible de contenido.
- [x] Tema, exports, ejemplos y laboratorio `?lab=operations`.
- [x] Análisis, pruebas, gates, compilación Web/Linux y revisión visual.
- [x] Documentación final y previews disponibles, sin publicación.

Decisiones: composición sobre MorphButton (no duplicar gestos); medir labels con
TextPainter y tipografía vigente, sin medir ocultando botones reales; constraints
tight tienen prioridad. Programa shader compartido, uniforms por instancia.
No métricas de rendimiento afirmadas sin medición. Sin datos personales ni red
en los componentes; las simulaciones cancelables pertenecen exclusivamente al lab.
