# Botones de operación y skeleton/shimmer

Incluido en Morph Expressive 0.8.0; no modifica los defaults existentes.
Importación: `package:morph_expressive/morph_expressive.dart`.

## Botón controlado

```dart
MorphAsyncButton(
  label: 'Guardar',
  state: operationState, // MorphOperationState: idle/loading/success/error
  onPressed: saveFromTheApplication,
  presentation: MorphOperationPresentation.compact,
  labels: const {
    MorphOperationState.loading: 'Guardando',
    MorphOperationState.success: 'Guardado',
    MorphOperationState.error: 'Reintentar',
  },
)
```

El consumidor posee el estado, los Futures y la cancelación. No hay temporizador
de resultado, duración mínima de carga ni interpretación de excepciones.
`onPressed: null` o `enabled: false` deshabilitan explícitamente. En loading,
`blockWhileLoading: true` bloquea la acción pero conserva colores activos y foco;
no vuelve a generar haptics. `showLoadingLabel: false` deja solo el loader.

Se conserva una instancia MorphButton durante toda la operación. Los cinco
estilos son filled, tonal, outlined, text y elevated; usa los tamaños y la
tipografía de Morph. `icon`, `loading`, `successIcon`, `errorIcon` son opcionales.
El loader predeterminado es MorphLoadingIndicator; éxito/error incluyen símbolos,
no solo color. `tooltip`, `focusNode`, `semanticLabel` y `semanticValue` permiten
personalizar la interacción y traducir la descripción de estado. Hay una sola
región semántica viva; el loader no produce anuncios adicionales por frame.

`preserveWidth` conserva el ancho medido del label de reposo (y su icono);
labels de estado largos usan ellipsis, nunca escalan. `compact` anima hacia un
cuadrado táctil de al menos 48 dp. Constraints tight del padre, `constraints`,
decoration.fixedSize/size.width y límites explícitos tienen prioridad. El alto
se adapta al texto; una constraint explícita menor puede reducir el área táctil.
`shape` admite round/square. La transición de ancho/radio/color parte del valor
visible al interrumpir; el contenido nuevo aparece sin estirarse ni acumular
copias antiguas. `transitionDuration` (280 ms por defecto) es independiente de
pressDuration/releaseDuration (90/160 ms). Reduced motion hace el cambio inmediato.

Precedencia de decoration: scope MorphButton → decoration local → decorations
del tema de operación para el estado → stateDecorations del widget. La superficie
usa MorphRoundedSurface con `renderer`/`onRendererChanged`, Canvas inmediato
mientras carga o falla el shader. Degradados usan el fallback existente.
Un backgroundBuilder explícito conserva su autoridad sobre el renderer y se
informa como Canvas/custom. No se añade otra captura offscreen al MorphButton.

### Colores de error (default semántico)

En `error` (con el botón activo) los defaults usan los tokens de color de
Morph, por estilo: filled `error`/`onError`; tonal `errorContainer`/
`onErrorContainer`; outlined superficie transparente con borde y contenido
`error`; text contenido `error`; elevated conserva su superficie elevada con un
tinte `error` al 8 % y contenido `error`. Contraste comprobado por test (≥ 3:1,
claro y oscuro). El error nunca depende solo del color: cambian icono
(`MorphIcons.error`/`errorIcon`) y label. Disabled mantiene sus colores
deshabilitados, distintos del error.

Precedencia de color en `error`: defaults semánticos de error (por encima de
scope MorphButton y `decoration` local, para que no se confunda con idle) →
`MorphAsyncButtonTheme.decorations[error]` → `stateDecorations[error]`
del widget (gana). Los demás estados no cambian: scope → decoration →
tema → widget.

Ancho preservado: nunca es menor que glifo + gap + label de un estado (acotado
al ancho del label de reposo); así, en botones pequeños sin icono de reposo, el
glifo no aprieta el label hasta recortarlo.

### Transición del glifo (loading → success)

El glifo de estado vive en un espacio cuadrado estable (`iconSize`), sin
recorte. Al cambiar de estado: el glifo saliente baja de escala (→ .8) y pierde
opacidad (0–60 % de la curva) mientras el entrante aparece por opacidad (30–100 %),
escala (desde `initialScale` = .6) y, si es éxito, rotación desde
`successRotation` (−45°) hasta 0°. Ni el botón ni el label se escalan o giran;
el label solo hace su fundido existente. `successIcon`/`errorIcon`/`loading` son
`Widget` arbitrarios; se envuelven con Opacity/Transform, nunca se copian.

