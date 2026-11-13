# Informe final de implementación — corrección visual e interacción posterior a R3

**Proyecto:** Morph Expressive (`morph_expressive`). Versiones sin cambio
(raíz 0.7.0, preview 0.2.0+1).
**Estado:** implementado y validado localmente; push, CI y publicación
pendientes. Sin commit, tag ni cambios de runners o SDK.
**Base del parche:** copia exacta del checkout post-R3 (con los cambios previos
del usuario) tomada al empezar; este trabajo solo contiene lo posterior.

## Qué probar

Laboratorio Web: <http://127.0.0.1:8081/?lab=shapes> (servidor
`python3 -m http.server 8081 --directory build/web` desde `preview/`).
Accesos directos a sección: `&section=buttons|edges|groups|loader`.
Nativo Linux: `preview/build/linux/x64/release/bundle/morph_expressive_preview`
(construido con `--dart-define=MORPH_LAB=shapes`; la sección se elige con la
variable de entorno `MORPH_LAB_SECTION`).

## Causas encontradas y solución

| Síntoma | Causa medida | Solución |
| --- | --- | --- |
| Bordes Canvas escalonados | En Linux/Impeller OpenGLESSDF `drawPath`, clips y un `saveLayer` simple sobre la ventana tienen cobertura binaria aunque `isAntiAlias` sea `true` (ya lo es por defecto). Una imagen offscreen sí mostró alpha parcial (96 píxeles de borde en un círculo de prueba), por lo que **ninguna sonda offscreen predice el resultado en pantalla** y se descartó. El Shader (cobertura analítica) no se ve afectado. | `MorphEdgeCoverage` (`lib/foundations/shape/morph_edge_coverage.dart`): ocho rellenos desplazados a sub-píxel, mezcla aditiva en una capa acotada a los bounds del contorno y coloreado con `srcIn`; 9 niveles de cobertura. Compartido por `MorphShapeView` (geometría, loader) y la superficie de `MorphShapeButton`. Política `MorphEdgeAntialias` (`auto` = muestras, `native`, `coverageSamples`). Coste: 8 rellenos + 1 capa del tamaño de la forma; sin imágenes ni texturas retenidas. En Skia/backends con MSAA `native` sigue disponible. |
| Corte diagonal del ShapeButton | Contornos del motor verificados sin autointersecciones en los pares del lab, loader y botón, y en retargets A→B→C (`test/morph_contour_integrity_test.dart`): el path es correcto. La pila de recortes (`ClipPath` + `Material` con forma y `Clip.antiAlias`) heredaba el recorte binario del backend. | Una sola superficie dibujada con `MorphEdgeCoverage`; la tinta se recorta con un único clip vivo. No se tocó el matching ni se amplió ningún canvas. |
| Grupo One/Two/Three "de toggles sueltos" | El lab instanciaba `MorphButtonGroup` con `type: standard`. | El lab usa `type: connected` (mismo widget productivo que la galería). |
| Radios exteriores invertidos en RTL | `isFirstInGroup/isLastInGroup` ya llegan como bordes físicos izquierdo/derecho, pero `morph_button_selection_shape.dart` los resolvía como `BorderRadiusDirectional` (doble inversión). | Radios físicos; pruebas de seleccionado izquierda/centro/derecha en LTR y RTL. El seleccionado es píldora (`alto/2`) en cualquier posición; los no seleccionados conservan extremo exterior completo e interior pequeño. |
| Vecinos cedían ancho sin límite durante el squish | `_shrinkNeighborsForSquish` solo acotaba a ≥ 0. | `_applySquishSizes` limita lo que cede cada vecino a `min(20 % de su ancho, 14 dp)`; la expansión del pulsado se reduce a la holgura real y el ancho total queda constante. Sin `Transform.scale`, fades ni `Clip.none`. |
| Loader contenido sin separación | Sin token de inset; el contorno de formas anchas (gem/sunny) superaba el radio útil. | `containedInset` (tema `MorphLoadingIndicatorTheme`, 5 dp por defecto; override local en `MorphLoadingIndicator`). Ver política. |
| ShapeButton solo morph | La API no tenía rotación continua ni compresión propia. | Ver semántica. |

