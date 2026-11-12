# Informe final de implementación — Parche R3

**Proyecto:** Morph Expressive (`morph_expressive`).
**Versión base:** raíz 0.7.0; preview 0.2.0+1, sin cambio de versión.
**Estado:** implementación parcial respecto de la totalidad de criterios R3-A–E;
funcionalidad ejecutable implementada, límites pendientes detallados abajo.
**Publicación:** no ejecutada. Sin commit, push, tag ni cambios de CI.

> **Corrección posterior:** bordes Canvas, grupos connected, inset del loader y
> la interacción de `MorphShapeButton` se corrigieron después; ver
> [R3_VISUAL_FIXES.md](R3_VISUAL_FIXES.md). Los límites de matching, Shader y
> retarget descritos abajo siguen vigentes salvo donde ese informe lo indique.

## Qué probar ahora

Laboratorio release: <http://127.0.0.1:8081/?lab=shapes>.
Servidor vivo sobre `preview/build/web`, bind `0.0.0.0:8081`.
Se lanzó con `python3 -m http.server 8081 --bind 0.0.0.0 --directory build/web`
desde `preview/`. Se requiere forwarding del puerto para acceso remoto.
También se inició el ejecutable Linux release; su log informa backend
Impeller OpenGLESSDF. No se verificó visualmente el Shader del laboratorio nativo
ni se midió rendimiento de GPU. La evidencia Shader/raster corresponde a tests
y Chromium Web, no a certificación del backend nativo.

## Cambios de código y estado por etapa

| Etapa | Implementado | Alcance pendiente de certificación |
| --- | --- | --- |
| A | 90/160 ms configurables, override/merge, reversión desde geometría visible, lifecycle primario, cancelación y regresión de grupos | Matriz exhaustiva de estados externos/foco, accesibilidad y cambios de perfil/reduced motion en todos los consumidores |
| B | Cúbicas propias, split exacto, bounds interiores, winding/seam, retarget acotado, 35 entradas, Canvas y nueve definiciones locales fijas | Matching semántico completo, topología de intermedios, retarget de transforms externos; optimización repaint-only |
| C | Shader real ellipse → ellipse, uniforms independientes, carga/cache, fallback diagnóstico y comparación raster | Inyección de fallo de carga/compilación y matriz de DPR/tamaños/rotaciones; no rounded rectangles ni catálogo general |
| D | Ambos loaders usan motor propio, reloj ticker, secuencia default/legacy, entrada shapes, cambios live, pausa/reduced motion y control manual | Envolvente sin recorte para todo custom polygon y continuidad completa de transforms al cambiar configuración |
| E | Botón público controlado, press/selected shapes, lifecycle compartido, tinta/clip/hit test, teclado, foco y rotación solo contenedor | Matriz completa touch/Semantics/haptics y superficie táctil mínima inscrita en formas cóncavas |
| F | Auditoría e inventario completados; plan de migración documentado | Retiro intencionalmente no ejecutado |

Áreas principales: `lib/foundations/shape/geometry/`, `morph_shape_view.dart`,
`shaders/morph_ellipse.frag`, lifecycle/motion/theme de buttons, LoadingIndicator,
`morph_shape_button.dart`, `preview/lib/shape_morph_lab.dart` y suites nuevas.

Compatibilidad: `MorphShapes` conserva sus tokens; `.polygon`, clippers y
containers legacy no cambian a contain. `RoundedPolygon`, `Morph` y demás
reexports siguen siendo los tipos originales. `material_new_shapes` se conserva.
Sin migración global de FAB/icon buttons. Haptics y reduced motion reutilizan
las políticas existentes, sin flags globales paralelos.

## Evidencia y pruebas

SDK aislado `/tmp/opencode/flutter`, Flutter 3.47.9 / Dart 3.13.7; SDK global no
modificado. Logs externos para no incluir cachés ni resultados de build en patch.

