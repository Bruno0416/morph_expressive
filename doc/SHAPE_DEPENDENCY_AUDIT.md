# R3-F — auditoría de material_new_shapes

La dependencia `material_new_shapes: ^1.0.0` y sus reexports **se conservan**.
Inventario de código runtime revisado al cierre de R3:

| Área | Uso / contrato | Requisito para retirar |
| --- | --- | --- |
| `foundations/shape/morph_material_new_shapes_bridge.dart` | Importa MaterialShapes/RoundedPolygon; reexporta CornerRounding, Matrix4PointTransformer, Morph, MorphToPathExtension, RoundedPolygon, RoundedPolygonToPathExtension, pathFromCubics | Migración mayor; preservar nominalidad requiere conservar la biblioteca original |
| `morph_shape_kind.dart` | 35 getters `.polygon` y nuevo `.geometry` | Conservar `.polygon` durante deprecación; completar otras 26 definiciones propias |
| `morph_shape_clipper.dart`, `morph_shape_container.dart` | Catálogo legacy y `polygon.toPath`; stretch por bounds | Probar equivalencia de clip, stretch y hit test antes de migrar internamente |
| `geometry/morph_shape.dart` | Conversión pública `fromPolygon` y 26 entradas adaptadas | Conversión opcional en paquete bridge separado en una versión mayor |
| Ambos LoadingIndicator | Firmas públicas `List<RoundedPolygon>? polygons`; secuencia default legacy | Adoptar shapes sin retirar compatibilidad prematuramente |
| `refresh_indicator/morph_refresh_indicator.dart` | Import directo y `polygons`; forwards al loader y control manual | Añadir entrada shapes y probar todos los estados de refresh antes de deprecar polygons |
| Sliders / range slider | No se encontraron imports ni usos de RoundedPolygon/Morph | No migración geométrica en esta entrega |
| Otras familias | Sin usos directos de esos tipos encontrados en components | Mantener búsqueda de consumidores externos antes de una versión mayor |
| Generador `tool/generate_native_shape_contours.dart` | API pública MaterialShapes.*.cubics | Conservar como procedencia/reproducibilidad o sustituir por generadores propios con pruebas |

## Secuencia de migración futura

1. Completar 26 definiciones propias, sus parámetros y pruebas geométricas/raster.
2. Mejorar matching de features, validar contornos simples y envolventes/transform.
3. Publicar guía de adopción de `MorphShape` y mantener adaptador de polígonos.
4. Inventariar consumidores reales de los tipos reexportados y de `Morph`, no solo
   el uso interno del loader. Renombrar clases no mantiene asignabilidad nominal.
5. En versión mayor autorizada, mover la compatibilidad a un bridge opcional y
   retirar firmas/reexports solo tras ventana de deprecación acordada.
6. Ejecutar consumidor mixto con `material_ui`, namespace y latest/lowest en copias.

Nueve tablas cúbicas locales y un interpolador propio no completan equivalencia
de catálogo, rounding/smoothing ni API de la dependencia. No se elimina ni se
redeclara `RoundedPolygon`. La auditoría F termina aquí; no autoriza su retiro.