Límite de la reproducción del corte: la captura original no estaba disponible en
este entorno; la causa se acotó por descarte (path sin defectos, clips
apilados con cobertura binaria medida). No se pudo comparar pixel a pixel con
la captura del usuario.

## `MorphShapeButton`: semántica y defaults

Firmas anteriores intactas. Nuevas opciones:

* `rotationEnabled` (default `false`), `rotationDuration` (default 8 s por
  vuelta, > 0), `rotationDirection` (`MorphShapeRotationDirection`).
  Gira la **superficie** alrededor de su centro fijo; el contenido no gira, no
  se escala ni se recorta. Cambios de duración/dirección conservan la fase
  visible; desactivar pausa en el ángulo actual. Reduced motion y `TickerMode`
  detienen el ticker; se libera en `dispose`.
* `pressedScale` (default 0.96, válido (0.5, 1.2]): compresión uniforme con el
  perfil 90/160 ms, reversible desde el tamaño visible.
* `pressedShape` / `selectedShape`: morph **opt-in**; `null` conserva la forma.
* `rotationOnPress` (radianes) se conserva como desplazamiento puntual al
  pulsar; no es la velocidad de la rotación continua.
* `edgeAntialias`: ver arriba.

Envolvente: con rotación, la superficie se escala con un factor estable
`0.5 / R` (R = radio máximo de todas las formas configuradas) para no salir
del cuadrado `size`; el factor se interpola con el perfil de press/release al
cambiar. El layout no cambia. Hit test: cuadrado `size` (≥ 48 dp), no el
contorno. Reduced motion: sin rotación ni animación, con compresión estática.
Disable/scroll durante la pulsación liberan sin acción.

## Política de inset del loader contenido

* `containedInset` en dp absolutos, precedencia: parámetro local > tema (5).
  Solo variante contenida. Validación: finito, `>= 0` y `< min(ancho, alto)/2`
  (`ArgumentError`).
* Presupuesto radial = `min(ancho, alto)/2 − inset` (19 dp para 48/5). Se
  calcula el radio máximo al centro de **todas** las formas de la secuencia, el
  pulse máximo (simulación del resorte) y la rotación libre (la cota es radial).
  Si no cabe, el tamaño activo se escala uniformemente (una vez por secuencia,
  no por frame). Cambios de secuencia en vivo animan ese factor (240 ms).
  El progreso geométrico ya está acotado a [0, 1] y la interpolación punto a
  punto no supera el radio de los extremos.
* Contenedores no circulares: se usa el círculo inscrito (conservador). La
  variante sin fondo no cambia.

## Pruebas nuevas

`test/morph_edge_coverage_test.dart` (DPR 1/1.5/2, posición fraccionaria, perfil
de borde frente al path Canvas directo, sin halo, sin recorte en bounds),
`morph_group_connected_shape_test.dart` (radios LTR/RTL, squish con texto 1×/2×,
etiquetas pintadas por frame mediante raster), `morph_loader_inset_test.dart`
(separación radial medida por raster en la secuencia completa, secuencia ancha,
cambio live, rotación manual, reduced motion, validación),
`morph_shape_button_surface_test.dart` (compresión 0.96, reversibilidad, morph
opt-in, rotación solo de superficie, fase conservada, ticker lifecycle, scroll
cancel/disable, semántica), `morph_contour_integrity_test.dart`, y ampliación
de `preview/test/shape_morph_lab_test.dart` (390 px con texto 2× en claro y
oscuro, 1440 px, demo principal con rotación y sin morph).

## Validaciones ejecutadas (este checkout)

