# Studio di System Design

[English](README.md) | [Italiano](README.it.md)

Un repository pubblico di apprendimento per studiare System Design attraverso
appunti originali, sintesi, quiz, risposte da colloquio, esercizi e piccoli
strumenti di supporto.

Transcript grezzi e materiale proveniente da fonti private possono essere usati
localmente come input, ma il repository pubblico contiene soltanto materiali
didattici revisionati e rielaborati.

## Obiettivo

Trasformare appunti grezzi e materiali di studio in contenuti riutilizzabili:

1. riorganizzazione delle note sorgente;
2. sintesi concisa;
3. concetti chiave;
4. trade-off architetturali;
5. quiz;
6. domande da colloquio;
7. risposte ragionate e correzioni.

## Metodo di studio

Il flusso di lavoro parte dal testo.

Ogni argomento deve produrre materiali pratici e revisionabili, non una copia
della fonte originale. Il contenuto pubblico deve privilegiare ragionamento
ingegneristico, esempi concreti, modalità di guasto e spiegazioni utili per i
colloqui.

## Struttura del repository

```text
system-design-study/
├── .github/
│   ├── bilingual-docs.json
│   └── workflows/
│       └── bilingual-docs.yml
├── archive/
├── docs/
├── scripts/
│   ├── check-bilingual-docs.py
│   ├── check-no-videos.sh
│   └── check-public-content.sh
├── sessions/
├── tests/
│   └── test_bilingual_docs.py
├── CONTRIBUTING.md
├── CONTRIBUTING.it.md
├── README.md
└── README.it.md
```

- `archive/`: note relative a materiale sorgente privato o locale.
- `sessions/`: materiale didattico rielaborato e organizzato per sessione.
- `docs/`: politiche del repository e convenzioni di manutenzione.
- `scripts/`: strumenti di validazione e igiene del repository.

## Lingue della documentazione

L'inglese è la lingua canonica della documentazione.

Le controparti italiane usano il suffisso `.it.md`. Le coppie bilingui e il
backlog legacy misurabile sono registrati in `.github/bilingual-docs.json`.

I contributi devono seguire [CONTRIBUTING.it.md](CONTRIBUTING.it.md).

## Percorso di studio attuale

Il percorso attuale riguarda API Design.

Il materiale disponibile tratta:

- API come contratti, astrazioni e confini tra servizi;
- REST, GraphQL e gRPC;
- consistenza, semplicità, sicurezza e performance;
- quiz e correzioni ragionate;
- domande e risposte da colloquio.

Vedere [Sessioni di studio](sessions/README.md).

## Politica di pubblicazione e copyright

I file video sono esclusi deliberatamente.

Non pubblicare transcript completi, traduzioni complete, materiale scaricato da
corsi, note private o corpus derivati da fonti senza autorizzazione esplicita o
licenza compatibile.

I materiali pubblici preferiti sono sintesi originali, lezioni apprese, quiz,
esercizi, diagrammi e risposte da colloquio.

## Validazione locale

Prima di pubblicare modifiche, eseguire i controlli di igiene del repository e
della documentazione bilingue:

```bash
./scripts/check-no-videos.sh
./scripts/check-public-content.sh
python3 -m unittest discover -s tests -p "test_bilingual_docs.py" -v
python3 scripts/check-bilingual-docs.py
```

La foundation bilingue è tracciata nella
[issue #1](https://github.com/gcomneno/system-design-study/issues/1).
