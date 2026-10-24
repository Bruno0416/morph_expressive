# Reduced motion: pruebas y auditoría

Esta batería examina las **39 familias** de componentes de Morph Expressive.
Añade instrumentación optativa y pruebas; no modifica las animaciones de `lib/`,
las dependencias ni la versión del paquete. La preview recibe un filtro opcional
de familias para aislar las pruebas; su valor por defecto conserva la galería
completa. El carrusel se ejecuta en un isolate de pruebas separado para evitar
que una aserción de su árbol de render contamine las demás familias.

## Ejecutar

Desde la raíz del repositorio, con Flutter 3.47.7:

```bash
flutter pub get
(cd preview && flutter pub get)
python3 tool/audit_reduced_motion.py
```

El informe queda en `.dart_tool/motion_audit/REPORT.md`; `summary.json` conserva
los resultados por familia y los archivos `*.jsonl` la salida original.
El comando termina con código **1** si hay pruebas fallidas o familias sin
montar. No convierte defectos conocidos en pruebas aprobadas ni los omite.

Para ejecutar una parte:

```bash
python3 tool/audit_reduced_motion.py --scope contracts --profiles full reduced
python3 tool/audit_reduced_motion.py --scope catalog --profiles reduced
python3 tool/audit_reduced_motion.py --profiles reduce-only
```

`--flutter /ruta/absoluta/flutter` permite usar un SDK que no esté en `PATH`.
`--output /ruta/informe` cambia el directorio de resultados.

## Preferencias independientes

| Perfil | `disableAnimations` | `reduceMotion` de plataforma |
|---|---|---|
| `full` | false | false |
| `reduced` | true | true |
| `reduce-only` (optativo) | false | true |

Se simula la plataforma mediante `FakeAccessibilityFeatures`, para que el valor
llegue tanto al framework y sus `AnimationController` como a `MediaQuery`.
Sobrescribir solamente un `MediaQuery` local no reproduce todo ese recorrido.
La prueba del entorno verifica esa propagación antes de interpretar resultados.

En Flutter 3.47.7, `reduceMotion` se observa en las características de plataforma;
ese SDK todavía no expone un getter `MediaQueryData.reduceMotion`. No se asume
que ambas preferencias sean intercambiables. `accessibleNavigation` se deja en
false: la navegación accesible es otra preferencia, no un sinónimo de reduced motion.

## Qué se comprueba

1. **Suite funcional completa** de biblioteca y preview bajo cada perfil.
   Conserva las interacciones y verificaciones existentes de los widgets.
2. **Contratos de movimiento**: estados inicial, intermedio y final de controles
   seleccionables; geometría y pintura visible; etiqueta de textfields al entrar
   y salir del foco. Los snapshots comparan el mismo proceso/renderizador;
   no dependen de imágenes golden de otra máquina.
3. **Catálogo completo**: monta las 39 familias, cambia las preferencias mientras
   están montadas, comprueba la propagación y las desmonta verificando que no
   queden callbacks de ticker. Usa pumps acotados para no colgarse con loaders.
4. **Muestreo pasivo** de animaciones observables en los frames que esas pruebas
   solicitan. Registra componente, familia, preferencia efectiva, cambios de
   valor y tiempo activo. No crea frames ni desactiva `TickerMode`.

## Cómo interpretar un fallo

Los contratos proponen que las transiciones decorativas finitas alcancen su
estado final dentro de **112 ms** con movimiento reducido. Ese margen permite
feedback breve; no pretende definir una regla universal de accesibilidad.
Los textfields verifican su comportamiento existente de salto inmediato.

Una prueba funcional antigua puede fallar porque esperaba una animación normal,
por ejemplo un bloom circular a mitad del recorrido. Eso requiere adaptar la
expectativa de ese test al perfil y **no demuestra por sí solo un defecto** del
widget. Los contratos dedicados y las trazas deben leerse por separado.

El informe marca animaciones observadas durante más de 80 ms para revisión.
Esa señal **no es un fallo automático**: un desplazamiento controlado por el
usuario o un indicador indeterminado de actividad pueden necesitar continuidad.
Las ondas ornamentales y los movimientos espaciales se revisan individualmente.

## Límites explícitos

- Montar una familia no equivale a verificar cada combinación de parámetros.
- La suite funcional aporta las interacciones; el test de catálogo no inventa
  una interacción representativa única para todos los widgets.
- La ausencia de movimiento observado **no equivale a cumplimiento**. Algunos
  controladores privados, `Listenable.merge`, timers y transiciones que empiezan
  y terminan entre dos pumps pueden escapar al muestreo.
- Los componentes sin animación propia también se montan y desmontan; pueden
  contener hijos que sí animan.
- Son pruebas de widgets en VM. La validación visual en Firefox/Chrome, CanvasKit/
  Skwasm, GPU y dispositivos nativos sigue siendo una comprobación diferente.

Los archivos `test/audits/*.dart` y `preview/test/audits/*.dart` se invocan
explícitamente por el runner. Así la auditoría puede mostrar defectos actuales
sin introducir expectativas falsas o romper silenciosamente el comando normal
`flutter test`. La instrumentación queda desactivada si no se proporciona
`MORPH_MOTION_AUDIT_PROFILE`.
