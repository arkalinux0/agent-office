---
name: agent-office
description: >-
  Orchestra lo sviluppo di un'app o di un progetto software, in qualsiasi
  linguaggio, a fasi: WBS, architettura con flowchart Mermaid e checkpoint di
  approvazione dell'utente, build con subagent in parallelo, review a occhi
  freschi con loop di correzione limitato, integrazione e test; lo stato
  condiviso vive in .agent-office/. Usala ogni volta che l'utente vuole
  costruire, creare o sviluppare un'applicazione, un tool, un servizio, un
  sito, un bot o un'API, o una funzionalità corposa in un progetto esistente,
  per esempio «creami un'app», «costruiamo un progetto», «sviluppa X», «fammi
  un gestionale», «mettiamo in piedi un MVP», anche se non nomina la skill, e
  quando lancia /office. Non usarla per fix puntuali, singole funzioni, script
  brevi o domande sul codice.
compatibility: Claude Code (usa i subagent e il filesystem del progetto)
---

# Agent Office

Tu sei l'orchestratore: intake, architettura e integrazione le fai tu, build e review le deleghi a due subagent. C'è un solo stop obbligatorio, sull'architettura. Con l'utente parla sempre in italiano.

## Regole valide per tutto il lavoro

- **`.agent-office/` è l'unica fonte di verità.** I subagent partono freddi e vedono solo i file: ciò che serve loro va scritto lì, mai passato a voce. Se sai qualcosa solo dalla conversazione (una preferenza, un vincolo), scrivilo in `.agent-office/` prima di lanciarli.
- **Nessuna riga di codice prima dell'ok al checkpoint** della Fase 1.
- **Autonomia.** Dopo l'ok lavora da solo fino alla fine. Fermati a chiedere solo per le cose grosse: stack o framework non ovvio, operazioni distruttive o irreversibili, dipendenze esterne a pagamento, decisioni con impatto sulla sicurezza. Il resto decidilo tu e annotalo in `decisions.md`.
- **Due soli agenti**: `office-builder` scrive il codice, `office-reviewer` lo verifica. L'estetica è una lente della review e la correzione è il loop della Fase 3: non creare altri agenti.
- **Tieni aggiornata la riga «Fase» di `progress.md`.** Se il contesto viene compattato, rileggi `${CLAUDE_SKILL_DIR}/SKILL.md` e `progress.md` prima di continuare.

## Avvio

- Il progetto è la cartella di lavoro; se contiene altro che non c'entra, usa una sottocartella col nome del progetto.
- Se `.agent-office/` esiste già, è un lavoro in corso: riprendi dalla fase segnata in `progress.md`. Se la richiesta riguarda un altro progetto, chiedi prima di sovrascriverla.
- Altrimenti copia i template di `${CLAUDE_SKILL_DIR}/templates/` in `.agent-office/`.
- Se `office-builder` o `office-reviewer` non sono tra i subagent disponibili, copia `${CLAUDE_SKILL_DIR}/agents/*.md` in `~/.claude/agents/` e dillo all'utente in una riga. Finché non compaiono, lancia `general-purpose` con un prompt che inizia: «Segui le istruzioni in `${CLAUDE_SKILL_DIR}/agents/office-builder.md`» (o `office-reviewer.md`).

## Ricerca online (se serve)

Se il progetto dipende da informazioni esterne da verificare (API, librerie e versioni, valori di riferimento, normative), chiedi all'utente se puoi usare in autonomia la skill `deep-research`, dicendo in una riga cosa cercheresti. Fai la domanda insieme a quelle dell'intake se la ricerca serve per progettare, altrimenti al checkpoint: niente stop in più.

- **Sì** → registralo in `decisions.md` e da lì in poi lanciala da solo ogni volta che serve, senza richiedere. Salva la sintesi con le fonti in `.agent-office/ricerca.md`, che i subagent leggono.
- **No** → procedi con ciò che sai e annota le assunzioni.
- Se `deep-research` non è installata, chiedi lo stesso permesso per una ricerca web normale.

## Fase 0 — Intake (thread principale)

1. Leggi la richiesta e, se c'è, il codice esistente con le sue convenzioni.
2. Se la richiesta è chiara, non chiedere niente. Chiedi subito solo ciò che cambierebbe tutto il piano e non puoi dedurre (scope ambiguo, vincoli, stack non ovvio): tutte le domande in un solo messaggio, ognuna con la tua proposta.
3. Ogni scelta fatta al posto dell'utente è un'assunzione: annotala in `decisions.md`, la vedrà al checkpoint.
4. Scrivi `wbs.md`: albero dei deliverable con ID gerarchici (1, 1.1, 1.2…). Le foglie sono i task dei builder: ognuna verificabile da sola e fattibile in una sessione.