| Check | Resultado |
| --- | --- |
| `flutter analyze` raíz y preview | Sin diagnósticos |
| Tests raíz | 980 aprobados, 3 fallidos (`list_expandable_test`: `expandable nested last row closes bottom radii`, `sublist last row rounds its bottom unless opted out`; `text_field_test`: `MorphTextField centers the label until it floats`) |
| Mismos tres en la base post-R3 preservada | Sí: mismas aserciones (300 vs 312.71; radios 4.5 vs 9.0) |
| Tests preview | 54 aprobados, 1 fallido (`morph_gallery_interactions_test`: `tab preview includes secondary tabs and a swipeable view`, "a menu cannot be empty"); idéntico en la base |
| `python3 tool/check_dependency_imports.py` | OK (se añadió `show MaterialApp` en `test/morph_minor_visual_fixes_test.dart`) |
| `bash tool/check.sh` | Llega al análisis (limpio, tras quitar tres imports/llaves triviales preexistentes) y se detiene en los tres fallos preexistentes; los tests de preview se ejecutaron aparte |
| Gate de nomenclatura `--all`, `git diff --check` | Ver cierre de la entrega |
| `dart format --set-exit-if-changed` global | No verde por archivos ajenos preexistentes; los archivos de este trabajo están formateados |
| Build Web / Linux release | Aprobados |
| Revisión visual | Linux nativo (Impeller OpenGLESSDF, release): bordes suaves en geometría, elipses Canvas/Shader, botones girando, loader contenido con separación, grupo connected con seleccionado a la izquierda y al centro. Web (Chromium headless, swiftshader, 1440 px): sección de botones sin errores de consola propios. |

No validado: fotograma de compresión del grupo en nativo (sin entrada sintética
disponible; cubierto por la prueba raster), GPU del usuario, rendimiento,
390 px en navegador real (cubierto por test de widget), CI y dependencias
latest/lowest.

## Límites vigentes

* El matching sigue siendo heurístico: 6 pares del catálogo se autointersectan
  a mitad de transición (`cookie12Sided→pixelTriangle`, `ghostish→heart` y sus
  inversos, `pixelTriangle→bun` y su inverso); ninguno está publicado en el lab,
  el loader por defecto ni los botones. No se promete cualquier topología.
* El Shader procedural sigue limitado a elipses; el resto usa Canvas con
  cobertura por muestras (9 niveles, no cobertura analítica).
* Grupos connected: los segmentos son de igual ancho; etiquetas que no caben en
  reposo siguen la política de overflow existente (recorte), no se alteran.
* `MorphEdgeAntialias.auto` no detecta el backend: siempre usa muestras.

## Ajustes finales: ancho uniforme y regresión de suavizado

### Ancho automático de grupos connected

`MorphButtonGroup(type: connected)` ya no expande al ancho disponible. Una fila
propia (`morph_button_group_uniform_row.dart`) mide cada botón con su layout
real (texto, escala, iconos, padding, gaps, RTL; sin contar caracteres) y usa el
contenido **más ancho como ancho común de reposo**; los estados seleccionados
con contenido distinto aportan su medida como suelo, de modo que seleccionar no
cambia el ancho. Se limita al presupuesto por elemento
(`(extent disponible − gaps) / n`, nunca negativo; sin límite horizontal se usa
el ancho natural finito) y entonces la etiqueta de texto simple conserva una
línea con ellipsis (sin escalar ni recortar a mitad de glifo; Semantics conserva
el texto completo). Etiquetas personalizadas (no `Text`) y estados de etiqueta
animados mantienen su política anterior de recorte.

* Nuevo `MorphButtonGroup.itemWidth` (`null` = automático). Precedencia:
  `MorphButtonGroupAction.width` (solo esa acción) > `itemWidth` > automático;
  siempre sujeto a constraints y a `maxWidth` del tema.
* Se re-mide en cada reconstrucción del grupo (contenido, tipografía, text
  scale, locale, dirección) y no por frame. Las restricciones hijas son casi
  tight a propósito: con tight el botón es límite de relayout y un cambio de
  contenido interno no llegaría a la fila.
* Animación de selección/press, radios y squish de grupos estándar sin cambios;
  los connected siguen sin variar ancho al pulsar.
* El test `connected group fills bounded width...` fijaba el comportamiento
  anterior (expandir); se reemplazó por la nueva especificación.

