#!/usr/bin/env bash
# Gira nella cartella di lavoro del caso. Richiede: claude plugin eval --scaffold
set -euo pipefail
cat > statistiche.py <<'PY'
def media(valori):
    return sum(valori) / len(valori)
PY
