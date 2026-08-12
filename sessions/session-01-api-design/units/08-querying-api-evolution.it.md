# Unità 08 – Query ed evoluzione delle API

[English](08-querying-api-evolution.md) | [Italiano](08-querying-api-evolution.it.md)

## Obiettivo didattico

Progettare API di collection che rimangano efficienti con la crescita dei dati ed evolvere i contratti pubblici senza rompere inaspettatamente i client esistenti.

I due problemi principali sono:

- controllare ciò che restituisce una richiesta su una collection;
- controllare come cambia l'API nel tempo.

## Le collection hanno bisogno di limiti

Una collection può crescere da dieci record a milioni.

Un'API che restituisce semplicemente tutte le risorse corrispondenti può generare nel tempo:

- payload molto grandi;
- elevato carico sul database;
- alto costo di serializzazione;
- trasferimenti di rete lenti;
- pressione sulla memoria;
- scarse performance del client.

Filtering, sorting e pagination fanno quindi parte dell'API design, non sono soltanto comodità del frontend.

## Filtering

Il filtering limita la collection alle risorse che rispettano determinati criteri.

Esempio:

`GET /products?category=books&in_stock=true`

Dimensioni comuni dei filtri:

- stato;
- categoria;
- owner;
- data di creazione;
- visibilità;
- stato del workflow;
- attributi specifici del dominio.

I filtri devono avere semantica documentata.

Un client non dovrebbe dover indovinare:

- case sensitivity;
- valori accettati;
- inclusività degli intervalli;
- combinazione di più filtri;
- comportamento di valori null o mancanti.

## Il filtering è un contratto pubblico

Quando i client dipendono da un filtro, il suo significato diventa parte dell'API.

Cambiare:

`status=active`

da:

> risorse attualmente abilitate

a:

> risorse abilitate almeno una volta nell'ultimo mese

può essere una breaking change semantica anche se il nome del parametro non cambia.

La compatibilità riguarda anche il comportamento, non soltanto la sintassi.

## Sorting

Il sorting consente al server di restituire una collection secondo un ordine definito.

Esempio:

`GET /products?sort=price`

Un'API dovrebbe documentare:

- campi ordinabili;
- sintassi ascending/descending;
- ordine predefinito;
- comportamento in caso di parità;
- interazione tra sorting e pagination.

Un ordinamento deterministico è particolarmente importante per la paginazione.

## Ordinamento stabile

Supponiamo di ordinare i prodotti soltanto per timestamp di creazione.

Due prodotti possono avere lo stesso timestamp.

Se l'API non definisce un ordinamento secondario deterministico, i confini delle pagine possono diventare instabili.

Un ordine concettualmente più robusto potrebbe essere:

`created_at DESC, id DESC`

I campi concreti dipendono dal dominio.

La proprietà importante è la determinismo dell'ordinamento.

## Pagination

La pagination divide una collection potenzialmente grande in risposte limitate.

Una buona API paginata comunica normalmente informazioni sufficienti perché il client possa richiedere i risultati successivi.

Strategie comuni:

- numero di pagina;
- offset e limit;
- cursor o page token.

Hanno trade-off differenti.

## Paginazione per numero di pagina

Forma tipica:

`GET /products?page=3&limit=20`

Vantaggi:

- intuitiva per gli utenti;
- utile per UI tradizionali a pagine numerate;
- semplice da esporre.

Trade-off:

- spesso implementata tramite offset;
- numeri di pagina molto elevati possono diventare costosi;
- inserimenti o cancellazioni concorrenti possono spostare i confini delle pagine.

L'astrazione pubblica basata sul numero di pagina e l'implementazione interna del database non devono necessariamente coincidere, ma spesso condividono simili problemi di instabilità.

## Offset pagination

Forma tipica:

`GET /products?offset=40&limit=20`

Concettualmente:

- salta i primi 40 risultati;
- restituisci i 20 successivi.

### Punti di forza

- facile da capire;
- facile da implementare in molti database;
- consente di saltare direttamente a una posizione arbitraria.

### Debolezze

Su dataset grandi o molto dinamici:

