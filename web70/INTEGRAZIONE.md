# Web 7.0 — Integrazione con freenet-core

Questo repository è un fork di [freenet/freenet-core](https://github.com/freenet/freenet-core)
con l'aggiunta del progetto **Web 7.0** nella cartella `web70/`.

## Struttura web70/

```
web70/
├── index.html      ← Browser Freenet (iframe sul nodo locale)
├── video.html      ← FreenetTV (YouTube decentralizzato)
├── photos.html     ← FreenetGram (Instagram decentralizzato)
├── posts.html      ← FreenetPosts (Twitter decentralizzato)
├── fn-api.js       ← API Freenet reale (WebSocket + /v1/version)
├── fn-theme.css    ← CSS comuni
├── browser/        ← App browser pubblicabile su Freenet
├── video/          ← App FreenetTV pubblicabile su Freenet
├── shared/         ← Librerie condivise
└── pubblica.sh     ← Pubblica tutto con fdev website publish
```

## Come pubblicare su Freenet

Richiede `fdev` (da questo stesso repo):

```bash
cargo install --path crates/fdev
cd web70
./pubblica.sh
```

## API usata

Basata sul protocollo reale di `freenet-core`:

| Endpoint | Descrizione |
|---|---|
| `GET /v1/version` | Versione nodo |
| `GET /v1/contract/web/{key}/` | Serve webapp |
| `WS /v1/contract/command?encodingProtocol=native` | ContractRequest |

Shell postMessage: `{__freenet_shell__: true, type:'navigate', href:'...'}` — da `crates/core/src/server/path_handlers/assets/navigation_interceptor.js`

## Licenza

- `freenet-core`: AGPL-3.0 (vedere [LICENSE](../LICENSE))
- `web70/`: MIT
