# Unità 07 – Semantica HTTP ed errori

[English](07-http-semantics-errors.md) | [Italiano](07-http-semantics-errors.it.md)

## Obiettivo didattico

Progettare operazioni HTTP nelle quali metodi, comportamento dei retry, risposte di successo e risposte di errore comunichino semantiche chiare e prevedibili.

L'obiettivo non è memorizzare gli status code.

L'obiettivo è capire cosa i client possono dedurre dal contratto del protocollo.

## Metodi safe

Un metodo è safe quando la sua semantica definita è di sola lettura.

Gli esempi classici sono:

- GET;
- HEAD.

Una richiesta safe non dovrebbe chiedere al server di modificare lo stato applicativo.

Questo non significa che il server non produca letteralmente alcun side effect.

Può comunque:

- registrare la richiesta nei log;
- aggiornare metriche;
- popolare cache;
- registrare diagnostica.

Questi effetti incidentali non cambiano la semantica intenzionale richiesta dal client.

## Metodi idempotenti

Un metodo è idempotente quando ripetere la stessa richiesta produce lo stesso effetto intenzionale dell'eseguirla una sola volta.

Esempi importanti:

- GET;
- HEAD;
- PUT;
- DELETE.

L'idempotenza conta quando il client non sa se una richiesta sia riuscita.

Supponiamo:

1. il client invia un PUT;
2. il server lo applica;
3. la connessione fallisce prima dell'arrivo della risposta;
4. il client non sa se l'operazione sia stata completata.

Poiché PUT è idempotente per definizione, ripetere la stessa operazione intenzionale può essere sicuro a livello di semantica HTTP.

La risposta del retry non deve necessariamente essere identica.

La proprietà importante è l'effetto finale intenzionale.

## Idempotenza non significa osservazioni identiche

Una richiesta idempotente può comunque:

- creare un'altra riga di log;
- aggiornare metriche;
- produrre un timestamp differente;
- restituire una risposta differente perché un altro attore ha modificato la risorsa.

L'idempotenza riguarda l'effetto intenzionale della richiesta stessa.

## POST

POST chiede alla risorsa target di elaborare il contenuto inviato secondo la semantica propria di quella risorsa.

Usi comuni:

- creare una risorsa identificata dal server;
- inviare un comando;
- appendere dati;
- avviare un'elaborazione.

POST non è idempotente per default.

Consideriamo:

`POST /orders`

Se la prima richiesta crea l'ordine A ma la risposta viene persa, ripetere ciecamente il POST può creare l'ordine B.

Le applicazioni che richiedono creazione retry-safe introducono spesso un meccanismo applicativo come:

- idempotency key;
- identificatore della richiesta client;
- record di deduplicazione.

Semantica del metodo HTTP e garanzie applicative di retry sono problemi distinti.

## PUT

PUT richiede che lo stato della risorsa target venga creato o sostituito secondo la rappresentazione fornita.

Per esempio:

`PUT /users/42`

significa che il client indirizza una risorsa target conosciuta.

Se ripetuto con la stessa rappresentazione intenzionale, PUT rimane idempotente a livello HTTP.

Un PUT riuscito può:

- creare la risorsa target, se consentito;
- sostituire lo stato di una risorsa target esistente.

PUT non dovrebbe essere trattato semplicemente come sinonimo di “update”.

La sua semantica riguarda lo stato della risorsa target.

## PATCH

PATCH applica un insieme di modifiche a una risorsa esistente.

A differenza di PUT, PATCH non è definito come idempotente.

Il comportamento idempotente di una specifica operazione PATCH dipende dal documento di patch e dalla semantica applicativa.

Per esempio, concettualmente:

`set phone = X`

può essere progettato come idempotente.

Ma:

`increment balance by 10`

non è idempotente se ripeterlo applica l'incremento due volte.

I client non devono quindi dedurre la sicurezza del retry semplicemente dal fatto che il metodo sia PATCH.

## DELETE

DELETE è idempotente rispetto all'effetto intenzionale.

Eliminare due volte la stessa risorsa non significa che entrambe le risposte debbano essere identiche.

La prima richiesta può riuscire mentre una successiva può indicare che la risorsa non è più presente.

Lo stato finale richiesto rimane che l'associazione rappresentata dalla risorsa target sia rimossa.

## Status code di successo

### 200 OK

Usare 200 quando la richiesta riesce e la risposta contiene dati appropriati all'operazione.

È una risposta generica di successo, non l'unico status di successo.

### 201 Created

Usare 201 quando l'elaborazione della richiesta crea una o più risorse.

Quando appropriato, la risposta può identificare la risorsa primaria creata tramite `Location`.

Esempio tipico:

`POST /orders`

crea un nuovo ordine identificato dal server.

### 202 Accepted

Usare 202 quando la richiesta è stata accettata per l'elaborazione ma questa non è necessariamente terminata.

È utile per workflow asincroni.

Una risposta 202 non dimostra che l'operazione di business avrà infine successo.

### 204 No Content

Usare 204 quando la richiesta è stata completata con successo e non esiste contenuto da inviare nella risposta.

