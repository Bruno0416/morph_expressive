# Navegación Morph e indicadores de onboarding

Esta guía describe las APIs de navegación de Morph Expressive 0.6.1.
Al migrar desde 0.5.0 debes actualizar los destinos `Widget` a `IconData` y
revisar los constructores `.morph()` / `.expressive()`, cuya asignación visual
se corrigió en 0.6.0.
El constructor sin nombre conserva la selección Material estándar. Las
variantes nombradas no requieren nuevas dependencias.

## Selección que viaja entre destinos

Usa `MorphNavigationBar.expressive` para la píldora elástica Material 3, y
`MorphNavigationRail.morph` / `MorphNavigationDrawer.morph` para la misma
selección compartida en rail/drawer. La barra `MorphNavigationBar.morph`
tiene en cambio una línea superior que viaja entre los destinos. Ambas
variantes nombradas mantienen `motion: MorphNavigationMotion.morph`; el
constructor sin nombre mantiene su comportamiento estándar. Puedes cambiar
el campo `motion` dinámicamente si necesitas control directo.

Una única figura recorre las posiciones reales de los destinos. El extremo
delantero comienza de inmediato y el posterior utiliza `selectionDelay`
(60 ms horizontal / 20 ms vertical por defecto) antes de seguirlo con Motor. Los cambios rápidos cancelan el
retardo anterior; movimiento reducido alinea todos los bordes sin espera.
Se conservan los
iconos, etiquetas, badges, teclado, foco y callbacks; la geometría se vuelve a
medir para RTL, secciones, ancho variable y escalado del texto. Los overlays
capturan el tema y la preferencia local, y actualizan la selección externa.

El rail tiene ahora destinos expandidos de 48 px (antes 56), indicador de 48 px,
destinos colapsados con etiqueta de 60 px y separación de 6 px. Los targets nunca
bajan de 48 px. Todos estos valores siguen siendo personalizables con
`MorphNavigationRailTheme` (`itemExpandedHeight`, `itemCollapsedHeight`,
`shortItemHeight`, `expandedIndicatorHeight`, `expandedItemGap`,
`itemVerticalGap`, etc.).

## Iconos como `IconData` y tamaño compacto

Los destinos de `MorphNavigationBar` reciben ahora `IconData` directamente.
No hay que construir un `Icon` manualmente; la barra resuelve el color y el
`IconTheme` según el estado de selección:

```dart
MorphNavigationBarDestination(
  icon: MorphIcons.home,
  selectedIcon: MorphIcons.search,
  label: 'Home',
)
```

Si necesitas un icono completamente personalizado, utiliza `iconWidget` y
`selectedIconWidget` en lugar de `icon`/`selectedIcon`; no mezcles ambos
modos en una misma propiedad. Los badges siguen envolviendo al icono.

El tamaño base de los iconos se configura mediante `iconSize`, disponible
para `MorphNavigationBar()`, `.expressive()` y `.morph()`. La escala relativa
`unselectedIconScale` permite dar mayor énfasis al destino activo, sin cambiar
la geometría táctil ni el tamaño del layout:

```dart
MorphNavigationBar.morph(
  iconSize: 32,
  unselectedIconScale: 0.9, // 28.8 dp visuales en inactivos; 32 en activo.
  destinations: destinations,
)
```

`unselectedIconScale: 1.0` (predeterminado) mantiene el mismo tamaño visual
seleccionado/inactivo. Valores superiores a `1.0` amplían los inactivos. Al
cambiar de selección el tamaño se interpola mediante el resorte existente,
respetando la preferencia de movimiento reducido. Los iconos personalizados
(`iconWidget`) también se escalan al pintarse, aunque `iconSize` se aplica
mediante el tema de iconos y depende de que el widget lo respete.

La variante `.expressive()` mantiene **64 dp** por defecto. En `.morph()`,
la altura compacta es **76 dp** para separar el indicador superior del icono
de 32 dp; el contenido se desplaza ligeramente hacia abajo con un valor
limitado por `clamp` según la altura real. Las dos permiten
`size: MorphNavBarSize.medium` (base de **80 dp**, ajustable por el
contenido). El constructor estándar
`MorphNavigationBar()` conserva **80 dp** por defecto, y `safeArea` sigue
respetando el área de navegación del sistema cuando la barra está acoplada.

