# Commits de la rama `feat/challenge`

> 19 commits sobre `main` (`7f6f56b`), del más antiguo al más reciente · Última actualización: 2026-11-16
> Documentos relacionados: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) (fases) · [ARCHITECTURE.md](ARCHITECTURE.md) · [README.md](README.md)

Cada commit corresponde a una fase del [plan de implementación](IMPLEMENTATION_PLAN.md), salvo el primero (documentación previa) y un `chore` de limpieza.

Hasta el commit 16, la app tenía un **modo mock** (`USE_MOCK=true`) que respondía con datos simulados. El commit 17 lo quitó: la app siempre consulta las APIs reales, y los datos simulados quedaron solo en las pruebas. Desde el commit 19, las URLs de las APIs tampoco están en el código: se leen de un `.env`. Los commits anteriores describen el estado de su momento.

## Resumen

| # | Commit | Fecha | Fase | Qué hizo |
|---|---|---|---|---|
| 1 | `3432abb` | 2026-11-13 | — | Documentos de arquitectura, plan e investigación de APIs |
| 2 | `53a4b1e` | 2026-11-13 | 0 | Proyecto Flutter, dependencias, lints, assets y l10n |
| 3 | `bbfbfd5` | 2026-11-13 | 1 | Configuración, red, caché, errores y tokens del design system |
| 4 | `8c7aad6` | 2026-11-13 | 2 | Entidades del dominio y caso de uso de cotización |
| 5 | `ddf24a1` | 2026-11-13 | 3 | Proveedor El Dorado (`/api/prices`) |
| 6 | `fc85066` | 2026-11-13 | 4 | Proveedor CriptoYa y *composition root* |
| 7 | `d820840` | 2026-11-13 | 5 | `ExchangeBloc` por proveedor y `HomeCubit` |
| 8 | `7eea937` | 2026-11-13 | 6 | Home con pestañas y calculadora fiel al diseño |
| 9 | `a007e78` | 2026-11-13 | 7 | Comparación de cotizaciones entre proveedores |
| 10 | `ca5b5e5` | 2026-11-13 | 8 | Mínimos, disponibilidad, carga, errores y accesibilidad |
| 11 | `32d09bc` | 2026-11-13 | 9 | README, CI y revisión final |
| 12 | `adc2654` | 2026-11-13 | 10 | API de órdenes `recommendations` (opcional) |
| 13 | `2958f30` | 2026-11-16 | 11 | Confirmación, ejecución simulada y comprobante |
| 14 | `ebad2ad` | 2026-11-16 | 12 | Selectores sin monedas no disponibles |
| 15 | `bab79de` | 2026-11-16 | — | Deja de versionar las diferencias de *goldens* fallidos |
| 16 | `c0a9e33` | 2026-11-16 | 12 | Calculadora en el mismo lugar en ambas pestañas |
| 17 | `33b572a` | 2026-11-16 | 12 | Retiro del modo mock de la app |
| 18 | `93654a8` | 2026-11-16 | 12 | QUIERO arranca en BOB |
| 19 | `17b7633` | 2026-11-16 | 12 | URLs de las APIs en `.env` |

## Detalle

### 1. `3432abb` docs: add architecture, implementation plan and API research

*3 archivos · +1212*

- `ARCHITECTURE.md`: organización por funcionalidad con capas `domain` / `data` / `presentation`, un repositorio por proveedor de tasas y datos simulados en el borde HTTP.
- `IMPLEMENTATION_PLAN.md`: el trabajo dividido en fases, cada una con su commit.
- `API_RESEARCH.md`: evaluación de las APIs públicas. El endpoint del enunciado responde 404, así que El Dorado usa `/api/prices` y CriptoYa se suma como segundo proveedor.

### 2. `53a4b1e` chore: scaffold flutter app

*82 archivos · +2465 −1*

- Proyecto Flutter (Android, iOS y web) en la raíz del repositorio.
- Dependencias: `flutter_bloc`, `bloc_concurrency`, `dio`, `get_it`, `equatable`, `decimal`, `intl` y `flutter_localizations`; en desarrollo, `very_good_analysis`, `bloc_test` y `mocktail`.
- Solo se empaquetan los íconos de monedas y la fuente Rubik; las imágenes del diseño quedan fuera.
- Textos en ARB (español), generados en `lib/l10n/gen`.
- El contador de ejemplo se reemplaza por una `App` vacía con una prueba mínima.