| Check | Resultado observado | Evidencia |
| --- | --- | --- |
| Tests focalizados R3 + grupo | PASS | `/tmp/opencode/r3-final-focused.log` |
| Root `flutter test` completo | 922 PASS / 3 FAIL | `/tmp/opencode/r3-final-root-test.log` |
| Fallos root en copia intacta | Los mismos tres fallos de text field/listas | `/tmp/opencode/r3-baseline-failures.log` |
| Preview completa | Fallo de menú vacío en `morph_gallery_interactions_test.dart` | `/tmp/opencode/r3-final-preview-test.log` |
| Fallo preview en copia intacta | Reproducido (`a menu cannot be empty`) | `/tmp/opencode/r3-baseline-preview.log` |
| Lab focalizado | 2 PASS: retarget real y 390 px/2× texto, claro/oscuro | `/tmp/opencode/r3-final-lab-test.log` |
| `flutter analyze --no-pub` | Tres infos preexistentes; sin diagnósticos en archivos R3 | `/tmp/opencode/r3-final-analyze.log` |
| `dart format --output=none --set-exit-if-changed ...` | Formato global no verde por archivos preexistentes; R3 formateado por separado | `/tmp/opencode/r3-format.log` |
| `bash tool/check.sh` | FAIL en import preexistente, antes de análisis/tests | `/tmp/opencode/r3-final-check.log` |
| `python3 tool/check_dependency_imports.py` | FAIL: `test/morph_minor_visual_fixes_test.dart:3`, falta show explícito | `/tmp/opencode/r3-imports.log` |
| Gate nomenclatura `--all` | PASS | `/tmp/opencode/r3-language.log` |
| `git diff --check` | PASS | `/tmp/opencode/r3-diff-check.log` |
| Web release | PASS | `/tmp/opencode/r3-final-web-build.log` |
| Linux release | PASS | `/tmp/opencode/r3-final-linux-build.log` |
| Chromium release | Retarget, pausa, Shader activo, fallback, down/release, loader, selección, tema y reduced motion | `/tmp/opencode/r3-final-browser.log` |
| Dependencias latest/lowest | No ejecutadas; no se cambiaron rangos de dependencias | — |
| CI / publicación | No ejecutadas / pendientes | — |

Los fallos root previos: etiqueta de text field esperada en y=300 y obtenida en
312.714; dos radios inferiores de listas esperados 4.5 y obtenidos cerca de 9.
No se modificaron esos tests para ocultarlos. Se corrigió una regresión propia
del observer de arena que retrasaba feedback del grupo; la suite focalizada y
la nueva suite completa ya no presentan ese fallo.

Prueba geométrica: puntos de referencia con error <1e-12, máscaras nativas a
128² con presupuesto 0.5% (toPath legacy redondea milésimas), máscaras antes/después
de retarget a 64² y secuencia de 250 retargets. Raster Shader: renderer efectivo
exigido antes de captura; alpha 0.5 a DPR 2 con media por canal <2/255.
El único error de consola Web observado fue `/favicon.ico` 404; no shaders/assets
del paquete fallidos. Capturas: `/tmp/opencode/r3-desktop.png`, `r3-mobile.png`.

## Entrega y aplicación

Parche: `/tmp/opencode/morph-r3.patch`. Base: copia fuente de entrada preservada
en `/tmp/opencode/morph-r3-base`, con los cambios previos del usuario, **no** HEAD
ni otro main remoto. El patch solo contiene diferencias posteriores respecto
de esa copia, incluidos archivos nuevos. Excluye builds, caches y CI preexistente.
Aplicación verificada en copia independiente, con comparación byte a byte de
archivos afectados; evidencia `/tmp/opencode/r3-patch-verification.log`.

En una copia sin estos cambios R3 de esa misma base:

```bash
git apply --check /tmp/opencode/morph-r3.patch
git apply /tmp/opencode/morph-r3.patch
git diff --check
```

No aplicar encima del checkout ya editado. Para detalles de límites y API:
[SHAPE_ENGINE.md](SHAPE_ENGINE.md). Auditoría F:
[SHAPE_DEPENDENCY_AUDIT.md](SHAPE_DEPENDENCY_AUDIT.md).

## Checklist manual en la máquina del usuario

1. Comparar 90/160 con 165/380; pulsar/cancelar dentro del scroll y comprobar contador.
2. Arrastrar progreso, reproducir A→B y pulsar Retarget C/Rapid targets.
3. Comparar elipse Canvas/Shader; pedir Shader en catálogo y comprobar fallback.
4. Cambiar secuencia/intervalo del loader; probar modo manual y reduced motion.
5. Seleccionar Favorite con ratón/teclado; programar cambio o disable en 900 ms
   y mantener press. Activar rotación y observar que el icono no rota.
6. Revisar recortes, contraste y tacto a tamaños extremos, 2× texto y GPU nativa;
   no inferir rendimiento a partir de debug o de la comparación Web.

Parche R3: implementación parcial. Validaciones ejecutadas con los resultados
anteriores; publicación pendiente. La documentación es final para el alcance
implementado, no una denominación de publicación provisional.