### Suavizado tras alternar opciones

**No reproducido.** Secuencia probada (arnés `preview/lib/edge_stress.dart`,
`--dart-define=MORPH_EDGE_STRESS=true`, Linux release / Impeller OpenGLESSDF,
32 capturas): una instancia viva recibe canvas → shader → shader con forma no
soportada → auto con morph → auto con rotación → shader a 122 dp → canvas native
a 48 dp → contorno capturado → cambio de color → forma distinta → shader →
configuración inicial, junto a una instancia nueva con la misma configuración.
`MorphShapeView`: 0 píxeles de diferencia en todas las muestras. `MorphShapeButton`
(selected/pressedShape/enabled/rotationOnPress/edge mode) y loader contenido:
bordes suaves, diferencias solo sub-píxel entre viva y nueva. Misma secuencia en
tests deterministas (`test/morph_shape_view_state_test.dart`, vista y botón, con
una instancia vecina que no se contamina). No se modificó el renderer. Hipótesis
sin confirmar: el modo `native` del laboratorio (B2) produce bordes binarios en
este backend por diseño y puede haberse dejado seleccionado.

## Cierre de correcciones visuales y pulido de interacción

### Antialiasing en sliders, progress, splash y swipe actions

Causa común comprobada en Linux (Impeller OpenGLESSDF, release): la superficie
de la ventana no tiene cobertura parcial para `drawPath`/`drawArc` ni para
clips duros, mientras que un **render target de imagen** del mismo backend sí
la tiene (un `saveLayer` simple y un único relleno AA dentro no bastan; sí
bastan las capas con muestras de `MorphEdgeCoverage` para formas propias). Los
painters de sliders y progress no habían cambiado respecto a HEAD: el defecto
no es una regresión de código sino del backend, visible ahora que las formas
propias ya eran suaves. Reproducción mínima: `preview/lib/aa_probe.dart`
(`--dart-define=MORPH_AA_PROBE=true`), un `MorphSlider.wavy` pintado directo
(escalonado) frente a envuelto (suave), medido en pantalla.

Corrección compartida: `MorphSmoothEdges` (`lib/foundations/shape/
morph_smooth_edges.dart`) rasteriza el subárbol con `OffsetLayer.toImageSync` a
`dpr × escala` y lo copia 1:1; layout, hit testing y semántica no cambian. Se
aplica en `MorphSlider`/`MorphRangeSlider`, `MorphProgressIndicator`
(circular, wavy, lineal, lineal wavy), el núcleo de `MorphButton` (incluye
splash/state layers, `bleed` 12 dp) y `MorphListSwipeActionButton` (clip
redondeado). Modo global `MorphSmoothEdges.defaultMode`
(`auto` = Linux de escritorio, no Web; `enabled`; `disabled` = referencia
directa) y override por instancia. No se tocó el SDK; no se simplificó ninguna
curva. Límites: no cubre otros componentes con tinta (icon buttons, chips,
listas), el coste por frame es una textura del tamaño del componente (no medido
en GPU) y la inspección visual del splash en movimiento no se pudo hacer sin
entrada sintética: solo se verificó el estado estático en pantalla.

### 360° exactos (shapes)

`rotate(2π)` deja una transformación casi identidad y el rectángulo del shader
(ajustado a los bounds de la elipse) se recortaba/rasterizaba distinto en el
extremo superior. Medido en nativo con la build anterior: 0°, 360° y 360°+1e-7
rad difieren en 18 y 37 px del borde; con la corrección son idénticos.
Cambios: `normalizeMorphRotation` (módulo 2π, ajuste a vueltas/cuartos
completos con 1e-9; solo para evaluar, la fase de animación no se reinicia) y
rectángulo del shader inflado 2 dp. Los tests de software no discriminan (la
base también pasa): la verificación decisiva fue visual en Linux. Además, la
carga del shader ya no cachea un `Future` pendiente (podía pertenecer a una
zona muerta y nunca completar).

### Gap en grupos connected

