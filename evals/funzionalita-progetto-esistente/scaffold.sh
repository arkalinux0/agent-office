#!/usr/bin/env bash
# Gira nella cartella di lavoro del caso. Richiede: claude plugin eval --scaffold
set -euo pipefail
mkdir -p gestionale/clienti tests
cat > requirements.txt <<'TXT'
flask==3.0.3
pytest==8.3.3
TXT
cat > gestionale/__init__.py <<'PY'
from flask import Flask


def crea_app():
    app = Flask(__name__)
    from gestionale.clienti.rotte import bp_clienti
    app.register_blueprint(bp_clienti, url_prefix="/clienti")
    return app
PY
touch gestionale/clienti/__init__.py
cat > gestionale/clienti/rotte.py <<'PY'
from flask import Blueprint, jsonify

bp_clienti = Blueprint("clienti", __name__)
_CLIENTI = [{"id": 1, "nome": "Rossi"}]


@bp_clienti.get("/")
def elenco_clienti():
    return jsonify(_CLIENTI)
PY
cat > tests/test_clienti.py <<'PY'
from gestionale import crea_app


def test_elenco_clienti():
    risposta = crea_app().test_client().get("/clienti/")
    assert risposta.status_code == 200
PY