Casi tipici includono update o delete riusciti nei quali il client non necessita di una rappresentazione.

Una risposta 204 non può contenere response content.

## Status code per errori del client

### 400 Bad Request

400 rappresenta un problema nella richiesta che impedisce al server di elaborarla secondo sintassi o framing attesi.

Un uso tipico nelle API è contenuto della richiesta malformato.

Non usare 400 come contenitore universale per qualsiasi condizione di business causata dal client.

### 401 Unauthorized

Nonostante il nome storico, 401 riguarda l'autenticazione HTTP.

Usarlo quando credenziali di autenticazione valide per la risorsa protetta mancano o non sono state stabilite correttamente.

Una API protetta restituisce comunemente 401 quando:

- le credenziali mancano;
- un bearer token non è valido;
- l'autenticazione deve essere effettuata nuovamente.

Modello mentale:

> L'autenticazione non è stata stabilita con successo.

### 403 Forbidden

403 significa che il server comprende la richiesta ma rifiuta di soddisfarla.

In una normale API autenticata spesso significa:

> So chi sei, ma non puoi fare questa cosa.

403 è però più ampio di un singolo scenario RBAC.

Il server può anche restituire deliberatamente 404 quando non vuole rivelare l'esistenza di una risorsa proibita.

### 404 Not Found

404 significa che l'origin server non ha trovato una rappresentazione corrente della risorsa target oppure non vuole rivelare che ne esista una.

La seconda possibilità è importante nelle API sensibili alla sicurezza.

Un 404 quindi non dimostra sempre che l'oggetto sottostante non esista letteralmente.

### 409 Conflict

409 indica che la richiesta è in conflitto con lo stato corrente della risorsa target.

Esempi:

- stato concorrente incompatibile;
- transizione non compatibile con lo stato corrente;
- operazione impossibile a causa di un conflitto di stato.

Non ridurre 409 a “email duplicata”.

Che un input duplicato sia rappresentato bene da 409 dipende dal resource model e dal contratto dell'API.

### 422 Unprocessable Content

422 significa che il server comprende il content type e la sintassi della richiesta è valida, ma non può elaborare le istruzioni contenute.

È spesso utile per input semanticamente non validi.

Esempio:

- il JSON è sintatticamente corretto;
- i campi possono essere interpretati;
- l'operazione richiesta non è semanticamente accettabile.

La distinzione concreta tra 400 e 422 deve essere documentata e applicata con coerenza.

### 429 Too Many Requests

429 indica che il client ha inviato troppe richieste secondo la policy di rate limiting del server.

La risposta può fornire informazioni su quando riprovare.

È il server a decidere come conteggiare le richieste.

Possibili dimensioni:

- identità autenticata;
- token;
- IP;
- risorsa;
- endpoint;
- policy dell'intero servizio.

## Status code per errori server

### 500 Internal Server Error

500 rappresenta una condizione inattesa che ha impedito al server di soddisfare la richiesta.

Non usare 500 per errori noti di validazione del client.

Una risposta 500 dovrebbe inoltre evitare di esporre:

- stack trace;
- credenziali database;
- path interni;
- segreti;
- dettagli implementativi.

## Le risposte di errore richiedono un contratto applicativo

Gli status code HTTP comunicano semantica generale del protocollo.

Le applicazioni spesso richiedono ulteriori informazioni.

Una rappresentazione utile dell'errore può includere:

- codice applicativo stabile;
- messaggio leggibile;
- dettagli di validazione per campo;
- identificatore di correlazione o trace;
- riferimento alla documentazione quando utile.

Esempio concettuale:

`code = EMAIL_ALREADY_USED`

`message = An account already uses this email`

Il codice machine-readable dovrebbe rimanere stabile anche se cambia la formulazione del messaggio umano.

## Non trasformare ogni condizione di business in un nuovo status HTTP

Gli status code HTTP descrivono categorie di risultato a livello di protocollo.

Le condizioni specifiche del dominio normalmente appartengono alla rappresentazione della risposta.

Per esempio, diverse regole di business possono condividere legittimamente lo stesso status HTTP usando codici applicativi differenti.

Questo mantiene comprensibile il livello HTTP senza perdere precisione sul dominio.

## Semantica dei retry

Prima di ripetere una richiesta fallita chiedersi:

1. Il metodo HTTP è idempotente?
2. Questa specifica operazione è realmente retry-safe?
3. La richiesta originale potrebbe aver già prodotto un side effect?
4. Il client può rilevare elaborazioni duplicate?
5. Il failure è transitorio?
6. Il server ha fornito indicazioni sul retry?

La logica di retry appartiene alla semantica dell'operazione, non semplicemente al fatto che sia avvenuto un errore.

## Ambiguità dei timeout

Un timeout non dimostra il fallimento dell'operazione.

Esempio:

1. il client invia `POST /payments`;
2. il server elabora l'addebito;
3. la risposta viene persa;
4. il client va in timeout.

Il client sa soltanto di non aver ricevuto la risposta.

Non sa se l'addebito sia avvenuto.