`MorphButtonGroupTheme.connectedGap` (default **4 dp**, `0` permitido) con
precedencia `MorphButtonGroup.spacing` → tema → default; ya integrado en
`copyWith` y `lerp`. El eje es el principal del grupo (vertical incluido), se
descuenta del presupuesto antes de repartir el ancho común y es independiente
del padding de los botones. El foco ya no ensancha el gap vecino (hacía el
espaciado no uniforme); con gaps menores que el aro, este solapa al vecino.

### FAB Menu: una superficie principal

Antes el menú abierto era un segundo FAB en el overlay y el cierre
retiraba el overlay al instante. Ahora hay **una** superficie
(`morph_fab_menu_overlay.dart`) en el overlay (siempre mostrado, anclado al
hueco del layout; sin Overlay se pinta en línea) cuyo tamaño, radio y colores
se interpolan con el mismo controlador en ambos sentidos y parten del valor
visible al interrumpir. Solo el icono tiene su propia animación (giro +
fundido). Scrim e items existen mientras algo esté abierto o colapsando; los
items colapsan con el resorte y se desvanecen. `MorphFabMenu.renderer` /
`onRendererChanged`: la superficie usa `MorphRoundedSurface`
(`shaders/morph_rrect.frag`, distancia exacta a rect redondeado) y cae a Canvas
(`RRect` con `MorphEdgeCoverage`) mientras carga, si falla o con degradado;
el estado efectivo se informa y se muestra en el lab. `decoration.backgroundColor`,
`foregroundColor` y `backgroundGradient` se respetan; `side` y otras partes de
`MorphFabDecoration` no se aplican a esta superficie. Los tests antiguos que
buscaban `MorphFab` ahora buscan `MorphRoundedSurface`.

### Submenús: hover por defecto

`MorphMenuSubmenuBehavior({mode, hoverDelay = 200 ms, closeDelay = 250 ms})`
(`MorphMenuSubmenuOpenMode.hover | click`), aceptado por `MorphMenu`,
`MorphMenu.entries`, `showMorphMenu` y propagado a todos los niveles. Hover
(solo ratón) abre tras el delay; entrar en otra fila cancela lo pendiente;
cruzar padre → submenú no cierra (la presencia del puntero en cualquiera de los
paneles cancela el cierre); salir de ambos cierra tras `closeDelay`; los timers
se cancelan al cerrar/disponer; solo hay una rama abierta. Click/tap y teclado
abren al instante; un click sobre la fila cuyo submenú ya está abierto lo
mantiene (el scrim del submenú ignora ese tap). Touch usa tap.

### Semantics de menús

`a menu cannot be empty` venía de `MorphNavigationRail` (`role: menu` fijo): un
viewport puede recortar todos los destinos y Flutter no admite un menú vacío.
Nuevo `MorphMenuSemantics`: decide con los nodos hijos reales y solo expone el
rol mientras hay hijos (no se simula ningún elemento ni se silencia la
aserción). Lo usan el rail y los items del FAB Menu (que además se excluyen de
Semantics mientras están cerrados). Este cambio hizo pasar el test
`morph_gallery_interactions_test` que fallaba con ese mensaje. La aserción
`node.parent?._dirty != true` no apareció en ninguna de las pruebas con
Semantics activado (menús, submenús hover, FAB abierto/cerrado/interrumpido,
rail recortado), por lo que **no se pudo reproducir ni se afirma corregida**. La
advertencia GDK del cursor no se investigó (no afecta a las rutas probadas).

### Preview

Secciones nuevas: B3 componentes con bordes (modo de suavizado), H FAB menu
(abrir/cerrar, inversión a mitad, ×8 rápido, cámara lenta ×6, renderer
solicitado/efectivo), I submenús (hover/click, delays), gap 0/4/8 y presets de
rotación 0/359.999/360/360.001/720/−360. Accesos: `?section=components|fab|
menus|groups|edges|loader|buttons`; nativo: `MORPH_LAB_SECTION`; `MORPH_FAB_AUTO=1`
abre y cierra el FAB solo en cámara lenta.
