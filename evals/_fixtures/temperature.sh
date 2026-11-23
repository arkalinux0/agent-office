#!/usr/bin/env bash
# Prepara nella cartella corrente un progetto Agent Office minimo: una CLI Python
# che converte temperature. Uso: temperature.sh checkpoint | ripresa
#   checkpoint → Fase 1 chiusa, piano presentato, nessun codice: manca solo l'ok
#   ripresa    → Fase 2, ondata 2/2 interrotta: 2.1 rimasto «in-corso» a metà
set -euo pipefail
stage="${1:?uso: temperature.sh checkpoint|ripresa}"
mkdir -p .agent-office

cat > .agent-office/wbs.md <<'EOF'
# WBS — temperature

**Obiettivo:** convertire temperature tra Celsius e Fahrenheit da riga di comando.

## 1. Fondamenta

- **1.1 Funzioni di conversione**
  - dipende da: —
  - output: `conv.py`
  - fatto quando: `conv.c_to_f(100) == 212` e `conv.f_to_c(32) == 0`; sotto lo zero assoluto alza `ValueError`

## 2. Interfaccia e test

- **2.1 CLI**
  - dipende da: 1.1
  - output: `cli.py`
  - fatto quando: `python cli.py 100 C` stampa `212.0 F` e `python cli.py 32 F` stampa `0.0 C`; un'unità sconosciuta stampa un errore ed esce con codice 2
- **2.2 Test**
  - dipende da: 1.1
  - output: `test_conv.py`
  - fatto quando: `python -m pytest -q` passa e copre le due conversioni e lo zero assoluto

## Ondate di build

1. 1.1
2. 2.1 · 2.2
EOF

cat > .agent-office/architecture.md <<'EOF'
# Architettura — temperature

## Perimetro

- **Cosa fa:** converte una temperatura tra Celsius e Fahrenheit.
- **Incluso:** due conversioni, CLI, test.
- **Escluso:** Kelvin, interfaccia grafica.

## Stack

| Livello | Scelta | Perché |
|---------|--------|--------|
| Linguaggio | Python 3, solo libreria standard | script piccolo |
| Test | pytest | standard |

## Contratti tra componenti

- `conv.c_to_f(c: float) -> float` e `conv.f_to_c(f: float) -> float`; sotto lo zero assoluto (−273.15 °C, −459.67 °F) alzano `ValueError`.
- `cli.py <valore> <C|F>`: stampa il valore convertito con una cifra decimale e l'unità di arrivo (`212.0 F`). Errori su stderr, codice di uscita 2.

## Verifica

- Test: `python -m pytest -q`
- Avvio: `python cli.py 100 C`
EOF

cat > .agent-office/flow.mmd <<'EOF'
flowchart TD
    A(["python cli.py valore unità"]) --> B{"Unità valida?"}
    B -->|no| E(["Errore, codice 2"])
    B -->|sì| C["conv.c_to_f / conv.f_to_c"]
    C --> D(["Stampa il risultato"])
EOF

cat > .agent-office/decisions.md <<'EOF'
# Decisioni

## Log

| # | Decisione | Perché | Chi | Fase |
|---|-----------|--------|-----|------|
| D1 | Solo Celsius e Fahrenheit | richiesta minima | orchestratore | 0 |
| D2 | Nessuna rete git | esclusa dall'utente | utente | 1 |

## Domande aperte
EOF

if [ "$stage" = checkpoint ]; then
cat > .agent-office/progress.md <<'EOF'
# Avanzamento

**Fase:** 1 — Architettura (checkpoint presentato, in attesa dell'ok)

## Task

| ID | Task | Stato | File / note |
|----|------|-------|-------------|

## Review
EOF
else
cat > conv.py <<'EOF'
ZERO_C = -273.15
ZERO_F = -459.67


def c_to_f(c: float) -> float:
    if c < ZERO_C:
        raise ValueError("sotto lo zero assoluto")
    return c * 9 / 5 + 32


def f_to_c(f: float) -> float:
    if f < ZERO_F:
        raise ValueError("sotto lo zero assoluto")
    return (f - 32) * 5 / 9
EOF
cat > cli.py <<'EOF'
import sys

import conv


def main(argv):
    valore = float(argv[1])
    # TODO: scegliere la conversione in base all'unità e gestire gli errori
EOF
cat > .agent-office/progress.md <<'EOF'
# Avanzamento

**Fase:** 2 — Build, ondata 2/2

## Task

| ID | Task | Stato | File / note |
|----|------|-------|-------------|
| 1.1 | Funzioni di conversione | fatto | conv.py |
| 2.1 | CLI | in-corso | |
| 2.2 | Test | in-corso | |

## Review
EOF
fi
