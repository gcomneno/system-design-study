# Contribuire

[English](CONTRIBUTING.md) | [Italiano](CONTRIBUTING.it.md)

Questo repository è un laboratorio personale per lo studio di System Design.

I contributi sono benvenuti quando migliorano il materiale didattico senza
aggiungere contenuti grezzi protetti da copyright, materiale privato o file
binari pesanti.

## Politica linguistica

L'inglese è la lingua canonica della documentazione.

Le controparti italiane usano il suffisso `.it.md`. Comandi, percorsi, API, nomi
dei file, identificatori, simboli tecnici, codice inline, collegamenti e blocchi
di codice devono rimanere strutturalmente equivalenti nella coppia bilingue.

Ogni documento bilingue deve mostrare vicino all'inizio la navigazione reciproca
tra le lingue.

## Classificazione della documentazione

Ogni documento Markdown pubblico e tracciato deve essere classificato in
`.github/bilingual-docs.json` come uno dei seguenti:

- documento canonico con controparte italiana dedotta;
- elemento del backlog `legacy_unpaired_documents`;
- esclusione motivata in `excluded_documents`.

Nessun documento Markdown pubblico può rimanere senza classificazione.

## Regole del repository

Non aggiungere:

- file video o contenuti multimediali scaricati;
- file binari pesanti;
- raccolte grezze provenienti da corsi;
- transcript o traduzioni complete senza licenza compatibile;
- file temporanei generati;
- credenziali, token o note private.

Preferire:

- sintesi originali;
- lezioni apprese;
- quiz ed esercizi;
- domande e risposte da colloquio;
- spiegazioni tecniche corrette;
- diagrammi testuali o Mermaid quando utili;
- piccoli strumenti per l'igiene del repository.

## Metodo di lavoro

1. creare o citare una issue GitHub circoscritta;
2. lavorare su un branch dedicato e un worktree isolato;
3. preservare il significato canonico inglese;
4. aggiornare entrambi i membri di ogni coppia bilingue interessata;
5. mantenere allineati titoli, navigazione, codice e identificatori tecnici;
6. eseguire tutti i controlli del repository prima di pubblicare una pull request.

## Messaggi di commit

Usare messaggi di commit concisi.

Prefissi consigliati:

- `news:` per nuovo materiale di studio visibile;
- `fix:` per correzioni;
- `chore:` per manutenzione;
- `refactor:` per modifiche esclusivamente strutturali;
- `docs:` per modifiche generali alla documentazione.

## Stile

Mantenere le spiegazioni pratiche, concise e orientate ai colloqui.

Evitare riempitivi motivazionali. Preferire esempi, trade-off, scenari di guasto
e ragionamento ingegneristico concreto.

## Validazione locale

Eseguire:

```bash
./scripts/check-no-videos.sh
./scripts/check-public-content.sh
python3 -m unittest discover -s tests -p "test_bilingual_docs.py" -v
python3 scripts/check-bilingual-docs.py
```

Tutti i comandi devono riuscire prima di pubblicare una pull request.

## Pull request

Una pull request deve:

- riferirsi alla relativa issue GitHub;
- spiegare ambito e decisioni architetturali;
- elencare documenti migrati, legacy ed esclusi;
- riportare i risultati della validazione locale;
- evitare modifiche non correlate al materiale di studio;
- rimanere senza merge finché non viene approvata esplicitamente.
