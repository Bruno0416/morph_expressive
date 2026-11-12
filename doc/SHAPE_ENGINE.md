# Motor de formas 2D

## Modelo y uso

La API aditiva se importa desde `package:morph_expressive/morph_expressive.dart`.
`MorphCubic` conserva anchors y controles Bézier; ofrece evaluación, derivada,
split de De Casteljau y bounds con raíces interiores de la derivada.
`MorphContour` copia sus curvas a una lista inmutable, exige cierre con tolerancia
de 1e-7 y admite de 1 a 512 segmentos finitos. La normalización es explícita;
la rotación usa radianes alrededor del centro persistente.

```dart
final engine = MorphGeometryEngine();
final transition = engine.prepare(
  MorphShapeCatalog.cookie7Sided.contour,
  MorphShapeCatalog.softBurst.contour,
);
final visible = transition.at(0.4);
final interrupted = engine.prepare(visible, MorphShapeCatalog.pentagon.contour);
// interrupted.at(0) conserva el lugar geométrico visible.
```

`prepare` normaliza winding, subdivide exactamente las curvas con mayor longitud
de polígono de control hasta igualar cantidades y busca un seam cíclico mediante
anchors y controles. La búsqueda cuesta O(n²), una vez por destino; `at` cuesta
O(n). No hay LCM, fitting ni conversión a polilínea. Retargets no aumentan la
cantidad por encima del máximo de los endpoints, hasta 512. No hay caché global
de transiciones; el propietario conserva su morph preparado. El catálogo cachea
solo sus 35 entradas.

El progreso finito se acota a [0,1]; NaN e infinito provocan `ArgumentError`.
La correspondencia es heurística: no implementa matching semántico completo de
features ni garantiza contornos simples en todos los frames. Agujeros, múltiples
contornos y topologías incompatibles quedan fuera de contrato. No hay certificación
de paridad con el algoritmo AndroidX. Se garantiza continuidad de posición del
contorno capturado, no continuidad de velocidad. Cambios externos de tamaño o
rotación siguen los valores del consumidor, no un retarget automático del transform.

## Canvas y Shader

`MorphShapeView` dibuja con `Path.cubicTo`, antialiasing, color o `Gradient`.
No añade semántica interactiva. Su espacio común no se renormaliza cada frame;
un destino no cuadrado estira x/y deliberadamente. El consumidor debe reservar
espacio para la envolvente de rotación. El painter no prepara correspondencias.
La vista actual reconstruye geometría al cambiar progreso; no ofrece un canal
`Listenable` de repaint sin rebuild para animaciones de alta densidad.

Canvas es el default. `.shader` y `.auto` son peticiones con fallback, nunca
garantías. `onRendererChanged` entrega el renderer efectivo y su motivo.
Solo `MorphShape.ellipse()` y transiciones entre estas elipses procedurales
son elegibles: la elipse analítica aproxima la referencia de cuatro cúbicas.
La prueba raster a DPR 2, tamaño 120×120 y alpha 0.5 exige error medio por canal
menor de 2/255. No equivale a una garantía para todos los tamaños/DPR.
Las formas de catálogo, incluso `circle` y `oval`, no reclaman esta capacidad.
Contornos capturados, gradientes y transiciones no elegibles usan Canvas.

El programa se carga fuera de paint desde
`packages/morph_expressive/shaders/morph_ellipse.frag`; los tests del paquete raíz
usan fallback de asset local. Cada widget posee uniforms independientes y dispone
su `FragmentShader`. Un fallo de carga queda registrado sin reintento por frame.
La ruta de error existe, pero no se ha inyectado una compilación fallida en tests.
No se afirma mejora de FPS ni validación Impeller/RTX por pruebas Web.

## Procedencia del catálogo

Las nueve definiciones locales son datos cúbicos fijos de
`material_new_shapes` **1.0.0**, generados con su API pública y conservando su MIT
en `NOTICE`. SHA-256 del archivo de paquete resuelto:
`e4bc375205e187e8fb232573387112dd8c0dd45b03af8aa2b3c79eb4b9e3e0dc`.
No son generadores parametrizables de rounding/smoothing.
Las otras 26 entradas convierten `RoundedPolygon.cubics` públicamente.
Todas se evalúan después con el motor propio, no con `material_new_shapes.Morph`.