Configuración: `MorphAsyncButton.iconTransition` → `MorphAsyncButtonTheme.iconTransition`
→ `MorphOperationIconTransition.defaults` (320 ms, `easeOutCubic`). `.none` (o
reduced motion) cambia de glifo sin giro ni movimiento. Es independiente de
`transitionDuration` (superficie/ancho, 280 ms) y de 90/160 ms de press/release.
Una interrupción parte de la pose visible: el glifo que estaba entrando se
convierte en saliente con su opacidad/escala/ángulo actuales; no hay timers
internos, duraciones mínimas ni retorno automático a idle. Al salir de compact,
el padding crece con el ancho para no desbordar mientras la superficie es estrecha.

## Skeleton

```dart
MorphSkeletonGroup(
  loading: isLoading,
  semanticLabel: 'Cargando perfil',
  placeholder: Row(children: [
    const MorphSkeleton.avatar(),
    const SizedBox(width: 16),
    Expanded(child: MorphSkeleton.lines(count: 3)),
  ]),
  child: profile,
)
```

Formas: `MorphSkeleton`, `.line`, `.lines`, `.avatar`, `.image`, y `shape` del
MorphShapeCatalog. Dimensiones explícitas o ancho disponible; sin ancho acotado,
el genérico usa 120 dp. Para líneas múltiples, proporcionar ancho acotado.
No se infieren placeholders desde widgets reales.

`MorphSkeletonEffect.shimmer`, `.pulse`, `.none`; cuatro direcciones mediante
MorphShimmerDirection. Un controlador por grupo, no por rectángulo. Las posiciones
se transforman al espacio del grupo para un barrido coherente incluso entre
filas de diferente ancho. El FragmentProgram se carga fuera de paint y se comparte;
cada placeholder tiene su propio FragmentShader y uniforms. Cada fragmento solo
cubre su rectángulo. No hay capturas a imagen, backdrop filters ni glow.

### Ángulo de la banda