## Distribución de destinos en `wide`

Por defecto los destinos de `MorphNavBarLayout.wide` se agrupan en el centro
(o en el extremo elegido mediante `alignment`). Para ocupar visualmente todo
el ancho con centros equidistantes, usa `distributeWideDestinations: true`:

```dart
MorphNavigationBar.expressive(
  autoLayout: false,
  layout: MorphNavBarLayout.wide,
  distributeWideDestinations: true,
  destinations: destinations,
)
```

El parámetro funciona igualmente en los constructores estándar y `.morph()`,
cuando el layout resuelto es `wide`. No altera el layout compacto, conserva el
ancho del indicador/píldora y los destinos siguen siendo accesibles. Con la
distribución equitativa se ignora `alignment`; para volver al agrupamiento
anterior basta con `distributeWideDestinations: false` (valor por defecto).

## Pull-to-refresh con scrolling anidado (desde 0.6.1)

A partir de **0.6.1**, `MorphNavigationBarHost` mantiene `onRefresh` como
única API necesaria tanto para una lista simple como para `NestedScrollView` con pestañas (`PageView`) y
listas verticales internas (`CustomScrollView`). El host selecciona una sola
fuente vertical por arrastre, usando el contexto de la notificación en lugar de
suponer que todo el contenido informa `depth == 0`. Los gestos horizontales no
participan en el reconocimiento del refresh.

Si el host tiene un `ScrollController` conectado al scroll exterior, solo
permite iniciar un refresh cuando ese scroll también está en su borde inicial:
no debe refrescar mientras un encabezado colapsable todavía está retraído.
La barra flotante, el glass y el retorno al inicio siguen siendo independientes.

La visibilidad de la barra también observa los scrollables verticales anidados,
independientemente del refresh. Durante un arrastre diagonal, un movimiento
vertical efectivo puede ocultar o revelar la barra aunque el gesto tenga una
componente horizontal. Los swipes que el `PageView` reconoce como horizontales
no la ocultan, y la selección de una única fuente evita sumar dos veces
los desplazamientos emitidos por el scroll padre y el hijo.

Para que la comprobación del borde inicial global funcione con encabezados
colapsables, conecta el `controller` recibido en `body` al `NestedScrollView`
exterior (o proporciona uno equivalente mediante `scrollController`). El
`PageView` puede conservar sus listas internas y la física de scrolling
apropiada. El filtro del refresh y la lógica de visibilidad son independientes:
la barra puede ocultarse por un gesto diagonal aunque el refresh no esté
habilitado. Si el usuario cambia de pestaña y `onRefresh` pasa a `null`, el
host deja de construir el indicador.

El host no impone un scroll vertical cuando Flutter interpreta el gesto como
horizontal: no se refresca ni se oculta la barra por un cambio de página puro.

```dart
MorphNavigationBarHost(
  onRefresh: () => reloadHome(),
  bar: MorphNavigationBar.morph(
    floating: true,
    destinations: destinations,
  ),
  body: (context, controller, padding) => NestedScrollView(
    controller: controller,
    headerSliverBuilder: (context, _) => headerSlivers,
    body: PageView(children: catalogTabs),
  ),
)
```

Si el contenido es demasiado corto para desplazarse, configura
`AlwaysScrollableScrollPhysics` en la lista vertical correspondiente. El host
no crea ningún indicador cuando `onRefresh` es `null`. Para páginas con scroll
anidado, las pruebas deben realizar un arrastre real y verificar que el
callback espera su `Future`, en lugar de comprobar solo la presencia del widget.

## Barra con indicador superior

```dart
MorphNavigationBar.morph(
  selectedIndex: selected,
  onDestinationSelected: select,
  destinations: destinations,
  topIndicatorWidth: 40,
  topIndicatorHeight: 4,
)
```

Muestra una barrita superior deslizante, icono activo y etiqueta seleccionada.
Usa disposición compacta incluso en pantallas anchas. `iconSize` (32 por defecto
en `.morph`) y `labelStyle` permiten ajustar iconos y tipografía. `labelBehavior` permite
mostrar todas las etiquetas u ocultarlas. Por defecto ocupa todo el ancho y
incluye el safe area inferior. Se puede usar en `Scaffold.bottomNavigationBar`.

