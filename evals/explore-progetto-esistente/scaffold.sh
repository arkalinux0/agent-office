#!/usr/bin/env bash
# Gira nella cartella di lavoro del caso. Richiede: claude plugin eval --scaffold
set -euo pipefail
for m in clienti fornitori ordini fatture magazzino report utenti; do
  mkdir -p "app/$m" tests
  cat > "app/$m/__init__.py" <<EOF
EOF
  cat > "app/$m/rotte.py" <<EOF
from flask import Blueprint, jsonify

bp_$m = Blueprint("$m", __name__)


@bp_$m.get("/")
def elenco():
    return jsonify([])
EOF
  cat > "app/$m/servizi.py" <<EOF
def carica_$m(db):
    return db.execute("SELECT * FROM $m").fetchall()
EOF
  cat > "tests/test_$m.py" <<EOF
from app import crea_app


def test_elenco_$m():
    assert crea_app().test_client().get("/$m/").status_code == 200
EOF
done
cat > app/__init__.py <<EOF
from flask import Flask


def crea_app():
    app = Flask(__name__)
    for nome in ["clienti", "fornitori", "ordini", "fatture", "magazzino", "report", "utenti"]:
        modulo = __import__(f"app.{nome}.rotte", fromlist=["x"])
        app.register_blueprint(getattr(modulo, f"bp_{nome}"), url_prefix=f"/{nome}")
    return app
EOF
printf "flask==3.0.3\npytest==8.3.3\n" > requirements.txt
printf "# Gestionale\n\nAvvio: flask --app app run\nTest: python -m pytest -q\n" > README.md
