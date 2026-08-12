# Quizzer 02 Responses – Sessione 01: HTTP API Design

## Risposte corrette

1A 2B 3B 4B 5B 6B 7A 8B 9B 10B

## Correzione ragionata

### 1A — Autenticazione versus autorizzazione

Autenticazione significa verificare o stabilire l'identità del caller.

Autorizzazione significa decidere se quell'identità può eseguire la specifica azione sulla specifica risorsa.

Modello mentale:

- authentication → chi sei?
- authorization → puoi fare questa cosa?

Le due fasi sono collegate ma non equivalenti.

### 2B — POST /orders

Se il client non conosce ancora l'identificatore finale della nuova risorsa, una scelta tipica è:

`POST /orders`

Il server elabora la richiesta e può creare un nuovo ordine con identificatore assegnato server-side.

`PUT /orders/{id}` è invece naturale quando il client conosce e indirizza già la risorsa target.

### 3B — PATCH /users/42

PATCH è adatto a descrivere una modifica parziale della risorsa.

Qui vogliamo modificare soltanto:

`phone`

senza sostituire l'intera rappresentazione dell'utente.

Importante:

PATCH non è automaticamente idempotente.

L'idempotenza dipende dalla semantica concreta della patch.

### 4B — PUT è idempotente

PUT è idempotente secondo la semantica HTTP.

Ripetere la stessa richiesta intenzionale non deve produrre una nuova risorsa distinta a ogni retry.

Questo non significa che:

- i log siano identici;
- i timestamp siano identici;
- la risposta debba essere letteralmente uguale.

L'idempotenza riguarda l'effetto intenzionale sullo stato della risorsa.

### 5B — POST può produrre due ordini

POST non è idempotente per default.

Se:

1. il server crea l'ordine;
2. la risposta viene persa;
3. il client ripete il POST;

il server può legittimamente elaborare una seconda creazione.

Per operazioni dove i retry devono essere sicuri servono meccanismi applicativi, per esempio:

- idempotency key;
- request identifier;
- deduplicazione;
- reconciliation.

### 6B — 403 Forbidden

Il token è valido e quindi l'identità è stata stabilita.

Il problema è che il principal non possiede l'autorità richiesta.

Il modello tipico è:

- 401 → autenticazione mancante o non valida;
- 403 → richiesta compresa ma non autorizzata.

In alcuni sistemi sensibili può essere scelto 404 per non rivelare l'esistenza della risorsa, ma non è la risposta migliore nello scenario presentato.

### 7A — 401 Unauthorized

Su un endpoint protetto, l'assenza delle credenziali significa che l'autenticazione non è stata stabilita.

Il nome storico `Unauthorized` può confondere, ma 401 riguarda l'autenticazione HTTP.

403 riguarda invece un rifiuto dopo che la richiesta è stata compresa e l'identità può essere già nota.

### 8B — 409 Conflict

Una email già registrata può ragionevolmente essere modellata come conflitto con lo stato corrente del sistema.

Non è una regola universale:

la scelta tra 409, 422 o altre rappresentazioni dipende dal contratto dell'API.

Fra le alternative proposte, 409 è però la più difendibile.

Le altre sono chiaramente errate:

- JSON sintatticamente malformato non è il caso tipico per 422;
- input client non valido non dovrebbe produrre 500;
- rate limiting ha uno status specifico: 429.

### 9B — offset pagination su dataset dinamico

Offset pagination è semplice ma può degradare quando:

- gli offset diventano molto grandi;
- nuovi record vengono inseriti;
- record precedenti vengono eliminati.

Durante la navigazione il client può osservare:

- elementi duplicati;
- elementi saltati;
- query più costose.

Cursor pagination è spesso più adatta a feed grandi e molto dinamici perché continua rispetto a un ordinamento stabile.

Non è però universalmente migliore.

### 10B — rinominare email rompe il contratto

Cambiare:

`email`

in:

`contact_email`

senza periodo di transizione rompe i client che dipendono dal vecchio campo.

È una breaking change strutturale evidente.

Aggiungere invece:

- un campo opzionale;
- un endpoint opzionale;
- un filtro opzionale;

è spesso compatibile, purché il contratto e i client prevedano correttamente l'evoluzione.

## Punti da ricordare

### Authentication versus authorization

Authentication:

> Who are you?

Authorization:

> May you perform this action on this resource?

### Safe versus idempotent

Safe:

- GET;
- HEAD.

Idempotent:

- GET;
- HEAD;
- PUT;
- DELETE.

POST:

- non idempotente per default.

PATCH:

- può essere progettato idempotente;
- non è garantito idempotente dal metodo stesso.

### Timeout

Timeout significa:

> non ho ricevuto la risposta.

Non significa:

> il server non ha eseguito l'operazione.

Questa distinzione è fondamentale per pagamenti, ordini e altri side effect.

### Status code

- 400 → request malformata;
- 401 → autenticazione mancante/non valida;
- 403 → policy nega l'accesso;
- 404 → risorsa non trovata o intenzionalmente nascosta;
- 409 → conflitto con lo stato corrente;
- 422 → contenuto sintatticamente valido ma semanticamente non elaborabile;
- 429 → rate limit;
- 500 → failure server inatteso.

### Pagination

Offset:

- semplice;
- navigazione arbitraria;
- può degradare su dataset grandi/dinamici.

Cursor:

- buon traversal di dataset dinamici;
- ordinamento stabile;
- meno naturale per saltare direttamente a una pagina arbitraria.

### API evolution

La compatibilità non riguarda soltanto il JSON schema.

Anche cambiare:

- significato di un field;
- ordinamento;
- semantica;
- comportamento di pagination;

può rompere un client esistente.

## Versione sintetica da colloquio

Quando progetto una HTTP API distinguo chiaramente authentication e authorization, uso i metodi secondo la loro semantica e considero l'idempotenza fondamentale per i retry.

PUT e DELETE sono idempotenti, POST normalmente no e PATCH dipende dall'operazione concreta. Un timeout non dimostra che l'operazione sia fallita, quindi per side effect sensibili uso idempotency key, deduplicazione o reconciliation.

Uso status code coerenti, scelgo pagination in base al workload e tratto anche i cambiamenti semantici come potenziali breaking change, non soltanto la rimozione di campi.
