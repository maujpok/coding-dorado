# Design system

> Estado: tokens y componentes implementados · Última actualización: 2026-11-13
> Código: [`lib/core/design_system/`](lib/core/design_system/) · Documentos relacionados: [ARCHITECTURE.md](ARCHITECTURE.md) · [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)

Un design system mínimo para la calculadora: tokens, un tema de Material construido sobre ellos y un puñado de componentes reutilizables.

**Qué sale de dónde:**
- **Estructura, medidas y tipografía:** de los mocks (`assets/screen_1.jpg`, `sheet_1.jpg`, `sheet_2.jpg`).
- **Paleta:** de la marca de **El Dorado**, tomada de las variables CSS de [eldorado.io](https://eldorado.io/).

## Principios

1. **Los componentes piden roles, no colores.** Un widget usa `context.colors.fieldBorder`, nunca `Color(0xFF…)` ni `AppPalette`. Cambiar la paleta es tocar un solo archivo.
2. **El amarillo es relleno, no texto.** El amarillo de El Dorado (`#FFFF00`) contra la superficie (`#FCFCFC`) tiene un contraste de **1.05:1**. Se usa como fondo de acciones y elementos destacados, siempre con texto y bordes en tinta (`#121211`), igual que en el sitio de la marca.
3. **Contraste verificado.** Cada par texto/fondo cumple WCAG AA (4.5:1 para texto, 3:1 para bordes) y una prueba lo comprueba ([`app_colors_contrast_test.dart`](test/core/design_system/app_colors_contrast_test.dart)).
4. **Medidas del mock.** Tamaños de texto y controles medidos en los mocks (804×1748 px a @2x = 402×874 pt).

## Tokens

### Paleta primitiva (`AppPalette`)

| Token | Valor | Origen en eldorado.io |
|---|---|---|
| `yellow` | `#FFFF00` | `--amarillo-el-dorado` |
| `yellowDeep` | `#E5E517` | amarillo de estados activos |
| `ink` | `#121211` | color de texto más usado del sitio |
| `black` | `#000000` | bordes del sitio |
| `grey50` | `#FCFCFC` | fondos de tarjetas |
| `grey100` | `#F1F1F0` | fondos secundarios |
| `grey200` | `#E6E6E4` | `--fondo-gris` |
| `grey300` | `#DADAD7` | divisores |
| `grey500` | `#8E8E88` | derivado, para texto deshabilitado |
| `grey700` | `#5B5B55` | `--gris-bordes` |
| `green` / `blue` | `#5DFF85` / `#4F4FEB` | acentos del sitio, solo como fondo |
| `greenInk` / `greenTint` | `#0B6B2E` / `#E3FFE9` | derivados legibles para éxito |
| `redInk` / `redTint` | `#B3261E` / `#FDECEA` | derivados legibles para error |

### Colores semánticos (`AppColors`)

`AppColors` es un `ThemeExtension`, así que admite más temas (por ejemplo, uno oscuro) sin tocar los widgets. Se lee con `context.colors`.

| Rol | Valor | Uso |
|---|---|---|
| `background` | `grey200` | Fondo de pantalla |
| `backgroundDecoration` | `yellow` | Semicírculo del fondo |
| `surface` | `grey50` | Tarjeta, bottom sheets |
| `surfaceMuted` | `grey100` | Skeletons, botones deshabilitados |
| `primary` / `primaryPressed` | `yellow` / `yellowDeep` | Botón principal, botón de swap, insignias, pestaña activa |
| `onPrimary` | `ink` | Texto e íconos sobre `primary` |
| `textPrimary` | `ink` | Texto principal |
| `textSecondary` | `grey700` | Etiquetas, subtítulos, notas |
| `textDisabled` | `grey500` | Texto deshabilitado (exento de AA) |
| `outline` | `ink` | Bordes con peso: selector de monedas, botones, campo en foco |
| `outlineSubtle` | `grey300` | Divisores, borde de tarjetas |
| `handle` | `grey400` (`#BDBDB7`) | Handle de los bottom sheets |
| `fieldBorder` | `grey700` | Borde de campos en reposo |
| `inverseSurface` / `onInverseSurface` | `ink` / `grey50` | Selector de pestañas |
| `success` / `successContainer` | `greenInk` / `greenTint` | Diferencia a favor en la comparación |
| `error` / `errorContainer` | `redInk` / `redTint` | Errores, monto bajo el mínimo |
| `scrim` | negro al 25 % | Velo detrás de los sheets (igual que el mock) |

**Contrastes verificados** (WCAG 2.x):

| Par | Contraste | Requisito |
|---|---|---|
| `textPrimary` / `surface` | 18.3:1 | 4.5 |
| `textSecondary` / `surface` | 6.7:1 | 4.5 |
| `textSecondary` / `background` | 5.5:1 | 4.5 |
| `onPrimary` / `primary` | 17.5:1 | 4.5 |
| `primary` / `inverseSurface` (pestaña activa) | 17.5:1 | 4.5 |
| `error` / `errorContainer` | 5.7:1 | 4.5 |
| `success` / `successContainer` | 6.3:1 | 4.5 |
| `fieldBorder` / `surface` | 6.7:1 | 3 |

### Tipografía (`AppTypography`)

Fuente **Rubik** (OFL), empaquetada en `assets/fonts/` para no depender de la red. Los tamaños salen de la altura de mayúsculas medida en los mocks.

| Estilo | Tamaño / peso | Uso |
|---|---|---|
| `title` | 20 / 400 | Título de bottom sheets |
| `headline` | 18 / 500 | Monto destacado en la comparación |
| `body` | 14 / 400 | Etiquetas del resumen, valores, monto ingresado |
| `bodyStrong` | 14 / 500 | Nombres de proveedor, énfasis |
| `button` | 14 / 500 | Botones |
| `label` | 11 / 600 | Código de moneda en el selector, insignias |
| `caption` | 11 / 400 | Unidades, subtítulos, notas |
| `overline` | 9.5 / 400 | "TENGO", "QUIERO" sobre el borde |

### Espaciado, radios, tamaños, sombras y movimiento

| Grupo | Valores |
|---|---|
| `AppSpacing` | `xxs` 2 · `xs` 4 · `sm` 8 · `md` 12 · `lg` 16 · `xl` 20 · `xxl` 24 · `xxxl` 32 · `huge` 40 |
| `AppRadius` | `badge` 4 · `icon` 5 · `control` 10 (campos y botones) · `card` 17 · `sheet` 20 · `pill` |
| `AppSizes` | selector 33 · campo 38 · botón 41 · swap 41 · pestañas 40 · íconos 20/24 · radio 22 (anillo 2, punto 8) · fila de lista 62 · fila del resumen 28 · handle 62×4 · ancho máximo 400 (contenido) y 520 (sheets) · selector de monedas al 70 % de la pantalla |
| `AppLayout` | margen lateral 48 pt desde 380 pt de ancho (tarjeta de ~306 pt en el teléfono del mock), 16 pt en pantallas angostas |
| `AppShadows` | `card` (ambiente suave + borde inferior marcado, como el mock) · `raised` (botón de swap) |
| `AppMotion` | `fast` 150 ms · `normal` 250 ms · `slow` 400 ms · curva `easeOutCubic` |

## Tema

`AppTheme.light()` traduce los tokens a `ThemeData`. Así también los respetan los widgets de Material: `ColorScheme`, `TextTheme`, bottom sheets (fondo, radio, scrim, ancho máximo), snackbars (tinta con texto claro) y la selección de texto (cursor en tinta, selección en amarillo).

## Componentes

Viven en [`lib/core/design_system/components/`](lib/core/design_system/components/) y solo usan tokens. Se importan todos con `design_system.dart`.

| Componente | Qué es | Estados y accesibilidad |
|---|---|---|
| `DsBackground` | Fondo con el semicírculo del mock (centro en 1.945·ancho, 0.378·alto; radio 1.403·ancho, ajustado con error < 1 px) | — |
| `DsCard` | Superficie con radio `card`, borde `outlineSubtle` y sombra `card` | `elevated` (con o sin sombra), `highlighted` (borde en tinta) |
| `DsPrimaryButton` | Acción principal: amarillo, texto y borde en tinta | Deshabilitado (`onPressed: null`) en `surfaceMuted`; `isLoading` con indicador; `Semantics(button, enabled)` |
| `DsLink` | Enlace en tinta con subrayado, como los de eldorado.io | Deshabilitado en `textDisabled`; `Semantics(link)` |
| `DsPillTabs<T>` | Pestañas segmentadas: píldora en tinta y la activa en amarillo, con indicador animado | `Semantics(selected, button, inMutuallyExclusiveGroup)` por pestaña |
| `DsBadge` | Etiqueta amarilla con texto en tinta | Estilo de texto configurable (prefijo del monto, "Mejor opción") |
| `DsRadio` | Indicador de selección: anillo `fieldBorder`; seleccionado, anillo en tinta, relleno amarillo y punto | `enabled`; es visual: la fila entera es el control |
| `DsSkeleton` | Bloque que pulsa mientras carga | Excluido de la semántica |
| `showDsBottomSheet` / `DsSheetScaffold` | Sheet con handle, título centrado y contenido; alto fijo (`heightFactor`) o ajustado al contenido | Título como `header`; ancho máximo 520; acción opcional junto al título |

Los widgets propios de la calculadora (selector de par, campo de monto, filas del resumen, ícono de moneda) están en la feature `exchange` y se construyen con estos componentes y tokens.

## Validación visual

Los *goldens* de [`test/goldens/`](test/goldens/) renderizan la app a 402×874 pt @2x, con Rubik y los íconos reales y con datos del mock HTTP, para compararlos con los mocks. Dependen del sistema operativo, así que no corren por defecto:

```bash
flutter test --dart-define=GOLDENS=true --tags golden [--update-goldens]
```

## Cambios respecto al mock

| Elemento | Mock | Design system |
|---|---|---|
| Fondo | celeste `#E0F8FA` | gris de El Dorado `#E6E6E4` |
| Semicírculo, botones, swap | ámbar `#FFB200` | amarillo de El Dorado `#FFFF00` |
| Texto del botón "Cambiar" | blanco | tinta (blanco sobre amarillo no se lee) |
| Bordes del selector y del campo | ámbar | tinta y `--gris-bordes` (el amarillo no se ve sobre blanco) |
| Prefijo del monto ("USDT") | texto ámbar | código en tinta sobre amarillo |

La estructura, las medidas y la tipografía no cambian.
