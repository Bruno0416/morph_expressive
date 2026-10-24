# Navegación Morph e indicadores de onboarding

Estas opciones están incluidas en Morph Expressive 0.5.0. Los cambios se
incorporaron después de 0.4.1.
Los constructores existentes conservan su selección Material. Las nuevas
variantes son aditivas y no requieren nuevas dependencias.

## Selección que viaja entre destinos

Usa `MorphNavigationBar.morph`, `MorphNavigationRail.morph` y
`MorphNavigationDrawer.morph` con los mismos argumentos del constructor normal.
También puedes cambiar `motion: MorphNavigationMotion.morph` dinámicamente.

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

## Barra con indicador superior

```dart
MorphNavigationBar.expressive(
  selectedIndex: selected,
  onDestinationSelected: select,
  destinations: destinations,
  topIndicatorWidth: 40,
  topIndicatorHeight: 4,
)
```

Muestra una barrita superior deslizante, icono activo y etiqueta seleccionada.
Usa disposición compacta incluso en pantallas anchas. `iconSize` (32 por defecto
en expressive) y `labelStyle` permiten ajustar iconos y tipografía. `labelBehavior` permite
mostrar todas las etiquetas u ocultarlas. Por defecto ocupa todo el ancho y
incluye el safe area inferior. Se puede usar en `Scaffold.bottomNavigationBar`.

`floating: true` redondea el contenedor y deja el safe area al host exterior.
El host nativo coloca el contenido y la barra en capas, reserva espacio para la
última fila y observa scroll vertical sin consumir sus notificaciones:

```dart
MorphNavigationBarHost(
  bar: MorphNavigationBar.expressive(
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

`onRefresh` integra el MorphRefreshIndicator existente, espera su Future y
mantiene la barra visible durante la recarga. No añade una segunda dependencia
ni un segundo detector de pull. `refreshController` permite recarga programática.
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

El efecto predeterminado es expand. Los targets pulsables tienen un mínimo
48x48; esa superficie puede aumentar la separación visual respecto al ejemplo
informativo. El estado seleccionado se anuncia siempre. `semanticLabelBuilder`
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

La galería muestra navegación estándar y Morph, barra expressive docked, barra
flotante con cristal y recarga, y cuatro configuraciones del indicador de páginas.

Las regresiones de la barra flotante se comprueban con
`flutter test test/navigation_refinement_test.dart` y
`(cd preview && flutter test test/floating_navigation_sample_test.dart)`.

## GIFs de navegación para 0.5.0

- `navigation.gif`: variantes estándar MD3E compacta y wide (se conserva).
- `navigation_morph.gif`: barras `.morph` y `.expressive`, junto a los
  efectos `expand` y `slide` de `MorphPageIndicator`.
- `navigation_rail_drawer.gif`: transiciones de selección independientes
  en `MorphNavigationRail.morph` y `MorphNavigationDrawer.morph`.

Para generar solo los nuevos recursos desde la raíz:

```bash
bash tool/generate_component_gifs.sh --only navigation_morph --only navigation_rail_drawer
python3 tool/check_gif_branding.py
```

La generación requiere Flutter Web, Chromium/Playwright y FFmpeg.