- offset elevati possono diventare costosi;
- nuove righe possono spostare gli offset successivi;
- cancellazioni possono spostare quelli precedenti;
- tra richieste successive il client può osservare duplicati o risorse saltate.

Offset pagination non è sbagliata.

È semplicemente un trade-off.

## Cursor-based pagination

La cursor pagination restituisce un valore opaco che rappresenta il punto dal quale deve continuare l'attraversamento.

Risposta concettuale:

- elementi;
- next cursor.

Il client restituisce poi quel cursor per ottenere il gruppo successivo.

### Punti di forza

- adatta a collection molto grandi;
- buon fit per feed che cambiano continuamente;
- può evitare grandi offset costosi;
- può preservare l'attraversamento rispetto a una chiave di ordinamento stabile.

### Trade-off

- più difficile saltare direttamente alla pagina 847;
- il design del cursor deve preservare la semantica dell'ordinamento;
- i cursor dovrebbero normalmente essere opachi per i client;
- scadenza e invalidazione devono essere documentate.

Il cursor fa parte del protocollo di pagination, non è un dettaglio implementativo del database che il client debba interpretare.

## Un cursor non è “l'hash della pagina”

Un cursor non dovrebbe essere pensato semplicemente come hash che rappresenta un numero di pagina.

Può codificare o fare riferimento a informazioni come:

- ultima sort key osservata;
- identificatore univoco;
- stato della query;
- informazioni sullo snapshot;
- stato di continuazione server-side.

La proprietà importante è la continuazione, non la numerazione delle pagine.

## La pagination va progettata presto

Aggiungere la pagination dopo che ai client è stata promessa una collection completa e illimitata può romperli a livello comportamentale.

Esempio:

1. la vecchia API restituisce tutte le 75 risorse;
2. un client esistente assume di ricevere l'intera collection;
3. il server introduce successivamente un page size predefinito di 50;
4. il vecchio client elabora silenziosamente soltanto 50 risorse.

Nessun campo è stato rimosso.

Il client si è comunque rotto.

Per collection che possono crescere, la pagination dovrebbe quindi generalmente far parte del contratto iniziale.

## Metadati della risposta

Una risposta paginata può esporre metadati utili come:

- token della pagina successiva;
- token della pagina precedente quando appropriato;
- dimensione della pagina;
- conteggio totale quando sostenibile.

I total count esatti non sono sempre economici.

Su dataset grandi o distribuiti calcolare un totale preciso può richiedere lavoro significativo.

Non promettere un conteggio esatto se il prodotto non ne ha realmente bisogno o il sistema non può sostenerlo.

## Evoluzione dell'API

Un'API è un contratto utilizzato da software esterno all'implementazione.

Quando i client sono distribuiti, cambiare quel contratto ha conseguenze.

La compatibilità va considerata su più dimensioni:

- wire format;
- compatibilità del codice o delle client library;
- comportamento;
- semantica.

Una risposta strutturalmente valida può comunque essere incompatibile se cambia il suo significato.

## Cambiamenti comunemente non breaking

A seconda del contratto e del modello di serializzazione, modifiche spesso considerate compatibili includono:

- aggiunta di un endpoint opzionale;
- aggiunta di un parametro request opzionale;
- aggiunta di un campo response opzionale che i client devono poter ignorare;
- rilassamento di una restrizione sull'input;
- aggiunta di funzionalità senza cambiare il comportamento esistente.

Non sono universalmente sicure.

I client possono aver fatto assunzioni non documentate.

La compatibilità deve essere valutata rispetto al contratto reale.

## Cambiamenti comunemente breaking

Esempi:

- rimuovere un campo;
- rinominare un campo;
- cambiare incompatibilmente il tipo di un campo;
- rendere obbligatorio un input prima opzionale;
- rimuovere un valore enum accettato;
- cambiare il formato di un valore esistente;
- cambiare il significato di un campo;
- cambiare gli identificatori delle risorse;
- cambiare garanzie di ordinamento usate dai client;
- trasformare una collection precedentemente completa in una risposta implicitamente troncata dalla pagination.

Una breaking change può quindi essere sintattica, strutturale oppure semantica.

## Compatibilità semantica

