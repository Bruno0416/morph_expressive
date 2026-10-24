# Accesibilidad del movimiento

Morph conserva sus curvas, duraciones y resortes en movimiento normal. Cuando
el sistema solicita `disableAnimations` **o** `reduceMotion`, las transiciones
decorativas adoptan su estado final y las ondas automáticas dejan de moverse.
No hace falta configurar cada widget.

## Configuración de la aplicación

```dart
final theme = MorphThemeData.light().copyWith(reduceMotion: true);

MorphMaterialApp(data: theme, home: const MyHome());
```

`reduceMotion: false` es el valor predeterminado: sigue la preferencia del sistema.
No fuerza las animaciones si el usuario pidió reducirlas. `copyWith`, los temas
anidados y la derivación del tema oscuro conservan la propiedad.

Para limitar la opción a un widget o una sección:

```dart
MorphMotionScope(
  reduceMotion: true,
  child: MorphSegmentedToggle<String>(
    options: const [
      MorphSegmentedToggleOption(value: 'a', label: 'Uno'),
      MorphSegmentedToggleOption(value: 'b', label: 'Dos'),
    ],
    selected: selected,
    onChanged: onChanged,
  ),
);
```

Un scope hijo con `false` no anula uno padre con `true`. Los overlays que capturan
temas heredados conservan esta preferencia. Para overlays propios que no capturen
temas, usa `InheritedTheme.captureAll(context, child)` o aplica explícitamente el
scope al contenido del overlay.

Para componentes propios:

```dart
final reduced = MorphMotion.reduceMotionOf(context);
final duration = MorphMotion.durationOf(context, myDuration);
```

## Comportamiento

| Familia o mecanismo | Con movimiento reducido |
| --- | --- |
| Selección, botones, navegación, tabs y resortes Morph | Estado final sin transferencia espacial |
| Chip animado y segmented toggle | Sin estiramiento, bloom ni retardo de seguimiento |
| Textfields | Etiqueta, forma y efectos alcanzan el objetivo; también al cambiar la preferencia durante la transición |
| Progreso determinado | Valor real visible, onda decorativa estática |
| Progreso indeterminado y loading | Fotograma estático reconocible; se conserva su semántica de progreso |
| Sliders y range sliders | Onda estática; valor, teclado y arrastre siguen disponibles |
| Carrusel | Distribución reducida coherente y navegación programática sin viaje animado |
| Overlays, selección de listas y efectos implícitos | Transiciones reducidas, conservando interacción y foco |

Los controladores de resorte completan el Future y notifican su estado al alcanzar
el destino. No se usa `TickerMode(false)` para congelar widgets en estados
intermedios. Las duraciones funcionales —por ejemplo, la permanencia de un
snackbar— no se convierten en cero.

## Pruebas

```bash
flutter pub get
(cd preview && flutter pub get)
python3 tool/audit_reduced_motion.py --profiles full reduced reduce-only
```

Perfiles:

- `full`: ambas preferencias desactivadas.
- `reduced`: ambas activadas.
- `reduce-only`: solo `AccessibilityFeatures.reduceMotion` activado.

El informe queda en `.dart_tool/motion_audit/REPORT.md`, con resultados estructurados
y trazas. El comando devuelve error si una prueba falla. La suite ordinaria puede
ejecutarse con `flutter test` sin activar instrumentación.

Los contratos comparan píxeles, geometría, estados finales y cambios de preferencia.
Los tests de catálogo montan las 107 clases públicas de las 39 familias. Montar una
clase no cubre todas sus variantes e interacciones, y la ausencia de movimiento
en un muestreo pasivo no demuestra cumplimiento por sí sola.

La matriz se ejecuta como pruebas de widgets en Linux. La evaluación visual en
Firefox/Chromium y dispositivos físicos sigue siendo una comprobación adicional;
esta suite no certifica toda la accesibilidad del producto.