| Forma | Definición | Canvas | Shader / transición GPU |
| --- | --- | --- | --- |
| circle | Nativa fija derivada | Sí | No; fallback |
| square | Adaptada | Sí | No; fallback |
| slanted | Adaptada | Sí | No; fallback |
| arch | Adaptada | Sí | No; fallback |
| semiCircle | Adaptada | Sí | No; fallback |
| oval | Nativa fija derivada | Sí | No; fallback |
| pill | Nativa fija derivada | Sí | No; fallback |
| triangle | Adaptada | Sí | No; fallback |
| arrow | Adaptada | Sí | No; fallback |
| fan | Adaptada | Sí | No; fallback |
| diamond | Adaptada | Sí | No; fallback |
| clamShell | Adaptada | Sí | No; fallback |
| pentagon | Nativa fija derivada | Sí | No; fallback |
| gem | Adaptada | Sí | No; fallback |
| sunny | Nativa fija derivada | Sí | No; fallback |
| verySunny | Adaptada | Sí | No; fallback |
| cookie4Sided | Nativa fija derivada | Sí | No; fallback |
| cookie6Sided | Adaptada | Sí | No; fallback |
| cookie7Sided | Nativa fija derivada | Sí | No; fallback |
| cookie9Sided | Nativa fija derivada | Sí | No; fallback |
| cookie12Sided | Adaptada | Sí | No; fallback |
| clover4Leaf | Adaptada | Sí | No; fallback |
| clover8Leaf | Adaptada | Sí | No; fallback |
| burst | Adaptada | Sí | No; fallback |
| softBurst | Nativa fija derivada | Sí | No; fallback |
| boom | Adaptada | Sí | No; fallback |
| softBoom | Adaptada | Sí | No; fallback |
| flower | Adaptada | Sí | No; fallback |
| puffy | Adaptada | Sí | No; fallback |
| puffyDiamond | Adaptada | Sí | No; fallback |
| ghostish | Adaptada | Sí | No; fallback |
| pixelCircle | Adaptada | Sí | No; fallback |
| pixelTriangle | Adaptada | Sí | No; fallback |
| bun | Adaptada | Sí | No; fallback |
| heart | Adaptada | Sí | No; fallback |
| `MorphShape.ellipse()` | Nativa procedural | Sí | Sí; solo ellipse → ellipse |

## Elegir formas para botones con icono

`MorphShapeButton` coloca el `child` en el centro del cuadrado `size` y gira la
superficie alrededor de ese mismo centro: el icono no se desplaza nunca. Algunas
formas del catálogo no son simétricas respecto de ese centro (su bounding box está
desplazado, por ejemplo `cookie7Sided` ≈ 1 % hacia arriba, `heart`, `ghostish`,
`pentagon`, `arrow`), y un icono centrado puede parecer descentrado. Para botones
con icono, sobre todo con rotación, preferir formas con simetría rotacional
(`sunny`, `softBurst`, `clover4Leaf`, `clover8Leaf`, `flower`, `softBoom`).
`test/morph_shape_button_center_test.dart` fija ese contrato.

## Loader y botón

Ambos loaders aceptan `shapes` (al menos dos) o `polygons` (legacy, al menos dos),
mutuamente excluyentes, y `renderer`. La secuencia default no cambia. El loader
usa un ticker entre comienzos y conserva la respuesta spring; el intervalo no es
una duración de morph. `TickerMode`, motion reducido y modo manual paran ciclos.
Los cambios de secuencia capturan el contorno actual. El loader entrega contornos
capturados a la vista, por lo que actualmente usa Canvas incluso con elipses.
La envolvente conservadora para toda rotación y la continuidad del transform al
cambiar velocidad/rotación necesitan validación adicional; no se certifica ausencia
de recorte para todo polígono personalizado.

```dart
MorphShapeButton(
  shape: MorphShapeCatalog.cookie7Sided,
  pressedShape: MorphShapeCatalog.softBurst,
  selectedShape: MorphShapeCatalog.pentagon,
  selected: selected,
  rotationOnPress: 0.0, // radianes; solo contenedor
  onPressed: onPressed,
  child: const Text('Guardar'),
)
```

Selección controlada; press tiene prioridad, con fallback a selección/reposo
si falta forma opcional. Reutiliza el lifecycle de interacción de botones;
Material/InkWell es la autoridad de acción. Comparte contorno para tinta, clip y
hit test; el child no rota ni cambia escala. El tamaño exterior mínimo es 48 dp;
la superficie activa sigue el contorno y no garantiza un círculo inscrito de
48 dp para cualquier forma cóncava. Foco visible, tooltip y Semantics incluidos.

## Fuentes consultadas

- [Shapes Compose](https://developer.android.com/develop/ui/compose/graphics/draw/shapes).
- [LoadingIndicator Compose, commit dd7d2935e6a5ab12f6957a813926eea1ca38188e](https://android.googlesource.com/platform/frameworks/support/+/dd7d2935e6a5ab12f6957a813926eea1ca38188e/compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/LoadingIndicator.kt).
- [Fragment shaders Flutter](https://docs.flutter.dev/ui/design/graphics/fragment-shaders).

El nuevo matching no es un port de implementación AndroidX; no se inventa un SHA
de algoritmo. La secuencia compartida con Compose no implica paridad de motion.
