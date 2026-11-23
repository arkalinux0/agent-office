#!/usr/bin/env bash
# Gira nella cartella di lavoro del caso. Richiede: claude plugin eval --scaffold
set -euo pipefail
bash "$(dirname "$0")/../_fixtures/temperature.sh" checkpoint
