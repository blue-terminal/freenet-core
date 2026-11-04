# Web 7.0 Core

**Infrastruttura decentralizzata completa — un click installa tutto.**

Fork di [freenet/freenet-core](https://github.com/freenet/freenet-core) con integrazione **Web 7.0**:
browser, FreenetTV (YouTube), FreenetGram (Instagram), FreenetPosts (Twitter) — tutto decentralizzato, nessuna censura.

---

## Installazione in un click

```bash
curl -sSL https://raw.githubusercontent.com/blue-terminal/web70-core/main/install.sh | bash
```

oppure, se hai già clonato il repo:

```bash
./install.sh
```

Lo script fa tutto automaticamente:
1. Installa Rust se non presente
2. Compila il nodo Freenet
3. Installa `fdev`
4. Avvia il nodo su `http://127.0.0.1:7509`
5. Pubblica le 4 app Web 7.0 sulla rete
6. Crea collegamento desktop e comando `web70`

---

## Dopo l'installazione

| App | URL |
|---|---|
| **Browser Freenet** | http://127.0.0.1:7509/v1/contract/web/browser-fn/ |
| **FreenetTV** (YouTube) | http://127.0.0.1:7509/v1/contract/web/fresnettv/ |
| **FreenetGram** (Instagram) | http://127.0.0.1:7509/v1/contract/web/frenetgram/ |
| **FreenetPosts** (Twitter) | http://127.0.0.1:7509/v1/contract/web/freenetposts/ |
| Homepage nodo | http://127.0.0.1:7509 |

**Avvio rapido** (dopo prima installazione):
```bash
web70
```

---

## Struttura

```
web70-core/
├── install.sh          ← INSTALLAZIONE ONE-CLICK
├── web70/              ← App Web 7.0 (MIT)
│   ├── index.html      ← Browser Freenet
│   ├── video.html      ← FreenetTV
│   ├── photos.html     ← FreenetGram
│   ├── posts.html      ← FreenetPosts
│   ├── fn-api.js       ← API Freenet reale
│   ├── pubblica.sh     ← Pubblica le app
│   └── LICENSE         ← MIT
├── crates/             ← freenet-core (AGPL-3.0)
│   ├── core/           ← Nodo Rust
│   └── fdev/           ← Strumento pubblicazione
└── LICENSE             ← AGPL-3.0 (freenet-core)
```

---

## Protocollo usato

| Endpoint | Descrizione |
|---|---|
| `GET /v1/version` | Versione nodo JSON |
| `GET /v1/contract/web/{key}/` | Serve webapp |
| `WS /v1/contract/command?encodingProtocol=native` | ContractRequest WebSocket |

---

## Licenza

- **web70/** — MIT License © 2026 blue-terminal
- **freenet-core** — GNU AGPL-3.0 © Freenet Project

---

## Repository collegati

- [blue-terminal/web70-core](https://github.com/blue-terminal/web70-core) ← questo repo
- [blue-terminal/web.7.0](https://github.com/blue-terminal/web.7.0) — solo le app
- [freenet/freenet-core](https://github.com/freenet/freenet-core) — repo originale upstream
