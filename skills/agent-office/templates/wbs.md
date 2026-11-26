# WBS — [nome progetto]

**Obiettivo:** [una frase: cosa ottiene l'utente]

<!--
Albero dei deliverable con ID gerarchici. Le FOGLIE (voci senza figli) sono i task dei builder:
ognuna deve potersi eseguire leggendo solo questo file e architecture.md.
Per ogni foglia: dipendenze (ID), file di output che possiede, criterio di completamento verificabile,
livello (leggero · normale · critico, con il perché) e le sole sezioni di architecture.md da leggere.
Cancella questi commenti quando compili il file: altrimenti li rilegge ogni builder.
Le voci intermedie servono solo a raggruppare. Aggiungi livelli (1.2.1…) solo se servono.
-->

## 1. [Fondamenta]

- **1.1 [Struttura del progetto]**
  - dipende da: —
  - output: `[file di configurazione, cartelle]`
  - fatto quando: [es. «il progetto vuoto si compila e si avvia»]
  - livello: leggero — scaffolding
  - leggi: § Stack, § Struttura delle cartelle
- **1.2 [Modello dati]**
  - dipende da: 1.1
  - output: `[file o cartella]`
  - fatto quando: [es. «tipi e validazione come in architecture.md § Dati»]
  - livello: critico — dati persistenti
  - leggi: § Dati, § Contratti tra componenti

## 2. [Funzionalità]

- **2.1 [Funzionalità A]**
  - dipende da: 1.2
  - output: `[...]`
  - fatto quando: [es. «`GET /items` risponde 200 con la lista»]
  - livello: normale — logica nuova
  - leggi: § Contratti tra componenti, § Errori, sicurezza, configurazione
- **2.2 [Funzionalità B]**
  - dipende da: 1.2
  - output: `[...]`
  - fatto quando: [es. «i test di questo modulo passano»]
  - livello: normale — logica nuova
  - leggi: § Contratti tra componenti

## Ondate di build

<!-- Calcolate in Fase 1. Ondata N = foglie con tutte le dipendenze nelle ondate precedenti.
     Due foglie con file di output in comune vanno in ondate diverse. -->

1. 1.1
2. 1.2
3. 2.1 · 2.2