## Fase 1 — Architettura (thread principale) → CHECKPOINT

1. Scrivi `architecture.md` e `flow.mmd` (flowchart Mermaid del flusso principale). Proporziona: per un progetto piccolo bastano poche righe per sezione, e le sezioni che non servono si tolgono.
2. Completa le foglie della WBS con dipendenze, file di output e criterio «fatto quando», poi raggruppale in **ondate**: un'ondata contiene foglie con tutte le dipendenze nelle ondate precedenti; due foglie con file in comune vanno in ondate diverse.
3. **Fermati e aspetta l'ok.** Mostra in breve, rimandando ai file per i dettagli:
   - il flowchart (il contenuto di `flow.mmd` in un blocco di codice `mermaid`);
   - stack, componenti e ondate, in poche righe;
   - assunzioni e domande aperte (compreso, se serve, il permesso per la ricerca online);
   - **migliorie proposte**: idee oltre la richiesta, numerate, con una riga di costo/beneficio; entrano nel piano solo se l'utente le accetta.

   Chiudi con: «Procedo? Rispondi *ok*, *ok + 1, 3* per includere delle migliorie, oppure dimmi cosa cambiare.»
4. Modifiche piccole insieme all'ok: applicale e parti. Modifiche sostanziali: aggiorna gli artefatti e ripresenta solo ciò che cambia. Fino all'ok tocchi solo `.agent-office/`: niente scaffolding, installazioni o file di progetto.
5. All'ok aggiungi alla WBS le migliorie accettate, registra in `decisions.md` cosa ha approvato l'utente e prepara in `progress.md` una riga `da-fare` per ogni foglia.

## Fase 2 — Build (`office-builder`)

Il codice lo scrivono i builder; tu coordini.

1. Un'ondata alla volta: un builder per foglia, lanciati **in parallelo** (più chiamate nello stesso messaggio, di norma non più di 4; accorpa le foglie piccole). Aspetta che finiscano tutti prima dell'ondata successiva.
2. Prompt al builder: `Task WBS <ID>. Progetto: <percorso>.` Nient'altro: il resto è nei file.
3. A fine ondata controlla `progress.md`:
   - task non finito, o bloccato da un buco nei documenti → sistema `wbs.md`/`architecture.md` e rilancialo una volta;
   - task bloccato su una cosa grossa → porta avanti ciò che non ne dipende, poi chiedi all'utente: una domanda, con la tua raccomandazione.

## Fase 3 — Review (`office-reviewer`, occhi freschi)

1. Lancia un reviewer nuovo: `Review iniziale. Progetto: <percorso>.` Confronta il codice con `architecture.md` e la WBS, esegue build e test e accoda i finding (R1, R2…) in `progress.md` § Review, come **bloccanti** (rotto, fuori specifica, insicuro) o **minori**.
2. Zero bloccanti → Fase 4.
3. Bloccanti → **giro di correzione**: builder sui finding (`Correggi R3, R5. Progetto: <percorso>.`), raggruppati per file e in parallelo se indipendenti; poi un reviewer nuovo: `Giro N di verifica. Progetto: <percorso>.` Un fix di una riga, senza scelte di design, puoi chiederlo direttamente al reviewer.
4. **Massimo 3 giri.** Se dopo il terzo restano bloccanti, fermati: mostra cosa resta e chiedi come procedere. Chiedi subito se un fix richiede di cambiare in modo sostanziale l'architettura approvata.

I minori non tengono aperto il loop: falli correggere nei giri se costano poco, altrimenti finiscono tra gli aperti.

## Fase 4 — Integrazione (thread principale)

1. Verifica che i pezzi funzionino insieme: build, test e, se possibile, un avvio di prova (`architecture.md` § Verifica). Qui correggi solo problemi piccoli.
2. Porta la fase di `progress.md` a «Completato».
3. Report finale, breve, rimandando a `.agent-office/` per decisioni e dettagli:
   - **Fatto**: cosa funziona, per area della WBS
   - **Come si usa**: comandi per avviare e testare
   - **Verifiche**: esito di build e test
   - **Aperto**: task bloccati, minori non risolti, domande aperte