`floating: true` redondea el contenedor y deja el safe area al host exterior.
El host nativo coloca el contenido y la barra en capas, reserva espacio para la
última fila y observa scroll vertical sin consumir sus notificaciones:

```dart
MorphNavigationBarHost(
  bar: MorphNavigationBar.morph(
    floating: true,
    selectedIndex: selected,
    onDestinationSelected: select,
    destinations: destinations,
    glass: const MorphNavigationGlass(
      blurX: 8,
      blurY: 8,
      tintOpacity: 0.65,
      tint: Color(0xFF19191C),
      borderColor: Color(0x33FFFFFF),
      borderWidth: 1,
    ),
  ),
  onRefresh: reload,
  body: (context, controller, contentPadding) => ListView.builder(
    controller: controller,
    padding: contentPadding,
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (context, index) => buildItem(items[index]),
  ),
)
```

Aplica `contentPadding` al contenido desplazable, no a un Padding exterior: así
el fondo continúa bajo el cristal. Si usas un controller externo, su propietario
lo desecha; el host solo desecha el controller que crea internamente.

Al bajar, la barra flotante se oculta después de `scrollThreshold` px; al subir
o llegar al inicio reaparece. `showOnScrollEnd` permite mostrarla al detenerse.
`hideOnScroll: false` la mantiene visible. El estado docked permanece visible.
`showBackToTop` habilita la acción de retorno al inicio; `backToTopIcon` y
`backToTopLabel` personalizan su icono y texto localizado. El botón comparte el
centro horizontal de la barra, incluso con márgenes asimétricos.
Usa el controller del
builder para que la acción pueda desplazar la lista. El host se coloca en el
body del Scaffold, con restricciones finitas, no en bottomNavigationBar.

**El `MorphNavigationBarHost` sirve para cualquiera de los tres diseños:**
`MorphNavigationBar()` (MD3E estándar), `.expressive()` (píldora elástica) y
`.morph()` (línea superior). Basta con pasar el constructor deseado en `bar`;
`floating: true` habilita la superposición en cualquiera de ellos. La
configuración `glass` es opcional: sin ella la barra usa su superficie normal
pero conserva ocultamiento por scroll, retorno al inicio y refresh. No se
necesita un host distinto para cada diseño.

`onRefresh` integra el MorphRefreshIndicator existente, espera su Future y
mantiene la barra visible durante la recarga. **Si `onRefresh` se omite o es
`null`, el host no crea `MorphRefreshIndicator` ni muestra su animación**.
`refreshController` permite recarga programática cuando `onRefresh` existe.
En `Scaffold(extendBodyBehindAppBar: true)` con una `MorphAppBar.frosted`,
el host calcula automáticamente el `edgeOffset` para mostrar el spinner por
debajo de la AppBar. Para layouts personalizados puedes configurar
`refreshIndicatorEdgeOffset` explícitamente. Con una barra opaca normal,
sin AppBar o sin contenido detrás, se conserva el offset predeterminado (0).
Las animaciones de visibilidad usan Motor y `visibilitySpring`.

`maxBarWidth`, `floatingMargin` y `floatingRadius` controlan tamaño y posición.
Para cristal en una barra docked colocada en `Scaffold.bottomNavigationBar`,
usa `Scaffold.extendBody: true` si quieres que el contenido se vea detrás del
cristal. Sin contenido detrás, el filtro solo desenfoca el fondo del Scaffold.

El teclado oculta la presentación flotante. Con accessibleNavigation se mantiene
visible y con movimiento reducido la selección y la visibilidad llegan al
estado final sin viaje decorativo; volver arriba utiliza jumpTo.