### 3. `bbfbfd5` feat(core): config, networking, errors and design system tokens

*22 archivos · +1321 −43*

- `AppConfig` lee las URLs de las APIs, la fuente de El Dorado y las opciones del modo mock desde `--dart-define`. Las URLs tenían valores por defecto en el código hasta el commit 19.
- `createDio`: un cliente HTTP por proveedor, con *timeouts* y log solo en debug.
- `TtlCache`: vencimiento por clave, una sola petición en curso compartida, sin cachear errores y con `forceRefresh`.
- Errores tipados: jerarquía `Failure` y `Result<T>` (`Ok` / `Err`) con clases `sealed`.
- `AmountFormatter`: formatea y lee montos `Decimal` sin pasar por `double`.
- Tokens del design system con la paleta de El Dorado: colores semánticos (`AppColors` como `ThemeExtension`), tipografía Rubik medida en el diseño, espaciado, radios, tamaños, sombras y movimiento.
- Pruebas de configuración, formateo, caché, `Result` y contraste WCAG AA de cada par texto/fondo. Se suma `DESIGN_SYSTEM.md`.

### 4. `8c7aad6` feat(exchange): domain entities and quote use case

*13 archivos · +566 −7*

- Entidades: `Currency`, `RateProvider`, `ExchangePair` (siempre una crypto y una fiat; dirección e intercambio), `ExchangeRate`, `ExchangeQuote` y `PairAvailability`.
- Interfaz `ExchangeRepository`, con una implementación por proveedor.
- `GetExchangeQuote` multiplica o divide por la tasa con 8 dígitos de precisión, rechaza tasas no positivas y aplica el mínimo del proveedor.
- El dominio es Dart puro, sin Flutter ni `dio`; las pruebas usan un repositorio falso programable.

### 5. `ddf24a1` feat(exchange): el dorado prices provider with http-level mock

*22 archivos · +1380 −8*

- `CurrencyCatalog` con las 8 monedas del diseño (nombre, símbolo e ícono) y los IDs de El Dorado.
- Capa de datos compartida: excepciones tipadas, `ExchangeRateModel`, la interfaz del *data source* y un repositorio base que traduce excepciones a `Failure`.
- `PricesResponse` lee `GET /api/prices` de forma tolerante (precio como texto o número, límites opcionales) y detecta los pares que no existen, como VES al comprar.
- `EldoradoPricesDataSource` elige `SELL` o `BUY` según la dirección, toma el mínimo de los límites y cachea la respuesta 60 s.
- Interceptor con datos simulados y escenarios de error (desde el commit 17, solo en las pruebas).
- Pruebas contra una respuesta real capturada y contra los datos simulados.

### 6. `fc85066` feat(exchange): criptoya provider with http-level mock

*15 archivos · +963 −8*

- `CriptoYaResponse` lee `GET /api/{coin}/{fiat}/{volumen}` y descarta las entradas inválidas.
- `CriptoYaRateDataSource` calcula la mediana entre los exchanges con ofertas, informa cuántos entraron y cachea 30 s por par.
- Interceptor con datos simulados, armados para que la comparación tenga un ganador distinto según la dirección, y sus escenarios: sin ofertas, 429, error del servidor, *timeout* y respuesta inválida.
- *Composition root* con `get_it`: un repositorio y un `GetExchangeQuote` por proveedor.
- Pruebas de contrato contra las APIs reales (`live`), que no corren por defecto.

### 7. `d820840` feat(exchange): exchange bloc per provider and home cubit

*14 archivos · +773 −24*

- `ExchangeBloc` no depende del proveedor: recibe el caso de uso y el repositorio de su pestaña. El par por defecto es USDT → VES, como en el diseño (desde el commit 18, USDT → BOB).
- Todas las cotizaciones pasan por un único handler `restartable` con *debounce* de 300 ms adentro, así nunca se muestra una respuesta vieja.
- Eventos: monto, selección de TENGO y QUIERO, intercambio, precarga desde otra pestaña, reintento y vuelta de la app al primer plano.
- Una cotización solo cuenta si corresponde al par y al monto actuales.
- `HomeCubit` guarda la pestaña activa.
- `CurrencyCatalog` pasa al dominio, para que la presentación no dependa de la capa de datos.

