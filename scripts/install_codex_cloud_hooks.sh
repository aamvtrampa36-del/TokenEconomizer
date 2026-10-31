#!/usr/bin/env bash
# Instala el plugin original de TokenEconomizer en un runtime Codex compatible.
# No garantiza que el orquestador de Codex Cloud ejecute hooks.
set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$repo_root/scripts/build_plugin.py" ]] || [[ ! -d "$repo_root/tokeneconomizer" ]]; then
  echo 'ERROR: ejecuta este archivo desde el clon completo de TokenEconomizer.' >&2
  exit 2
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo 'ERROR: se requiere Python 3.10+.' >&2
  exit 2
fi
if ! python3 -c 'import sys; assert sys.version_info >= (3, 10)' 2>/dev/null; then
  echo 'ERROR: se requiere Python 3.10+.' >&2
  exit 2
fi
if ! command -v codex >/dev/null 2>&1; then
  echo 'ERROR: este entorno no incluye Codex CLI; no es posible instalar el plugin ni confirmar hooks aquí.' >&2
  exit 3
fi

market_root="${CODEX_HOME:-$HOME/.codex}/tokeneconomizer-cloud-marketplace"
mkdir -p "$(dirname "$market_root")"
python3 "$repo_root/scripts/build_plugin.py" --out "$market_root"

# Codex informa en JSON si un marketplace ya estaba registrado.
codex plugin marketplace add "$market_root" --json
codex plugin add tokeneconomizer@tokeneconomizer --json

# Comprueba la instalación, no equivale a comprobar que los hooks se ejecutaron.
codex plugin list --json | python3 -c '
import json, sys
payload=json.load(sys.stdin)
rows=payload.get("installed", [])
found=[p for p in rows if p.get("name")=="tokeneconomizer" and p.get("marketplaceName")=="tokeneconomizer"]
if not found or not all(p.get("enabled", True) for p in found):
    print("ERROR: el plugin no aparece instalado y habilitado", file=sys.stderr)
    sys.exit(4)
print("TokenEconomizer instalado en la configuración CLI de este entorno.")
'
cat <<'END'
ATENCIÓN: instala el plugin en este runtime; NO confirma activación en Codex Cloud.
Los hooks requieren confianza explícita y un runtime que los soporte.
Prueba en una sesión nueva: /hooks y $tokeneconomizer:status.
Este plugin usa estado local ~/.tokeneconomizer y NO sincroniza con el Worker remoto automáticamente.
END