I cambiamenti semantici sono facili da sottovalutare.

Supponiamo che:

`GET /orders/{id}`

abbia sempre restituito:

`status = shipped`

soltanto dopo l'accettazione del pacco da parte del corriere.

Se il server cambia silenziosamente quel significato in:

`status = shipped`

appena il magazzino stampa l'etichetta, i client esistenti possono comportarsi in modo errato.

Nome e tipo del campo non sono cambiati.

Il contratto si è comunque rotto.

## Versioning

Il versioning è uno strumento per gestire evoluzioni incompatibili.

Una convenzione REST comune è il versioning nel path:

`/api/v1/products`

seguito da:

`/api/v2/products`

quando viene introdotto un nuovo contratto incompatibile.

È facile da comprendere e da gestire.

Non è l'unica strategia possibile.

Altri sistemi possono negoziare versioni delle rappresentazioni o dell'API tramite header o convenzioni sui media type.

Il punto importante non è dove viene scritto il numero di versione.

Il punto importante è:

- cosa viene realmente versionato;
- cosa viene considerato compatibile;
- per quanto tempo convivono le versioni;
- come migrano i client;
- come viene comunicata la deprecazione.

## Non versionare ogni modifica

Una nuova major version non dovrebbe essere la risposta automatica a ogni nuova funzionalità.

Se una modifica preserva il contratto esistente, mantenere la stessa versione è normalmente più semplice.

Esempi che spesso non richiedono una nuova major version:

- aggiungere un endpoint opzionale;
- aggiungere una proprietà response opzionale;
- aggiungere funzionalità opzionale;
- correggere dettagli implementativi senza cambiare la semantica osservabile.

Creare troppe versioni aumenta:

- costo di manutenzione;
- matrice dei test;
- complessità della documentazione;
- complessità di deployment;
- costo delle migrazioni.

## Versioning non sostituisce disciplina sulla compatibilità

Anche quando esiste il versioning, breaking change frequenti sono costose.

Supportare contemporaneamente:

- v1;
- v2;
- v3;
- v4;

può creare un notevole costo ingegneristico.

Preferire l'evoluzione compatibile quando ragionevole.

Creare un nuovo contratto major quando l'incompatibilità è realmente necessaria.

## Deprecazione

La rimozione di una vecchia versione dell'API dovrebbe essere un evento gestito del lifecycle.

Un processo utile comprende:

1. pubblicare il sostituto;
2. documentare la migrazione;
3. annunciare la deprecazione;
4. garantire un ragionevole periodo di convivenza;
5. osservare l'utilizzo residuo;
6. contattare consumer importanti quando possibile;
7. ritirare la vecchia versione soltanto dopo la finestra di migrazione.

Versioning senza politica di retirement produce superfici legacy permanenti.

## L'indipendenza dei client conta

La compatibilità diventa più importante quanto più i consumer sono indipendenti.

Una API privata usata da una singola applicazione strettamente coordinata può talvolta tollerare modifiche sincronizzate.

Una API pubblica usata da terze parti sconosciute non può assumere deployment sincronizzati.

Anche le API interne beneficiano dal trattare i consumer come client che evolvono indipendentemente.

Questo riduce l'accoppiamento organizzativo.

## Filtering, sorting e pagination interagiscono

Questi aspetti non possono essere progettati indipendentemente.

Un cursor creato per:

`status=active&sort=-created_at`

normalmente non dovrebbe essere riutilizzato per:

`status=archived&sort=name`

Il token di continuazione appartiene a una specifica definizione dell'attraversamento.

Allo stesso modo, cambiare le regole di sorting tra una richiesta e la successiva può invalidare le assunzioni della pagination.

Il contratto dell'API deve rendere chiare queste interazioni.

## Sicurezza e complessità delle query

Query molto flessibili possono diventare una superficie di attacco o di esaurimento delle risorse.

Possibili problemi:

- page size illimitato;
- sorting arbitrario e costoso;
- filtri che non sfruttano indici;
- result set enormi;
- combinazioni che generano query costose.

Le API dovrebbero generalmente definire:

