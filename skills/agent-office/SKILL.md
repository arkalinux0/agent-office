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
- **Due soli agenti**: `office-builder` scrive il codice, `office-reviewer` lo verifica. L'estetica è una lente della review e la correzione è il loop della Fase 3: non creare altri agenti. Unica eccezione, già inclusa in Claude Code: `Explore`, in sola lettura, solo in Fase 0 (vedi lì).
- **Ogni lancio ha un profilo**: modello ed effort scelti in base al lavoro (vedi «Profili di lavoro»). Si spende di più solo dove sbagliare costa.
- **Thread principale snello.** Ogni tuo turno rimanda al modello tutta la conversazione: non leggere il codice (ti bastano i report di builder e reviewer), non ricopiare i report in chat, registrali nei file e vai avanti, modifica i documenti con Edit mirati invece di rileggerli e riscriverli.
- **`progress.md` e `decisions.md` li scrivi tu.** I builder lavorano in parallelo e le loro scritture si sovrapporrebbero: per questo non toccano lo stato condiviso, ma riportano esito, decisioni e domande nella risposta, e tu li registri. Lo stesso vale per il reviewer: restituisce il report e lo accodi tu. Scrivi questi file con Write o Edit, non con Bash: con la sandbox attiva le scritture da Bash in `.agent-office/` vengono bloccate.
- **Tieni aggiornata la riga «Fase» di `progress.md`.** Se il contesto viene compattato, rileggi `${CLAUDE_SKILL_DIR}/SKILL.md` e `progress.md` prima di continuare.

## Avvio

- Il progetto è la cartella di lavoro; se contiene altro che non c'entra, usa una sottocartella col nome del progetto.
- Se `.agent-office/` esiste già, è un lavoro in corso: riprendi dalla fase segnata in `progress.md`. Se la richiesta riguarda un altro progetto, chiedi prima di sovrascriverla. Prima di ripartire, riallinea lo stato, perché la sessione precedente può essersi interrotta a metà:
  - un task `in-corso` non lo sta facendo più nessuno: controlla i suoi file di output contro il «fatto quando» e segnalo `fatto`, oppure rimettilo `da-fare` e rilancialo con la sua ondata;
  - in Fase 3, riparti dall'ultima sezione di § Review: se ha bloccanti `aperto` o `riaperto`, il prossimo passo è un giro di correzione; se ci sono finding `corretto` non ancora verificati, il prossimo passo è un giro di verifica.
- Altrimenti copia i template di `${CLAUDE_SKILL_DIR}/templates/` in `.agent-office/`.
- I subagent si chiamano `office-builder` e `office-reviewer`; se Agent Office è installato come plugin compaiono come `agent-office:office-builder` e `agent-office:office-reviewer`. Usa il nome che trovi tra i subagent disponibili. Se non c'è in nessuna delle due forme, copia `${CLAUDE_SKILL_DIR}/agents/*.md` in `~/.claude/agents/` e dillo all'utente in una riga. Finché non compaiono, lancia `general-purpose` con un prompt che inizia: «Segui le istruzioni in `${CLAUDE_SKILL_DIR}/agents/office-builder.md`» (o `office-reviewer.md`).

## Ricerca online (se serve)

Se il progetto dipende da informazioni esterne da verificare (API, librerie e versioni, valori di riferimento, normative), chiedi all'utente se puoi usare in autonomia la skill `deep-research`, dicendo in una riga cosa cercheresti. Fai la domanda insieme a quelle dell'intake se la ricerca serve per progettare, altrimenti al checkpoint: niente stop in più.

- **Sì** → registralo in `decisions.md` e da lì in poi lanciala da solo ogni volta che serve, senza richiedere. Salva la sintesi con le fonti in `.agent-office/ricerca.md`, che i subagent leggono.
- **No** → procedi con ciò che sai e annota le assunzioni.
- Se `deep-research` non è installata, chiedi lo stesso permesso per una ricerca web normale.

## Profili di lavoro

In Fase 1 dai a ogni foglia un **livello**, con la prima regola che vale:

1. **critico** se tocca sicurezza (login, permessi, segreti), dati persistenti o migrazioni, soldi o calcoli su cui l'utente fa affidamento, concorrenza, o contratti usati da tre o più moduli;
2. **normale** se c'è logica nuova o incertezza: requisiti interpretati, libreria poco nota, codice esistente da modificare;
3. **leggero** per il resto: scaffolding, configurazione, CRUD lineare, stili, documentazione.

Nel dubbio sul rischio sali di livello, sul resto scendi.

| Livello | `model` | `effort` |
|---|---|---|
| leggero | `haiku` | `low` |
| normale | `sonnet` | `medium` |
| critico | `opus` | `high` |

