# Architettura — [nome progetto]

<!-- Proporziona al progetto: per un tool piccolo bastano poche righe per sezione; togli le sezioni che non servono. -->

## Perimetro

- **Cosa fa:** [2-3 righe]
- **Incluso:** [funzionalità di questa versione]
- **Escluso:** [cosa NON si fa ora]

## Stack

| Livello | Scelta | Perché |
|---------|--------|--------|
| Linguaggio / runtime | | |
| Framework / librerie chiave | | |
| Dati / persistenza | | |
| Test | | |

## Componenti

| Componente | Responsabilità | Dove |
|------------|----------------|------|
| | | `[cartella o file]` |

## Struttura delle cartelle

```text
[albero delle cartelle principali]
```

## Dati

[Entità, campi principali, relazioni, formato di persistenza; oppure «nessuno».]

## Contratti tra componenti

<!-- È la sezione che permette ai builder di lavorare in parallelo senza parlarsi: firme di funzioni e moduli pubblici,
     endpoint (metodo, path, input, output, errori), eventi, formati di file e di configurazione.
     Sii preciso: ciò che non è scritto qui, ogni builder lo inventerà a modo suo. -->

## Flussi

Diagramma in `flow.mmd`. [Una riga per ogni flusso non ovvio.]

## Errori, sicurezza, configurazione

- **Errori:** [strategia di gestione e messaggi all'utente]
- **Sicurezza:** [validazione degli input, autenticazione, segreti fuori dal codice]
- **Configurazione:** [variabili d'ambiente, file di config]

## Convenzioni

[Stile, naming, formatter e linter. Se il progetto esiste già, quelle in uso.]

## Verifica

<!-- Comandi che reviewer e orchestratore lanceranno. Se non ci sono test, prevedi almeno uno smoke test eseguibile. -->

- Build: `[comando]`
- Test: `[comando]`
- Avvio: `[comando]`

## Migliorie proposte

<!-- Idee oltre la richiesta. Entrano nella WBS solo se l'utente le accetta al checkpoint. -->

1. [Miglioria] — costo: [...] · beneficio: [...]
