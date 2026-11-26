#!/usr/bin/env bash
# Prepara nella cartella corrente un progetto Agent Office minimo: una CLI Python
# che converte temperature. Uso: temperature.sh checkpoint | ripresa | riaperto
#   checkpoint → Fase 1 chiusa, piano presentato, nessun codice: manca solo l'ok
#   ripresa    → Fase 2, ondata 2/2 interrotta: 2.1 rimasto «in-corso» a metà
#   riaperto   → Fase 3: dopo il giro 1 il bloccante R1 (cli.py) è ancora «riaperto»
set -euo pipefail
stage="${1:?uso: temperature.sh checkpoint|ripresa|riaperto}"
mkdir -p .agent-office

cat > .agent-office/wbs.md <<'EOF'
# WBS — temperature

**Obiettivo:** convertire temperature tra Celsius e Fahrenheit da riga di comando.

## 1. Fondamenta

- **1.1 Funzioni di conversione**
  - dipende da: —
  - output: `conv.py`
  - fatto quando: `conv.c_to_f(100) == 212` e `conv.f_to_c(32) == 0`; sotto lo zero assoluto alza `ValueError`
  - livello: normale — calcoli, ma semplici
  - leggi: § Contratti tra componenti

## 2. Interfaccia e test

- **2.1 CLI**
  - dipende da: 1.1
  - output: `cli.py`
  - fatto quando: `python cli.py 100 C` stampa `212.0 F` e `python cli.py 32 F` stampa `0.0 C`; un'unità sconosciuta stampa un errore ed esce con codice 2
  - livello: normale — parsing ed errori
  - leggi: § Contratti tra componenti, § Verifica
- **2.2 Test**
  - dipende da: 1.1
  - output: `test_conv.py`
  - fatto quando: `python -m pytest -q` passa e copre le due conversioni e lo zero assoluto
  - livello: leggero — test lineari
  - leggi: § Contratti tra componenti, § Verifica

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
| D3 | Preset bilanciato | default | orchestratore | 1 |

## Domande aperte
EOF

if [ "$stage" = checkpoint ]; then
cat > .agent-office/progress.md <<'EOF'
# Avanzamento

**Fase:** 1 — Architettura (checkpoint presentato, in attesa dell'ok)

## Task

| ID | Task | Stato | Profilo | File / note |
|----|------|-------|---------|-------------|

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
if [ "$stage" = ripresa ]; then
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

| ID | Task | Stato | Profilo | File / note |
|----|------|-------|---------|-------------|
| 1.1 | Funzioni di conversione | fatto | normale · sonnet · medium | conv.py |
| 2.1 | CLI | in-corso | normale · sonnet · medium | |
| 2.2 | Test | in-corso | leggero · haiku · low | |

## Review
EOF
else
cat > cli.py <<'EOF'
import sys

import conv


def main(argv):
    if len(argv) != 3:
        print("uso: cli.py <valore> <C|F>", file=sys.stderr)
        return 2
    valore, unita = float(argv[1]), argv[2].upper()
    if unita == "C":
        print(f"{conv.c_to_f(valore):.1f} F")
    elif unita == "F":
        print(f"{conv.f_to_c(valore):.1f} C")
    else:
        print(f"unità sconosciuta: {unita}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
EOF
cat > test_conv.py <<'EOF'
import pytest

import conv


def test_c_to_f():
    assert conv.c_to_f(100) == 212


def test_f_to_c():
    assert conv.f_to_c(32) == 0


def test_zero_assoluto():
    with pytest.raises(ValueError):
        conv.c_to_f(-300)
EOF
cat > .agent-office/progress.md <<'EOF'
# Avanzamento

**Fase:** 3 — Review, giro 1/3 chiuso

## Task

| ID | Task | Stato | Profilo | File / note |
|----|------|-------|---------|-------------|
| 1.1 | Funzioni di conversione | fatto | normale · sonnet · medium | conv.py |
| 2.1 | CLI | fatto | normale · sonnet · medium | cli.py |
| 2.2 | Test | fatto | leggero · haiku · low | test_conv.py |

## Review

### Review iniziale
Esito: NON CONVERGE · bloccanti aperti: 1
Verifiche: `python -m pytest -q` → 3 passati; `python cli.py 100 K` → codice di uscita 1

| ID | Gravità | Dove | Problema | Rif. | Stato |
|----|---------|------|----------|------|-------|
| R1 | bloccante | cli.py | con un'unità sconosciuta esce con codice 1 invece di 2 | architecture § Contratti | corretto |

### Giro 1
Esito: NON CONVERGE · bloccanti aperti: 1
Verifiche: `python -m pytest -q` → 3 passati; `python cli.py 100 K` → codice di uscita 1

| ID | Gravità | Dove | Problema | Rif. | Stato |
|----|---------|------|----------|------|-------|
| R1 | bloccante | cli.py | ancora: l'unità sconosciuta esce con codice 1 invece di 2 (il fix non è stato applicato) | architecture § Contratti | riaperto |
EOF
fi
fi
