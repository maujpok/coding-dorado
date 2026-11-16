# Investigación de APIs: alternativas temporales

> Verificado el 2026-11-13, entre las 18:40 y las 19:05 UTC · Documentos relacionados: [ARCHITECTURE.md](ARCHITECTURE.md) · [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
>
> Etiquetas: **[curl]** llamado directamente · **[docs]** documentación oficial · **[src]** leído en código o documentación pública de terceros.

## Resumen

1. **El endpoint oficial no está caído entero: se eliminó la ruta.**
   - `…/stage/currencies` responde `200` hoy, con `generatedAt` del 2026-11-13 [curl].
   - Lo que no existe es la ruta `/orderbook/public/recommendations`: API Gateway devuelve `MissingAuthenticationTokenException`, que es el error que da ante una ruta o método inexistente.
   - Según un fork, la ruta seguía funcionando el 2026-04-16 [src].
2. **La forma real del response está documentada públicamente** por forks del template `eldoradoio/coding-interview-frontend`. El DTO y la API falsa de las pruebas pueden seguirla desde ya (§2).
3. **Aunque la ruta volviera, USDT→VES (el par por defecto del diseño) probablemente no traería ofertas.**
   - En el catálogo de El Dorado, VES figura con `p2pDisabled: true` y `apiDisabled: true` [curl].
   - USDC es `TATUM-MATIC-USDC`, también con `p2pDisabled: true` [curl].
4. **Reemplazo temporal recomendado:** el API público oficial de El Dorado, `GET https://api.eldorado.io/api/prices`, para USDT; y **CriptoYa** como respaldo para USDC y para VES en la dirección fiat→crypto (§6).

## 1. Estado del API oficial

| Llamada | Resultado |
|---|---|
| `GET …/stage/orderbook/public/recommendations?type=0&…` | `404` · `MissingAuthenticationTokenException` [curl] |
| `GET …/prod/orderbook/public/recommendations?…` | `403` [curl] |
| `GET …/stage/currencies` | `200` · catálogo vigente [curl] |

Ningún fork usa una URL más nueva de `recommendations`; todos usan la misma de `/stage` [src]. **Hay que pedirle al equipo la URL vigente** (ver Fase 8 del plan).

## 2. Forma del response de `recommendations`

Fuentes:
- [API.md de un fork](https://github.com/Miyo-Excellent/el-dorado-coding-interview-frontend/blob/main/API.md): 44 llamadas reales hechas el 2026-04-16 [src].
- [Respuesta capturada en enero de 2025](https://github.com/mbam132/exchange_app/blob/dee6e71446e73b534140b4d835e81bfc7201dcfb/test/mock_responses.dart) [src].

```jsonc
// HTTP SIEMPRE 200. El resultado se interpreta por el body.
// Sin liquidez o monto fuera de límites → { "data": {} }
// Parámetros inválidos → { "error": { "code": "INVALID_REQUEST", "message": "..." }, "errors": [ ... ] }
{
  "data": {
    "byPrice":      { /* Offer */ },  // mejor tasa para el usuario ← la que usamos
    "byReputation": { /* Offer */ },  // maker con mejor puntaje
    "bySpeed":      { /* Offer */ }   // estaba en enero de 2025; no aparece en abril de 2026
  }
}

// Offer (resumido)
{
  "offerId": "uuid",
  "offerType": 0,                                  // igual al `type` del request
  "cryptoCurrencyId": "TATUM-TRON-USDT",
  "fiatCurrencyId": "COP",
  "fiatToCryptoExchangeRate": "3607.999",          // STRING: fiat por 1 crypto
  "limits": {
    "crypto": { "minLimit": "1.51",     "maxLimit": "495.05" },
    "fiat":   { "minLimit": "7215.998", "maxLimit": "1803999.5" }
  },
  "offerMakerStats": {
    "releaseTime": 1.03,                           // minutos promedio para liberar fondos
    "payTime": 2.65,
    "responseTime": 2.06,
    "marketMakerOrderTime": 4.49                   // minutos promedio para completar una orden
  },
  "paymentMethods": ["app_nequi_co", "bank_bancolombia"],
  "user_status": "ONLINE"
}
```

**Qué usa la app:**

| Campo | Uso |
|---|---|
| `data.byPrice.fiatToCryptoExchangeRate` | Tasa. Llega como **string**; el parseo acepta string o número. |
| `data.byPrice.offerMakerStats.marketMakerOrderTime` | "Tiempo estimado", redondeado hacia arriba a minutos. |
| `data == {}` | "No hay ofertas" (sin liquidez o monto fuera de límites). |
| `error.code` | Error de validación (`INVALID_REQUEST`). |

## 3. IDs de monedas (`GET …/stage/currencies`)

| Moneda | ID | `p2pDisabled` | `apiDisabled` |
|---|---|---|---|
| USDT | `TATUM-TRON-USDT` | false | false |
| USDC | `TATUM-MATIC-USDC` | **true** | false |
| VES | `VES` | **true** | **true** |
| COP | `COP` | false | false |
| ARS | `ARS` | false | false |
| PEN | `PEN` | false | false |
| BRL | `BRL` | false | false |
| BOB | `BOB` | false | false |

Todo verificado con [curl]. En este catálogo `type` 0 = fiat y 1 = crypto.

## 4. Candidatas evaluadas

"Vía USD" significa que la fuente solo publica fiat por USD y habría que usarla como sustituto de USDT/USDC.

| API | ¿Key? | VES | COP | ARS | PEN | BRL | BOB | USDT | USDC | Tipo de tasa | CORS | Estabilidad |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **El Dorado `/api/prices`** | No | solo SELL | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ | Libro P2P propio, BUY/SELL | `*` | Oficial, con OpenAPI |
| **CriptoYa** | No | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | P2P y exchanges, bid/ask | `*` | Documentada, de un tercero |
| Yadio | No | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | vía USD | vía USD | Mercado / paralelo | `*` | Pública, poca documentación |
| CoinGecko | No (*Demo key* opcional) | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Promedio global (ARS ≈ oficial) | `*` | Oficial |
| Coinbase v2 | No | oficial | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Tipo de cambio de referencia | `*` | Oficial |
| open.er-api.com | No | oficial | ✅ | oficial | ✅ | ✅ | ✅ | vía USD | vía USD | Oficial, se actualiza a diario | `*` | Free tier oficial |
| Binance P2P (`bapi`) | No | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | Anuncios P2P | ❌ (no sirve en web) | **No oficial** |
| DolarApi | No | ✅ | ❌ | ✅ | ❌ | ❌ | ✅ | proxy | – | "Dólar" por país | `*` | Open source |

Cobertura y CORS verificados con [curl] (CORS con `Origin: http://localhost:8080`). Límites conocidos:
- CriptoYa: 120 peticiones (`x-ratelimit-limit`) [curl].
- Yadio: 1000 por minuto [curl].
- open.er-api: bloquea 20 minutos si se abusa y exige atribución [docs].
- El Dorado: no publica límites; responde desde la caché de CloudFront [curl].

### Referencia: USDT en fiat a las 18:44 UTC [curl]

| Fiat | El Dorado SELL / BUY | CriptoYa bid / ask (mediana) | Yadio (USD) | Coinbase | open.er-api (USD) |
|---|---|---|---|---|---|
| VES | 1014.83 / – | 1050 / 1065.8 | 1045.73 | 900.85 | 911.62 |
| COP | 3208 / 3347.5 | 3283.3 / 3329.5 | 3313.18 | 3315.51 | 3288.65 |
| ARS | 1649.56 / 1682.5 | 1655.9 / 1676 | 1666.33 | 1542.34 | 1544.43 |
| PEN | 3.33 / 3.4935 | 3.417 / 3.457 | 3.41 | 3.40 | 3.41 |
| BRL | 4.94 / 5.997 | 5.633 / 5.687 | 5.656 | 5.641 | 5.610 |
| BOB | 11.79 / 12 | 11.84 / 11.94 | 11.87 | 11.66 | 11.82 |

Las fuentes de tipo de cambio oficial (Coinbase, open.er-api, CoinGecko) **subvaloran VES en ~13 % y ARS en ~7 %** frente a la tasa P2P/USDT. Por eso no sirven para este caso.

## 5. Detalle de las dos opciones elegidas

### El Dorado: `GET https://api.eldorado.io/api/prices`

Sin parámetros ni autenticación. Documentación: [llms.txt](https://api.eldorado.io/llms.txt) y [OpenAPI](https://api.eldorado.io/api/openapi) [docs].

```json
{
  "SELL": { "VES": { "limits": { "in": { "min": "5" }, "out": { "min": "5074.146" } }, "price": "1014.8292" },
            "BRL": { "limits": { "in": { "min": "5" }, "out": { "min": "24.7" } },     "price": "4.94" } },
  "BUY":  { "BRL": { "limits": { "in": { "min": "29.985" }, "out": { "min": "5" } },  "price": "5.997" } }
}
```

- `price` es un string con el fiat por 1 USDT; los precios son **indicativos, no vinculantes** [docs].
- `SELL` es el usuario vendiendo USDT (`in` en USDT, `out` en fiat). `BUY` es el usuario comprando USDT (`in` en fiat, `out` en USDT) [docs].
- Fiats en SELL: ARS, BOB, BRL, CLP, COP, DOP, ECU, MXN, PEN, PYG, USD y VES. En BUY no están VES ni DOP [curl].
- Una sola llamada trae todas las fiat, así que se puede cachear 30–60 s.
- Los endpoints de cotización (`POST /quote/sell` y `/quote/buy`) exigen `X-Client-ID` y `X-Referral-ID`; no se usan.

### CriptoYa: `GET https://criptoya.com/api/{usdt|usdc}/{fiat}/{volumen}`

Ejemplo: `https://criptoya.com/api/usdc/bob/1`. [Documentación](https://docs.criptoya.com/).

```json
{ "vitawallet": { "ask": 11.9697, "totalAsk": 11.9697, "bid": 11.7198, "totalBid": 11.7198, "time": 1794595909 },
  "bybitp2p":   { "ask": 0,       "totalAsk": 0,       "bid": 11.85,   "totalBid": 11.85,   "time": 1794595907 } }
```

- Devuelve un objeto por exchange. `ask` es el precio para comprar crypto y `bid` el precio para venderla; los `total*` incluyen comisiones [docs].
- `ask: 0` significa sin ofertas, lo cual es frecuente en USDC y BOB [curl].
- Los extremos del libro P2P pueden aparecer invertidos (bid > ask), así que conviene usar la **mediana** entre exchanges con valor mayor que 0.
- `volumen` está en unidades de la crypto.
- La respuesta se cachea 30 s (`cache-control: max-age=30`).

## 6. Recomendación

**Principal: El Dorado `/api/prices` para USDT.** Es la misma empresa, es oficial, no requiere key, tiene CORS abierto y su precio es justamente "fiat por 1 USDT" de su libro P2P, el mismo concepto que `fiatToCryptoExchangeRate`.

**Respaldo: CriptoYa.** Es la única fuente sin key que cubre los 12 pares con precios P2P bid/ask, y se usa para lo que El Dorado no cubre: **USDC** (todas las fiat) y **VES en fiat→crypto**.

| Dirección | El Dorado | CriptoYa | Cálculo |
|---|---|---|---|
| crypto→fiat (`type=0`) | `SELL[fiat].price` | mediana de `totalBid > 0` | `fiat = crypto × rate` |
| fiat→crypto (`type=1`) | `BUY[fiat].price` | mediana de `totalAsk > 0` | `crypto = fiat ÷ rate` |

**Limitaciones del reemplazo:**
- Ninguno informa el "tiempo estimado". Se muestra un valor fijo marcado como estimado.
- Los precios son indicativos; el API original devolvía una oferta concreta.
- El spread de El Dorado puede ser grande (BRL: 4.94 contra ~5.65 de mercado), porque es un libro propio y poco profundo. Es lo mismo que habría devuelto el API original.

**Tercera opción, si hiciera falta:** Yadio `GET https://api.yadio.io/exrates/USD`. Usa la misma tasa en ambas direcciones (sin spread), toma USD como sustituto de USDT/USDC, y su valor para VES y ARS se parece al P2P.

## 7. Impacto en la arquitectura y el plan

- **Forma del response:** el DTO y `FakeOrderbookApi` (la API falsa de las pruebas) siguen la forma documentada en §2. Siempre HTTP 200, `data: {}` y `error` en el body ([ARCHITECTURE.md §6](ARCHITECTURE.md#6-datos)).
- **USDC:** el catálogo usa `TATUM-MATIC-USDC`.
- **Proveedores:** la app usa ambos, cada uno en su propia pestaña (El Dorado `/api/prices` y CriptoYa), y los compara lado a lado ([IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md#enfoque), Fases 3, 4 y 7).
- **Riesgo nuevo:** con el API oficial, USDT→VES y todo lo de USDC probablemente devolverían `data: {}`. La UI tiene que tratar bien el estado "sin ofertas".

## Fuentes

- [Template oficial: eldoradoio/coding-interview-frontend](https://github.com/eldoradoio/coding-interview-frontend)
- [Fork con la documentación del API (2026-04-16)](https://github.com/Miyo-Excellent/el-dorado-coding-interview-frontend/blob/main/API.md)
- [Respuesta real capturada (enero de 2025)](https://github.com/mbam132/exchange_app/blob/dee6e71446e73b534140b4d835e81bfc7201dcfb/test/mock_responses.dart)
- [El Dorado: llms.txt](https://api.eldorado.io/llms.txt) · [OpenAPI](https://api.eldorado.io/api/openapi)
- [CriptoYa: documentación](https://docs.criptoya.com/)
- [Yadio](https://api.yadio.io/exrates/USD) · [CoinGecko: límites](https://docs.coingecko.com/docs/common-errors-rate-limit) · [Coinbase: exchange rates](https://docs.cdp.coinbase.com/coinbase-app/track-apis/exchange-rates) · [ExchangeRate-API: términos](https://www.exchangerate-api.com/terms)