### 8. `7eea937` feat(home): tabs per rate provider and exchange calculator ui

*43 archivos · +2719 −52*

- Componentes del design system, construidos solo con tokens: fondo con el semicírculo, tarjeta, botón principal, enlace, pestañas, insignia, radio, *skeleton* y bottom sheet.
- Widgets de la calculadora:
  - el selector TENGO / QUIERO con el botón de intercambio;
  - el campo de monto, con hasta 2 decimales;
  - el resumen de la cotización;
  - los mensajes;
  - el selector de monedas;
  - la fuente.
- La home tiene un `ExchangeBloc` por proveedor y una pestaña por cada uno, generadas desde `RateProvider.values`.
- Todos los textos de la UI en el ARB.
- Pruebas de widgets y *goldens* a 402×874 pt (opcionales).

### 9. `a007e78` feat(quote-comparison): compare el dorado and criptoya quotes

*21 archivos · +1334 −32*

- Nueva funcionalidad `quote_comparison`, que solo depende del dominio de `exchange`.
- `CompareQuotes` consulta todos los proveedores en paralelo con sus mismas cachés, elige el que entrega más y calcula la diferencia. Un empate no tiene ganador, y si un proveedor falla, el otro se muestra igual.
- Bottom sheet con una tarjeta por proveedor, la insignia "Mejor opción", errores con reintento y una nota sobre las dos fuentes.
- El enlace "Comparar cotizaciones" va debajo de la tarjeta. "Usar …" lleva a esa pestaña con el mismo par y monto.

### 10. `ca5b5e5` feat: limits, availability, loading and error states

*14 archivos · +462 −87*

- Monto mínimo: aviso debajo del campo, que se marca en rojo, y el botón deshabilitado.
- Par no disponible o sin ofertas: un mensaje con "Elegir otra moneda" y "Ver en …".
- En la pestaña El Dorado, los selectores marcan las monedas sin cotización como "No disponible" (desde el commit 14 se ocultan).
- Las pestañas cambian con un fundido y conservan su estado; los precios se renuevan al volver a la app; tocar fuera del campo cierra el teclado.
- Banner "MOCK" en debug (retirado en el commit 17).
- Sin desbordes con texto al 130 % en una pantalla de 320 pt.

### 11. `32d09bc` docs: usage, architecture summary and screenshots

*21 archivos · +200 −38*

- README para quien revisa: qué hace la app, cómo ejecutarla y probarla, la arquitectura, las decisiones, las limitaciones y capturas del diseño junto a la app.
- GitHub Actions: formato, `flutter analyze` y `flutter test`.
- Revisión final contra la *Definition of Done*: dependencias entre funcionalidades y valores sueltos reemplazados por tokens.
- El plan suma notas de implementación con cada desvío y su motivo.

### 12. `adc2654` feat(exchange): el dorado orderbook recommendations source

*11 archivos · +672 −11*

- Fase 10, opcional y bloqueada: el endpoint `recommendations` del enunciado responde 404. Se implementó lo que no depende de tener una URL vigente.
- `RecommendationResponse` sigue la forma documentada: siempre HTTP 200, `data: {}` sin ofertas y el error en el cuerpo.
- `OrderbookRateDataSource` arma la consulta desde el par (IDs de moneda de El Dorado), cachea por monto y toma el tiempo estimado del *maker*.
- `ELDORADO_SOURCE=orderbook` cambia la fuente de la pestaña El Dorado; sin `API_URL`, vuelve a `/api/prices`.
- Datos de prueba con la forma documentada. Queda pendiente verificar con una URL real.

### 13. `2958f30` feat(checkout): confirm, process and receipt for a simulated exchange

*72 archivos · +3605 −370*