Questa ambiguità è un problema centrale dei sistemi distribuiti.

Possibili mitigazioni:

- idempotency key;
- identificatori dell'operazione;
- endpoint di status lookup;
- deduplicazione;
- riconciliazione.

## Conditional request e lost update

Le modifiche concorrenti creano un altro failure mode.

Consideriamo:

1. client A legge la versione 10;
2. client B modifica la risorsa portandola alla versione 11;
3. client A scrive partendo dalla vecchia versione 10.

Le conditional request possono impedire di sovrascrivere stato più recente.

Meccanismi come ETag più `If-Match` consentono al client di esprimere:

> Applica la mia modifica soltanto se la risorsa è ancora la versione che ho osservato.

È particolarmente utile per richieste che modificano stato, compresi alcuni workflow PATCH.

## Mappa pratica degli status code

| Situazione | Status tipico |
|---|---|
| Richiesta riuscita con contenuto nella risposta | 200 |
| Risorsa creata con successo | 201 |
| Accettata per elaborazione asincrona | 202 |
| Richiesta riuscita senza contenuto nella risposta | 204 |
| Richiesta malformata | 400 |
| Autenticazione assente o non valida | 401 |
| Richiesta compresa ma proibita | 403 |
| Risorsa assente o intenzionalmente nascosta | 404 |
| Conflitto con lo stato corrente | 409 |
| Contenuto semanticamente non elaborabile | 422 |
| Rate limit superato | 429 |
| Errore server inatteso | 500 |

Questa tabella è una guida di design, non sostituisce la specifica HTTP o il contratto della singola API.

## Errori comuni

### “401 significa autenticato ma non autorizzato”

Errato.

Il caso tipico appartiene a 403.

### “403 significa che l'utente non esiste”

Modello mentale errato.

403 riguarda il rifiuto di soddisfare una richiesta compresa.

### “Ogni errore di validazione deve essere 422”

No.

L'API deve avere una distinzione coerente e documentata tra richiesta malformata, validazione semantica e conflitti del dominio.

### “PATCH è idempotente perché aggiorna soltanto una parte”

Errato.

Modifica parziale e idempotenza sono proprietà indipendenti.

### “DELETE deve restituire la stessa risposta ogni volta”

Errato.

L'idempotenza riguarda l'effetto intenzionale, non l'identità delle risposte.

### “Timeout significa che il server non ha fatto nulla”

Pericoloso.

L'operazione può essere terminata prima del failure di comunicazione.

### “Ritento ogni 500”

Pericoloso.

La policy di retry deve considerare semantica dell'operazione, tipo di failure e backoff.

## Risposta da colloquio

Progetto API HTTP in modo che semantica dei metodi e comportamento dei retry siano espliciti.

GET e HEAD sono safe, mentre PUT, DELETE e i metodi safe sono idempotenti. POST non è idempotente per default e PATCH non è garantito idempotente; la sicurezza del retry dipende quindi dall'operazione concreta.

Per gli status code uso il significato di protocollo più specifico adatto al risultato: 201 per risorse create, 204 per successo senza contenuto, 401 quando l'autenticazione manca o non è valida, 403 quando il server rifiuta una richiesta compresa, 409 per conflitti con lo stato corrente, 422 per contenuto semanticamente non elaborabile e 429 per rate limiting.

Soprattutto tratto i timeout di rete come ambigui. Per operazioni di business non idempotenti come i pagamenti aggiungo idempotenza o riconciliazione a livello applicativo invece di assumere che il retry sia sicuro.

## Esercizi per lo studio successivo

1. Spiega perché ritentare PUT è fondamentalmente diverso dal ritentare ciecamente POST.
2. Progetta un meccanismo di idempotenza per `POST /payments`.
3. Decidi se cinque diversi errori di validazione debbano restituire 400, 409 o 422 e giustifica il contratto.
4. Spiega un caso legittimo in cui una API restituisce 404 invece di 403.
5. Progetta una API di export asincrono usando 202 e una risorsa di stato.
6. Modella un problema di lost update e risolvilo usando ETag e `If-Match`.
7. Spiega perché un DELETE idempotente può restituire risposte differenti nei retry.
8. Progetta un contratto JSON stabile per gli errori con informazioni machine-readable e human-readable.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- metodi HTTP per operazioni in stile CRUD;
- GET safe e idempotente;
- POST per creazione;
- PUT e PATCH per modifica;
- DELETE;
- principali famiglie di status code;
- 200, 201, 204, 400, 401, 404 e 500.

Il materiale pubblico estende e raffina intenzionalmente quel modello:

- safe e idempotent vengono trattati come proprietà differenti;
- l'idempotenza di PUT viene separata dall'identità delle risposte;
- PATCH non viene assunto idempotente;
- vengono resi espliciti ambiguità dei timeout e retry semantics;
- 401 e 403 vengono distinti accuratamente;
- vengono aggiunti 409, 422 e 429;
- 202 viene incluso per elaborazioni asincrone;
- gli status code HTTP vengono separati dai codici di errore applicativi;
- vengono introdotte le conditional request come difesa contro i lost update.