`MorphSkeletonGroup.angle` (grados) → `MorphSkeletonTheme.angle` → 0. 0° es el
aspecto aprobado. La banda es la banda sin inclinar (perpendicular a la
dirección) girada en sentido horario en pantalla: con izquierda/derecha es la
inclinación respecto a la vertical (positivo `/`, negativo `\`); con
arriba/abajo gira igual la banda horizontal. `direction` sigue decidiendo el
sentido de avance; el ángulo solo decide la inclinación. Se calcula en el
espacio común del grupo: la fase se normaliza sobre la proyección del rectángulo
del grupo en la normal de la banda (cubre esquinas) y el ancho visual de banda se
mantiene en .2 del eje sin inclinar (acotado en ángulos próximos a ±90°).
Shader y Canvas usan las mismas fórmulas (`morphShimmerGeometry` / `uAngle`).
Pulse y placeholder estático ignoran el ángulo; la fase no se reinicia al
cambiarlo. No se rota el árbol ni las formas.

Shimmer auto/shader usa el fragment shader cuando está disponible; Canvas usa
un degradado con la misma fase y espacio. Pulse y estático se pintan en Canvas.
Las formas del catálogo usan Canvas con MorphEdgeCoverage para respetar su
contorno exacto; el estado efectivo del grupo describe los rectángulos, no
convierte los contornos del catálogo a un shader procedural.

Precedencia: widget → MorphThemeData.skeletonTheme → colorScheme/defaults.
Configurable: duration (1600 ms), transitionDuration (180 ms), intensity (.35),
baseColor, highlightColor, enabled, renderer y callback efectivo. Ambos temas
nuevos ofrecen copyWith/lerp/igualdad y se conservan al copiar MorphThemeData.
Los mapas de decorations de operación son inmutables por contrato; al interpolar
se elige un mapa en t=.5, como configuración discreta.

El contenido real conserva layout; durante loading tiene IgnorePointer,
ExcludeFocus y ExcludeSemantics. El crossfade no muestra un frame vacío ni permite
activar contenido oculto. Usar tamaños equivalentes en placeholder/contenido para
mantener espacio estable. Una inversión retargetea desde la opacidad visible.
Reduced motion usa placeholders estáticos y cambio inmediato. Disabled, contenido
visible y TickerMode desactivado detienen el reloj. Dispose libera controlador y
shaders. Para listas, usar el TickerMode y el montaje/desmontaje del viewport;
no hay un sistema global de visibilidad. Un grupo independiente tiene fase propia.

## Grupo reactivo de botones

`MorphReactiveButtonGroup` es un componente nuevo; `MorphButtonGroup` (incluido
el connected aprobado) no cambia. Reutiliza `MorphButton`, el tema del grupo
(`connectedGap`, alturas) y radios por decoración; no duplica overflow ni
medición del grupo clásico.

Modos (`MorphReactiveGroupMode`): `singleSelect` (`selectedIndex`; tocar el
seleccionado lo limpia salvo `selectionRequired`), `multiToggle`
(`selectedIndices`) y `actions` (nunca seleccionado; `onPressed` por item).
Estado siempre del consumidor; selección/toggle/acción se confirman por el tap
normal del botón, nunca en pointer down. Cancelación por scroll/arrastre no
dispara nada y restaura anchos. Varios punteros: cada botón mantiene su presión
y se resuelven juntos con la misma distribución.

Distribución (`resolveReactiveWidths`, un único estado común animado por un
ticker; el render object relayouta, no reconstruye). Base estable: los anchos
naturales y el alto de fila se miden solo cuando cambian contenido, tema o
constraints (nunca desde el resultado animado) y los hijos reciben alto tight,
así que el alto no varía durante la interacción. Ancho natural de cada botón
(contenido, padding, iconos, `minWidth`; icon-only mínimo cuadrado) →
`fit`: `fill` (ancho acotado: reparte la holgura proporcional al natural; la
expansión mueve ancho entre hermanos, total constante), `natural` (la expansión
solo consume holgura; hermanos no ceden) o `uniform` (anchos iguales). Con
ancho no acotado nunca se reparte infinito: anchos naturales y el item pulsado/
activo crece su razón sin que otros cedan. Destino por item =
`max(selectedExpansion si seleccionado, pressedExpansion si pulsado)`, no suma.
`pressedExpansion` vale .15 y `selectedExpansion` .08 por defecto: son la razón
del ancho en reposo (un botón de 130 dp pulsado gana ≈ 20 dp). Compensación local: cada item
que pide ancho lo toma solo de sus vecinos adyacentes (mitad y mitad; en un
extremo, del único vecino; si uno no tiene holgura, del otro). Los elementos
lejanos no cambian. Un vecino sin holgura cede menos (saturación suave); la parte
no cedida no se reencamina al otro lado, para no provocar saltos ni ondas. Los donantes ceden solo lo que supera su ancho natural,
ponderado por lo poco que piden (un seleccionado pierde su ganancia cuando su
vecino pulsado la reclama); si no hay holgura la amplitud es 0 (se conservan
formas y feedback);
si el padre no cabe ni los naturales se comprime proporcionalmente con ellipsis.
Sin anchos negativos ni overflow; con todos activos solo cambian las formas.
La evolución es un sistema crítico amortiguado por valor (ω 30/22 rad/s, sin
overshoot ni salto de velocidad), con dt acotado.
`width` fija un item fuera del reparto. Los valores visibles se retargetean
(posición y velocidad se conservan), reduced motion salta al destino.

Formas: radios en dp por grupo o item (`restRadius`, `selectedRadius`,
`pressedRadius`); el resto es pill/circular y el seleccionado/pulsado usa los
defaults más cuadrados de `MorphButton`. Estilos por item (`style`,
`decoration`) permiten el botón central de los controles multimedia. Texto,
iconos y labels nunca se escalan; ellipsis solo cuando no caben; el texto
completo permanece en Semantics. RTL invierte el orden; hit testing, splash y
foco pertenecen a cada superficie (el layout asigna el tamaño real). Limitación:
si un `selectedLabel` cambia el ancho natural, el cambio es inmediato.

## Preview y ejemplos

Galería → **Operation & Skeleton Lab**. Acceso estable Web: `?lab=operations`.
Web: `?lab=operations&section=async|groups|shimmer` salta a la sección.
Revisión nativa opcional: `--dart-define=MORPH_OPERATION_SECTION=async|groups|shimmer` salta a la sección y `MORPH_OPERATION_AUTORUN=true` repite loading→success.
Linux: `flutter run -d linux --release --dart-define=MORPH_LAB=operations`
desde `preview/`. El archivo `preview/lib/operation_loading_lab.dart` es el
ejemplo compilable de las simulaciones con generaciones/timers cancelables.

Secciones nuevas: **AsyncButton polish** (cinco estilos en error, override y
disabled, loading→success/error/loading, repetición, interrupción durante la
entrada, normal 320 ms/lento 1400 ms, icono por defecto y Widget propio,
animación desactivada, compact/preserve), **Reactive button groups** (los tres
modos, conectividad, dos controles multimedia, icon-only/label-only/icon+label,
varios activos y todos activos, contenedor 560/260, labels largos, uniforme,
sliders de expansión/radios/gap y comparación con el connected anterior) y, en
el shimmer, control de ángulo −90…90 con presets y comparación entre grupos
(0°, ±30°, ancho/estrecho).

Incluye cinco estilos y ambos anchos, estados manuales, éxito/error/reintento,
resultado inmediato, interrupciones, disabled, texto largo, iconos, loader
personalizado, tamaños, tarjeta, lista de ocho filas, pósteres, forma de catálogo
y grupos independientes. Controles de claro/oscuro, móvil, texto 2×, RTL, reduced
motion, duración, dirección, intensidad y renderer solicitado/efectivo.

No se prometen mejoras de rendimiento. El coste del sweep Canvas es por contorno
y el del shader por rectángulo; la solución conserva el suavizado existente.

## Validación local — 2026-11-11

- Análisis raíz sin incidencias. Suite focalizada de operación/skeleton,
  presión y rotación: 24 pruebas aprobadas. Suite preview: 57 aprobadas,
  incluidos 390/1440 px con texto 2×. Pruebas específicas comprueban sincronía
  por raster (tolerancia de un nivel de cuantización de 8 bits), independencia
  de grupos, TickerMode, reduced motion, foco/teclado, semántica, reversión y dispose.
- `tool/check.sh`: guardas Python, imports y análisis aprobados; suite raíz
  1051 aprobadas y tres fallos históricos identificados en el informe R3:
  `list_expandable_test`: `expandable nested last row closes bottom radii`,
  `sublist last row rounds its bottom unless opted out`;
  `text_field_test`: `MorphTextField centers the label until it floats`.
  No se tocaron esas familias. La suite preview se ejecutó por separado.
- Compilaciones Web y Linux release aprobadas. Revisión nativa real mediante
  `MORPH_OPERATION_REVIEW=true`, Impeller OpenGLESSDF: varios botones cargando,
  compactos/preservados, error, lista de ocho skeletons y configuración
  reduced/RTL/móvil/texto 2×. Las capturas detectaron y permitieron corregir el
  loader filled de bajo contraste (regresión añadida); la revisión posterior
  muestra contraste y bordes suaves. Evidencia temporal: `/tmp/opencode/operations-native-*.png`.
- Chromium headless a 1440×1000: cambios idle/loading/error, interrupciones,
  Canvas/Shader efectivos, contenido real/retorno a loading y claro/móvil/RTL/2×.
  Sin excepciones JS de la app. Queda un 404 de `/favicon.ico` del servidor
  de preview; también persiste la advertencia de build sobre fuentes Material/
  Cupertino de ejemplos existentes. El nuevo laboratorio usa Fluent.
- Muestra orientativa de 120 intervalos requestAnimationFrame en Chromium
  headless, varios botones en loading y grupos de skeleton animados: mediana
  16.7 ms, p95 33.4 ms, máximo 50 ms. **No es una medición GPU ni de build/raster
  Flutter**, ni prueba de mejora; hubo intervalos que exceden un presupuesto
  de 16.7 ms. No se certifica rendimiento en otras GPU/DPR ni listas extensas.
- Gate de nomenclatura disponible en `tool/ci/check_final_release_language.py`
  aprobado. Las instrucciones locales ya apuntan a esa ruta; consultar la
  auditoría de automatización en [el informe 0.8.0](RELEASE_0_8_0.md) para el
  estado posterior de herramientas y publicación.

Implementación final del alcance descrito; no hay cambios de versión, commit,
push, tags ni publicación. CI y validación en otras plataformas pendientes.