- page size massimo;
- campi ordinabili consentiti;
- filtri consentiti;
- regole di validazione;
- rate limit.

La flessibilità richiede confini operativi.

## Errori comuni

### “La pagination è un problema del frontend”

No.

Protegge risorse server, rete e client ed è parte del contratto pubblico.

### “Offset pagination è sbagliata”

Troppo assoluto.

Può essere perfettamente appropriata per dataset piccoli o stabili e UI con pagine numerate.

### “Cursor pagination è sempre migliore”

No.

Scambia la semplicità del salto arbitrario con migliori caratteristiche di traversal e scalabilità in certi workload.

### “Un cursor è soltanto un page number codificato”

Modello mentale errato.

Rappresenta stato di continuazione.

### “Aggiungere pagination dopo non è breaking perché non ho rimosso campi”

Errato.

Cambiare un endpoint da collection completa a collection parziale può rompere il comportamento dei client.

### “Aggiungere un campo non può mai rompere un client”

Troppo assoluto.

Client ben progettati dovrebbero tollerare aggiunte compatibili quando il contratto lo prevede, ma la compatibilità reale dipende dalle regole di serializzazione e dalle aspettative documentate.

### “Se lo schema JSON è ancora valido, il cambiamento è compatibile”

No.

Il comportamento semantico può rompere i consumer senza cambiare la struttura.

### “Versionare ogni deployment”

No.

Si versiona il contratto pubblico quando l'evoluzione incompatibile lo richiede, non la release dell'implementazione.

## Risposta da colloquio

Per le collection progetto filtering, sorting e pagination come parte del contratto fin dall'inizio.

Offset pagination è semplice e utile quando serve accesso arbitrario alle pagine, ma può diventare costosa e instabile su dataset molto dinamici. Cursor pagination è spesso più adatta ai grandi feed perché continua da una posizione stabile dell'ordinamento anziché saltare ripetutamente righe.

Per l'evoluzione dell'API distinguo compatibilità strutturale e compatibilità semantica. Rimuovere o rinominare campi è chiaramente breaking, ma anche cambiare il significato di un campo esistente o trasformare silenziosamente una collection non paginata in una paginata può rompere i client.

Preferisco evoluzioni backwards-compatible quando possibile. Quando è necessario un contratto incompatibile introduco una versione esplicita e fornisco un percorso di migrazione e deprecazione invece di costringere tutti i client ad aggiornarsi contemporaneamente.

## Esercizi per lo studio successivo

1. Confronta offset e cursor pagination per un social feed con frequenti inserimenti.
2. Progetta la pagination di una tabella amministrativa nella quale gli utenti devono saltare direttamente alla pagina 100.
3. Definisci un sorting deterministico per una collection nella quale molte righe condividono lo stesso timestamp.
4. Classifica dieci modifiche proposte all'API come probabilmente compatibili o breaking.
5. Trova tre esempi di breaking change semantiche che non modificano i nomi dei campi JSON.
6. Progetta la migrazione da `/api/v1/orders` a una v2 incompatibile.
7. Decidi se un total count esatto vale il relativo costo operativo su un dataset da un miliardo di righe.
8. Progetta limiti di page size e sorting che impediscano query abusive.
9. Spiega perché i client non dovrebbero interpretare il contenuto di un cursor opaco.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- filtering tramite query parameter;
- sorting lato server;
- pagination page/limit;
- pagination offset/limit;
- cursor-based pagination;
- prefissi di versione come `/api/v1`;
- necessità di preservare i vecchi client durante evoluzioni API breaking.

Il materiale pubblico raffina quel modello:

- la pagination viene trattata come parte del contratto pubblico originale;
- cursor pagination viene modellata come stato di continuazione anziché hash di una pagina;
- viene reso esplicito l'ordinamento deterministico;
- i total count vengono considerati potenzialmente costosi;
- filtering, sorting e pagination vengono progettati insieme;
- backwards compatibility comprende il comportamento semantico, non soltanto la forma della risposta;
- versioning viene trattato come uno strumento per evoluzioni incompatibili e non come prefisso obbligatorio per ogni API;
- deprecazione e convivenza delle versioni entrano nel lifecycle dell'API.