El host se inspira en el comportamiento documentado de
[flutter_floating_bottom_bar](https://github.com/codenameakshay/flutter-floating-bottom-bar)
(scroll, barra superpuesta y retorno al inicio). Es una implementación propia;
no incorpora código de esa dependencia ni modifica AnimatedNavBar en WatchNext.

## Cristal

`glass: null` conserva el fondo normal. `MorphNavigationGlass` permite blur X/Y,
tinte, opacidad, gradiente, borde y blendMode. El filtro siempre está recortado
al contenedor. `opaqueInHighContrast` activa una superficie opaca cuando el
sistema pide alto contraste. El tinte y los colores de contenido deben elegirse
con contraste suficiente para el fondo de la aplicación.

En `MorphNavigationBarHost`, `blurDuringScroll: false` (predeterminado) suspende
solo el desenfoque mientras se desplaza el contenido y lo recupera al detenerse.
Tinte, gradiente, borde e interacción permanecen disponibles. Usa
`blurDuringScroll: true` para conservar el desenfoque continuo. Una barra sin
host conserva siempre el blur. Esta opción evita recalcular el fondo móvil;
un `RepaintBoundary` por sí solo no congela un backdrop que cambia.
El scroll de una página que contiene la navbar no controla su filtro: solo
cuentan el scroll interno del host y el estado de visibilidad. En Android/iOS,
`blurRevealProgress` (0.35 por defecto, rango 0–1) permite que el blur vuelva
durante la aparición sin esperar al final del resorte; Web mantiene una
política más conservadora. `webBackdropBlur: false` opta por un tinte sin blur
real únicamente en Web. En todos los casos el desenfoque se mantiene recortado
y separado de los iconos y los indicadores animados.

El host oculta la barra mediante traslación, sin una capa de opacidad sobre el
filtro. Cuando termina de ocultarse, no se pinta y sus tickers se suspenden;
su estado de selección se conserva. La demo usa blur real de sigma 5 en Web y 10 en nativo y estado local para
que una recarga no reconstruya la galería completa.

Para probar pull-to-refresh en la preview, vuelve al primer elemento y
arrastra hacia abajo con el botón izquierdo o con un gesto táctil; suelta
cuando el indicador esté completamente revelado. La rueda por sí sola no
dispara una recarga. La demo espera 650 ms y luego incrementa el contador de
sus filas. Su scroll acepta explícitamente ratón y usa física clamping.

## Indicador de páginas

```dart
MorphPageIndicator(
  count: 3,
  selectedIndex: page,
  activeWidth: 40,
  inactiveWidth: 16,
  height: 16,
  spacing: 6,
  onPageSelected: (index) {
    if (MorphMotion.reduceMotionOf(context)) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(
        index,
        duration: MorphMotion.medium2,
        curve: MorphMotion.standard,
      );
    }
  },
)
```

| Resultado | Configuración |
| --- | --- |
| Píldoras iguales | activeWidth e inactiveWidth iguales |
| Cápsula activa ancha | activeWidth mayor, inactiveHeight omitido |
| Puntos que crecen | effect expand e inactiveHeight menor que height |
| Slots de tamaño fijo | effect slide |
| Solo información | onPageSelected omitido |

El efecto predeterminado es expand. Los targets semánticos accesibles conservan 48x48 sin cambiar la distancia
visual entre puntos, que queda determinada por `spacing`. El estado seleccionado se anuncia siempre. `semanticLabelBuilder`
permite textos personalizados; por defecto se usa la localización de Material.
`activeColor`, `inactiveColor` y `spring` personalizan su aspecto.

`selectedIndex` lo controla la aplicación; el callback solicita el cambio. El
widget no asume propiedad de un PageController. Si el cambio navega un PageView,
aplica también la preferencia de movimiento reducido en ese PageView.

## Comprobación

```bash
flutter test test/navigation_morph_test.dart test/page_indicator_test.dart
flutter test --dart-define=MORPH_MOTION_AUDIT_PROFILE=reduced \
  test/navigation_morph_test.dart test/page_indicator_test.dart
flutter test --dart-define=MORPH_MOTION_AUDIT_PROFILE=reduce-only \
  test/navigation_morph_test.dart test/page_indicator_test.dart
```

La galería muestra navegación estándar, Expressive de píldora, Morph con línea
superior y barra flotante con cristal y recarga, además de cuatro configuraciones
del indicador de páginas.

Las regresiones de la barra flotante se comprueban con
`flutter test test/navigation_refinement_test.dart` y
`(cd preview && flutter test test/floating_navigation_sample_test.dart)`.

## GIFs de navegación (escenas actualizadas en 0.6.0)

- `navigation.gif`: variantes estándar MD3E compacta y wide (se conserva).
- `navigation_morph.gif`: píldora `.expressive` y línea `.morph`, junto a los
  efectos `expand` y `slide` de `MorphPageIndicator`.
- `navigation_rail_drawer.gif`: transiciones de selección independientes
  en `MorphNavigationRail.morph` y `MorphNavigationDrawer.morph`.

La actualización 0.6.1 no modifica la apariencia ni las escenas de captura;
no exige regenerar estos GIFs. Para volver a capturar la escena de 0.6.0,
desde la raíz:

```bash
bash tool/generate_component_gifs.sh --only navigation_morph
python3 tool/check_gif_branding.py
```

La generación requiere Flutter Web, Chromium/Playwright y FFmpeg.
`navigation_rail_drawer.gif` sigue siendo válido si su escena no cambió;
no se debe sustituir el GIF original `navigation.gif`.

## Indicadores compactos y AppBar con gradiente nativo

`MorphPageIndicator.spacing` ahora define la **distancia visual entre las
cápsulas**, incluso cuando `onPageSelected` está configurado. Los destinos
interactivos conservan nodos accesibles de 48×48 mediante una capa separada;
los gestos eligen el destino más cercano para evitar que se intercepten entre
sí en pistas compactas. `slide` y `expand` siguen siendo compatibles con RTL,
teclado y movimiento reducido.

Para una AppBar superior translúcida, usa `MorphAppBar.frosted` con el contenido
**detrás** de la barra (`extendBodyBehindAppBar: true`):

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: MorphAppBar.frosted(
    titleText: 'Explore',
    glass: const MorphAppBarGlass(
      topOpacity: 0.90,   // 90% arriba, 0% en el borde inferior
      maxBlurSigma: 16,   // blur máximo superior
      blurBands: 7,       // seis filtros progresivos
      tintCurvePower: 0.38,
      blurCurvePower: 1.8,
      blurClearExtent: 4, // 4 píxeles lógicos sin blur abajo
    ),
  ),
  body: ListView.builder(
    itemCount: 40,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
)
```

El tinte es continuo: parte en **0% en el borde inferior**, crece de manera
**lineal hasta la mitad** (≈26% de opacidad) y luego acelera mediante una
curva exponencial hasta **90% arriba** (`topOpacity`). La transición mantiene
una pendiente continua en el punto medio. El gradiente usa 65 muestras para
representar esa progresión con precisión. El blur
empieza en **0 sigma abajo** durante `blurClearExtent` píxeles lógicos (4 por
defecto). Justo encima aparecen franjas pequeñas de sigma casi nulo; las franjas
aumentan de altura y fuerza progresivamente hacia arriba. Se mantienen
`blurBands - 1` filtros, sin listeners adicionales ni animaciones sobre el blur.
Es una aproximación por franjas, no un shader de blur continuo por píxel.

Para ajustar las curvas sin cambiar los extremos: `tintCurvePower` controla
la aceleración de la mitad superior del tinte y `blurCurvePower > 1` reduce
el salto entre la zona nítida y la primera franja de blur. `blurClearExtent` deja libre
de blur el borde inferior (solo el blur: el tinte sigue llegando a cero). El
número de filtros es `blurBands - 1`; para dispositivos lentos se puede usar
`blurBands: 5`.
`topOpacity` define opacidad, no porcentaje de transparencia. Si prefieres
~75% de transparencia superior, usa `topOpacity: 0.25`; puede ser necesario
subir el blur para garantizar el contraste del título. Un mayor número de
`blurBands` mejora la progresión pero aumenta el coste de renderizado.

Esta variante está orientada a **Android/iOS** para evaluar rendimiento nativo.
En la preview móvil, abre **Gradient AppBar + page indicator** en Touch Lab:
el escenario combina la AppBar frosted, la navbar Morph flotante, los puntos
compactos y el pull-to-refresh con offset automático.
Desde `preview/`, usa `flutter run -t lib/main_mobile.dart` y elige tu
dispositivo conectado. El motor de Flutter Web también funciona, pero varios
`BackdropFilter` pueden ser caros cuando se desplaza el fondo.