- El botón de la tarjeta pasa de "Cambiar" a "Simular" y abre una confirmación editable en tres filas: moneda que entregas, moneda que recibes (con "Invertir") y cantidad. Tiene "Confirmar" y "Cancelar".
- Nueva funcionalidad `checkout`: caso de uso `SubmitExchange` sobre una ejecución simulada, con IDs `TX-XXXX-XXXX`.
- Pantalla de proceso con animación y tres pasos; no se puede salir mientras corre, y un error ofrece reintentar.
- Pantalla de éxito con el comprobante: lo recibido y lo enviado, tasa, fuente, fecha, hora, estado e ID copiable.
- Tras un cambio, la calculadora de esa pestaña vuelve al inicio.
- Título "Calculadora" sobre la tarjeta, fondo distinto en la pestaña CriptoYa y lista FIAT en orden alfabético por país.
- El selector de monedas se ajusta a la lista, sin espacio vacío abajo.

### 14. `ebad2ad` feat(exchange): hide unavailable currencies in the pickers

*9 archivos · +122 −73*

- Los selectores ya no muestran las monedas que el proveedor no cotiza para la dirección actual (USDC en El Dorado, VES al comprar), en lugar de mostrarlas deshabilitadas.
- La moneda ya elegida se muestra siempre, aunque el par actual no esté disponible.
- Se quitan el estado deshabilitado de la fila y el texto "No disponible".

### 15. `bab79de` chore: stop tracking golden failure diffs

*5 archivos · +3*

- Cuando un *golden* falla, `flutter test` deja imágenes de diferencias en `test/goldens/failures/`. Algunas se habían versionado por error: se quitan y la carpeta se ignora.

### 16. `c0a9e33` fix(home): keep the calculator in the same place on both tabs

*16 archivos · +63 −10*

- La calculadora estaba centrada en vertical, así que su posición dependía del alto de la tarjeta. La de CriptoYa no tiene "Tiempo estimado" y quedaba más abajo, y un mensaje dentro de la tarjeta la movía.
- Ahora el título y la tarjeta quedan anclados arriba, a una distancia fija (`AppLayout.calculatorTopInset`). Lo que cambia de alto crece hacia abajo.
- Pruebas: misma posición en ambas pestañas, y un aviso de mínimo no mueve la tarjeta.

### 17. `33b572a` refactor: remove the mock mode from the app

*38 archivos · +378 −611*

- La app siempre consulta las APIs reales. Se quitan `USE_MOCK`, `MOCK_SCENARIO_ELDORADO`, `MOCK_SCENARIO_CRIPTOYA`, `MOCK_LATENCY_MS` y el banner "MOCK".
- Los interceptores con datos simulados pasan de `lib/` a `test/helpers/fake_apis` como APIs falsas, solo para las pruebas.
- `configureDependencies` acepta interceptores por proveedor. Las pruebas arman la app completa sobre las APIs falsas con `fakeApiDependencies()`.
- `ELDORADO_SOURCE=orderbook` exige `API_URL`; sin ella, vuelve a `/api/prices`.
- Se quita `mocktail`, que no se usaba.

### 18. `93654a8` feat(exchange): default QUIERO currency is BOB

*22 archivos · +47 −33*

- El par inicial pasa de USDT → VES (el del diseño) a USDT → BOB en ambas pestañas. Es también el par al que vuelve la calculadora después de un cambio.
- BOB no tiene ícono entre los assets del challenge, así que se muestra con sus iniciales, como ARS.
- Las pruebas usan los valores de BOB (5 USDT: 59.25 BOB en El Dorado y 59.84 BOB en CriptoYa). Las que prueban la cobertura de VES lo eligen primero.

### 19. `17b7633` feat(config): read the api urls from a .env file

*13 archivos · +200 −77*

- Ninguna URL de API queda en el código: los valores van en `.env`, que no se versiona, y llegan con `--dart-define-from-file=.env`.
- `.env.example` documenta las claves: `ELDORADO_API_URL` y `CRIPTOYA_API_URL` (obligatorias), `ELDORADO_SOURCE` y `API_URL` (opcionales).
- Sin las claves obligatorias, la app no arranca y `MissingConfigException` dice cuáles faltan y cómo pasar el `.env`.
- `.vscode/launch.json` pasa el `.env` al ejecutar desde VS Code.
- Las pruebas no necesitan el `.env`: usan URLs de mentira sobre las APIs falsas. Las pruebas `live` leen el `.env`.