- Passa `model` ed `effort` a ogni chiamata Agent. Mai un modello più forte di quello della sessione: se la sessione è su `sonnet`, il critico resta `sonnet` con effort `high`.
- Se l'utente ha fissato il modello dei subagent (`CLAUDE_CODE_SUBAGENT_MODEL_FORCE`) o l'effort (`CLAUDE_CODE_EFFORT_LEVEL`), quella scelta vince: dillo in una riga al checkpoint.
- **Preset**, registrato in `decisions.md`: *bilanciato* (default) usa la tabella; *economico* scende di un livello ovunque tranne la review; *qualità* sale di un livello.
- **Review**: modello pari al più forte usato in build e mai sotto `sonnet` (salvo sessione più debole), effort `high`, in ogni preset. Giro di verifica: stesso modello, effort `medium`, che torna `high` se il giro prima ha riaperto qualcosa.
- **Correzioni**: il livello del task che ha prodotto il finding. **Escalation**: un finding `riaperto`, o un task bloccato due volte, fa salire quel lavoro di un livello. Oltre il critico non si sale: valgono il tetto dei 3 giri e la domanda all'utente.
- In `progress.md` registra il profilo di ogni lancio (es. `critico · opus · high`, `↑` se c'è stata escalation).

## Fase 0 — Intake (thread principale)

1. Leggi la richiesta e, se c'è, il codice esistente con le sue convenzioni. Se il progetto esistente ha più di una ventina di file di codice, invece di leggerlo tu lancia `Explore` (1-2 lanci con domande precise: struttura, convenzioni, comandi di build e test, punti che la richiesta tocca). Lancialo prima di aprire file tu, e dopo non rifare il suo lavoro: apri solo i file che la richiesta modifica direttamente, se il riassunto non basta. Builder e reviewer non vedranno mai il suo riassunto: riporta ciò che serve in `architecture.md` § Codice esistente. Per progetti nuovi o di pochi file non serve.
2. Se la richiesta è chiara, non chiedere niente. Chiedi subito solo ciò che cambierebbe tutto il piano e non puoi dedurre (scope ambiguo, vincoli, stack non ovvio): tutte le domande in un solo messaggio, ognuna con la tua proposta.
3. Ogni scelta fatta al posto dell'utente è un'assunzione: annotala in `decisions.md`, la vedrà al checkpoint.
4. Scrivi `wbs.md`: albero dei deliverable con ID gerarchici (1, 1.1, 1.2…). Le foglie sono i task dei builder: ognuna verificabile da sola e fattibile in una sessione.

## Fase 1 — Architettura (thread principale) → CHECKPOINT

1. Scrivi `architecture.md` e `flow.mmd` (flowchart Mermaid del flusso principale). Proporziona: per un progetto piccolo bastano poche righe per sezione, e le sezioni che non servono si tolgono. Mentre compili i template cancella i loro commenti `<!-- -->`: servono a te, e altrimenti li rilegge ogni subagent.
2. Completa le foglie della WBS con dipendenze, file di output, criterio «fatto quando», **livello** (vedi «Profili di lavoro») e **`leggi:`**, le sole sezioni di `architecture.md` che servono a quella foglia: di norma 2-3, perché § Convenzioni il builder la legge sempre. Se a una foglia servono quasi tutte, è troppo grande: dividila. Poi raggruppale in **ondate**: un'ondata contiene foglie con tutte le dipendenze nelle ondate precedenti; due foglie con file in comune vanno in ondate diverse.
3. **Fermati e aspetta l'ok.** Mostra in breve, rimandando ai file per i dettagli:
   - il flowchart (il contenuto di `flow.mmd` in un blocco di codice `mermaid`);
   - stack, componenti e ondate, in poche righe;
   - il profilo, in una riga: `Profilo bilanciato · critici: 2.1 calcolo punteggi, 3.1 login · normali: 5 · leggeri: 3`;
   - assunzioni e domande aperte (compreso, se serve, il permesso per la ricerca online);
   - **migliorie proposte**: idee oltre la richiesta, numerate, con una riga di costo/beneficio; entrano nel piano solo se l'utente le accetta. La prima è sempre la **rete di sicurezza git** (vedi sotto), a meno che l'utente l'abbia già esclusa.

   Chiudi con: «Procedo? Rispondi *ok*, *ok + 1, 3* per includere delle migliorie, *ok, qualità* o *ok, risparmia* per cambiare il profilo (o *ok, 2.3 critico* per un task solo), oppure dimmi cosa cambiare.»
4. Modifiche piccole insieme all'ok: applicale e parti. Modifiche sostanziali: aggiorna gli artefatti e ripresenta solo ciò che cambia. Fino all'ok tocchi solo `.agent-office/`: niente scaffolding, installazioni o file di progetto.
5. All'ok aggiungi alla WBS le migliorie accettate, registra in `decisions.md` cosa ha approvato l'utente e prepara in `progress.md` una riga `da-fare` per ogni foglia.

**Rete di sicurezza git.** Serve a poter tornare indietro dopo un lavoro lungo e autonomo. La proponi al checkpoint dicendo cosa faresti:
- se la cartella non è un repository, `git init` con un `.gitignore` adatto allo stack; se lo è, un branch nuovo `agent-office/<progetto>`. Se l'utente ha modifiche non committate, non includerle nei tuoi commit: dillo al checkpoint;
- un commit alla fine di ogni ondata, di ogni giro di correzione e dell'integrazione, con messaggi come `agent-office: ondata 2 (2.1, 2.2)` o `agent-office: giro 1 (R3, R5)`. Includi anche `.agent-office/`;
- mai push, merge, rebase o riscritture della storia: restano all'utente.

Se `git config user.email` è vuoto, chiedi al checkpoint con quale identità fare i commit. Accettata, registrala in `decisions.md`; i commit li fai tu, mai i builder.

## Fase 2 — Build (`office-builder`)

Il codice lo scrivono i builder; tu coordini.

1. Un'ondata alla volta: un builder per foglia, lanciati **in parallelo** (più chiamate nello stesso messaggio, di norma non più di 4), ognuno con `model` ed `effort` del suo livello. Ogni builder ha un costo fisso di avvio: una foglia leggera da sola non lo merita, accorpala con un'altra della stessa ondata (il gruppo prende il livello più alto). Aspetta che finiscano tutti prima dell'ondata successiva.
2. Prima di lanciare l'ondata, segna le sue foglie `in-corso` in `progress.md`.
3. Prompt al builder: `Task WBS <ID>. Progetto: <percorso>.` Nient'altro: il resto è nei file.
4. Quando i builder rispondono, registra tu ciò che riportano: in `progress.md` stato, file toccati e note della loro riga; in `decisions.md` le decisioni (Chi: builder + ID) e le domande aperte.
5. A fine ondata, prima di passare alla successiva:
   - task non finito, o bloccato da un buco nei documenti → sistema `wbs.md`/`architecture.md` e rilancialo una volta;
   - task bloccato perché deve modificare file di un altro task → aggiorna la WBS (assegna quel file a una foglia sola, oppure aggiungi una foglia in un'ondata successiva) e rilancialo;
   - task bloccato su una cosa grossa → porta avanti ciò che non ne dipende, poi chiedi all'utente: una domanda, con la tua raccomandazione;
   - rete git accettata → commit dell'ondata.

## Fase 3 — Review (`office-reviewer`, occhi freschi)

1. Lancia un reviewer nuovo: `Review iniziale. Progetto: <percorso>.` Confronta il codice con `architecture.md` e la WBS, esegue build e test e restituisce un report con i finding (R1, R2…), **bloccanti** (rotto, fuori specifica, insicuro) o **minori**. Accodalo così com'è in fondo a `progress.md` § Review.
2. Bloccanti (`aperto` o `riaperto`) → **giro di correzione**: builder sui finding (`Correggi R3, R5. Progetto: <percorso>.`), raggruppati per file e in parallelo solo se toccano file diversi. Al loro ritorno segna `corretto` in § Review i finding che riportano risolti. Con la rete git, commit del giro. Poi un reviewer nuovo, `Giro N di verifica. Progetto: <percorso>.`, e accoda anche il suo report. La verifica guarda solo i finding e i file toccati dal giro, non tutto il progetto: quello l'ha già fatto la review iniziale.
3. Zero bloccanti → se tra i minori ce ne sono di poco costo, fai **un** giro di correzione solo su quelli, con la sua verifica, poi vai in Fase 4. Altrimenti vai subito in Fase 4.
4. **Massimo 3 giri** in tutto, compreso quello sui minori. Se dopo il terzo restano bloccanti, fermati: mostra cosa resta e chiedi come procedere. Chiedi subito se un fix richiede di cambiare in modo sostanziale l'architettura approvata.

I minori non tengono aperto il loop: nei giri sui bloccanti falli correggere se costano poco e toccano gli stessi file; quelli che restano finiscono tra gli aperti del report.

## Fase 4 — Integrazione (thread principale)

1. Verifica che i pezzi funzionino insieme: build, test e, se possibile, un avvio di prova (`architecture.md` § Verifica). Qui correggi tu solo problemi piccoli: una riga o poco più, senza scelte di design.
   Un problema più grosso diventa un finding bloccante: accodalo in § Review (`### Integrazione`, con ID che continuano la numerazione) e torna in Fase 3 per un giro di correzione, se ne restano; altrimenti fermati e chiedi all'utente come procedere.
2. Porta la fase di `progress.md` a «Completato» e, con la rete git, fai il commit finale.
3. Report finale, breve, rimandando a `.agent-office/` per decisioni e dettagli:
   - **Fatto**: cosa funziona, per area della WBS
   - **Come si usa**: comandi per avviare e testare
   - **Verifiche**: esito di build e test
   - **Aperto**: task bloccati, minori non risolti, domande aperte
