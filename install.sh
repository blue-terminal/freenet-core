#!/bin/bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║          Web 7.0 — Installazione completa con un click          ║
# ║   github.com/blue-terminal/freenet-core  (fork di freenet-core) ║
# ╚══════════════════════════════════════════════════════════════════╝
# Installa: Rust, freenet-core, fdev, avvia il nodo, pubblica le app
#
# USO:
#   curl -sSL https://raw.githubusercontent.com/blue-terminal/freenet-core/main/install.sh | bash
#   oppure:
#   ./install.sh

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[Web 7.0]${NC} $*"; }
ok()      { echo -e "${GREEN}[  OK  ]${NC} $*"; }
warn()    { echo -e "${YELLOW}[ WARN ]${NC} $*"; }
error()   { echo -e "${RED}[ERROR ]${NC} $*" >&2; exit 1; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║        Web 7.0 — Installazione          ║${NC}"
echo -e "${BOLD}║  Browser · FreenetTV · FreenetGram       ║${NC}"
echo -e "${BOLD}║  FreenetPosts · River · Mail · Atlas     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB70_DIR="$REPO_DIR/web70"

# ── 1. Controlla OS ───────────────────────────────────────────────
info "Rilevamento sistema operativo…"
OS="$(uname -s)"
ARCH="$(uname -m)"
info "Sistema: $OS / $ARCH"

# ── 2. Installa Rust se mancante ──────────────────────────────────
if ! command -v cargo &>/dev/null; then
  info "Rust non trovato — installazione in corso…"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env" 2>/dev/null || export PATH="$HOME/.cargo/bin:$PATH"
  ok "Rust installato: $(rustc --version)"
else
  ok "Rust già presente: $(rustc --version)"
  source "$HOME/.cargo/env" 2>/dev/null || export PATH="$HOME/.cargo/bin:$PATH"
fi

# ── 3. Dipendenze di sistema ──────────────────────────────────────
info "Verifica dipendenze di sistema…"
if [[ "$OS" == "Linux" ]]; then
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y --no-install-recommends \
      build-essential pkg-config libssl-dev clang cmake 2>/dev/null || warn "apt-get: alcune dipendenze potrebbero mancare"
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm base-devel openssl clang cmake 2>/dev/null || warn "pacman: alcune dipendenze potrebbero mancare"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y gcc openssl-devel clang cmake 2>/dev/null || warn "dnf: alcune dipendenze potrebbero mancare"
  fi
elif [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    warn "Homebrew non trovato — installa manualmente: https://brew.sh"
  else
    brew install openssl cmake 2>/dev/null || true
  fi
fi

# ── 4. Compila freenet-core ───────────────────────────────────────
info "Compilazione freenet-core (può richiedere 5–15 minuti la prima volta)…"
cd "$REPO_DIR"
cargo build --release --bin freenet 2>&1 | tail -5
ok "freenet compilato: $REPO_DIR/target/release/freenet"

# ── 5. Compila e installa fdev ────────────────────────────────────
info "Compilazione fdev (strumento di pubblicazione app)…"
cargo build --release --bin fdev 2>&1 | tail -3
# copia in PATH locale
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/target/release/fdev" "$HOME/.local/bin/fdev"
export PATH="$HOME/.local/bin:$PATH"
ok "fdev installato: $(fdev --version 2>/dev/null || echo 'ok')"

# ── 6. Avvia nodo Freenet in background ───────────────────────────
info "Avvio nodo Freenet su http://127.0.0.1:7509 …"
mkdir -p "$HOME/.freenet"
"$REPO_DIR/target/release/freenet" network 2>"$HOME/.freenet/freenet.log" &
FREENET_PID=$!
echo "$FREENET_PID" > "$HOME/.freenet/freenet.pid"

# attendi che il nodo sia pronto
info "Attendo che il nodo sia pronto…"
for i in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:7509/v1/version" &>/dev/null; then
    ok "Nodo online: $(curl -sf http://127.0.0.1:7509/v1/version)"
    break
  fi
  sleep 2
  if [[ $i -eq 30 ]]; then
    warn "Nodo non risponde ancora — controlla $HOME/.freenet/freenet.log"
  fi
done

# ── 7. Pubblica app Web 7.0 su Freenet ───────────────────────────
info "Pubblicazione app Web 7.0 sulla rete Freenet…"
cd "$WEB70_DIR"
bash pubblica.sh
ok "Tutte le app pubblicate!"

# ── 8. Crea collegamento desktop (Linux) ─────────────────────────
if [[ "$OS" == "Linux" ]] && [[ -d "$HOME/Desktop" || -d "$HOME/Scrivania" ]]; then
  DESK="${HOME}/Scrivania"
  [[ -d "$HOME/Desktop" ]] && DESK="$HOME/Desktop"
  cat > "$DESK/Web70.desktop" <<DESKTOP
[Desktop Entry]
Name=Web 7.0
Comment=Browser Freenet decentralizzato
Exec=xdg-open http://127.0.0.1:7509/v1/contract/web/browser-fn/
Icon=web-browser
Terminal=false
Type=Application
Categories=Network;
DESKTOP
  chmod +x "$DESK/Web70.desktop"
  ok "Collegamento desktop creato: $DESK/Web70.desktop"
fi

# ── 9. Crea script di avvio rapido ───────────────────────────────
cat > "$HOME/.local/bin/web70" <<STARTSCRIPT
#!/bin/bash
# Avvia Web 7.0 (nodo Freenet + apre il browser)
export PATH="\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH"
PID_FILE="\$HOME/.freenet/freenet.pid"
if [[ -f "\$PID_FILE" ]] && kill -0 "\$(cat "\$PID_FILE")" 2>/dev/null; then
  echo "Nodo già in esecuzione (PID \$(cat "\$PID_FILE"))"
else
  mkdir -p "\$HOME/.freenet"
  "$REPO_DIR/target/release/freenet" network 2>>"\$HOME/.freenet/freenet.log" &
  echo \$! > "\$PID_FILE"
  echo "Nodo avviato (PID \$!)"
  sleep 3
fi
# Apri browser
URL="http://127.0.0.1:7509/v1/contract/web/browser-fn/"
if command -v xdg-open &>/dev/null; then xdg-open "\$URL"
elif command -v open &>/dev/null; then open "\$URL"
else echo "Apri manualmente: \$URL"; fi
STARTSCRIPT
chmod +x "$HOME/.local/bin/web70"

# ── RIEPILOGO ─────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║      Installazione completata! ✓         ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Nodo Freenet:${NC}   http://127.0.0.1:7509"
echo -e "  ${BOLD}Browser:${NC}        http://127.0.0.1:7509/v1/contract/web/browser-fn/"
echo -e "  ${BOLD}FreenetTV:${NC}      http://127.0.0.1:7509/v1/contract/web/fresnettv/"
echo -e "  ${BOLD}FreenetGram:${NC}    http://127.0.0.1:7509/v1/contract/web/frenetgram/"
echo -e "  ${BOLD}FreenetPosts:${NC}   http://127.0.0.1:7509/v1/contract/web/freenetposts/"
echo ""
echo -e "  ${BOLD}Avvio rapido:${NC}   ${CYAN}web70${NC}"
echo -e "  ${BOLD}Log nodo:${NC}       $HOME/.freenet/freenet.log"
echo ""
echo -e "  Sorgente:  ${CYAN}https://github.com/blue-terminal/freenet-core${NC}"
echo -e "  App Web70: ${CYAN}https://github.com/blue-terminal/web.7.0${NC}"
echo ""
