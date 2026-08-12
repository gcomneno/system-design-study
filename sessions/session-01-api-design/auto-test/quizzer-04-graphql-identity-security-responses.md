# Quizzer 04 Responses – Sessione 01: GraphQL, Identity & API Security

## Risposte corrette

1A 2B 3B 4B 5B 6A 7A 8A 9B 10B 11A 12A 13B 14A 15A 16A 17B 18A 19A 20A 21A 22A 23A 24A 25A 26A 27A 28A

## Correzione ragionata

### 1A — Client-controlled response shape

GraphQL è particolarmente interessante quando consumer differenti necessitano viste differenti di dati collegati.

Non elimina automaticamente:

- authentication;
- authorization;
- backend complexity;
- database cost.

La sua flessibilità deve risolvere un problema reale.

### 2B — Request error

Un documento sintatticamente non valido non può procedere alla normale execution.

È quindi un request error.

La risposta GraphQL contiene informazioni sull'errore senza normale `data` risultante dall'esecuzione.

### 3B — Partial data

Un execution error può colpire un field senza rendere inutilizzabile necessariamente ogni sibling field.

GraphQL può quindi restituire:

- `data` parziale;
- `errors`.

La nullability dello schema influenza la propagazione dell'errore.

### 4B — GraphQL e HTTP sono livelli distinti

GraphQL definisce response ed execution semantics.

HTTP definisce transport semantics.

Per questo:

“GraphQL restituisce sempre 200”

è una semplificazione sbagliata.

Il comportamento HTTP va considerato nel contratto GraphQL-over-HTTP implementato.

### 5B — N+1

Una singola richiesta GraphQL client-facing può produrre molte chiamate backend.

Il problema classico è:

1 query per la collection
+
N query per relazioni degli N elementi.

Mitigazioni includono batching e request-scoped loader.

### 6A — Shallow può essere costoso

Una query con depth 1 può chiedere:

100.000 record

oppure attivare un resolver costosissimo.

Depth limiting è utile ma deve essere affiancato da:

- pagination;
- complexity control;
- resource limits.

### 7A — OAuth 2.0 = delegated authorization

OAuth 2.0 permette a un client di ottenere autorità limitata verso protected resources.

Non va confuso automaticamente con:

- login;
- identity;
- JWT;
- SSO.

### 8A — OpenID Connect

OpenID Connect costruisce un identity layer sopra OAuth 2.0.

Serve a standardizzare authentication dell'end user e comunicazione dell'identità al relying party.

### 9B — Audience e purpose differenti

Access token:

- destinato al resource server;
- concede accesso alle risorse.

ID Token:

- destinato al relying party/client OIDC;
- comunica informazioni sull'identità autenticata.

Non sono genericamente intercambiabili.

### 10B — JWT è un formato

JWT trasporta claim.

La sicurezza deriva dal protocollo e dalla validazione corretta.

Il consumer può dover controllare:

- signature;
- issuer;
- audience;
- expiration;
- token purpose.

Decodificare non significa validare.

### 11A — Signed non significa encrypted

Una firma protegge integrità/autenticità.

Non rende automaticamente confidenziale il payload.

Claim sensibili non diventano segreti soltanto perché il token è firmato.

### 12A — Refresh token = autorità longeva

Un refresh token può permettere di ottenere nuovi access token.

Per questo una sua compromissione può avere conseguenze più durature rispetto al furto di un access token molto breve.

### 13B — Replay detection

Con rotation:

refresh A
→ nuovo refresh B
→ A invalidato.

Il riutilizzo successivo di A può segnalare che una copia rubata è stata riutilizzata.

### 14A — RBAC

RBAC struttura l'autorità tramite:

principal
→ role
→ permission.

È efficace quando responsabilità e ruoli organizzativi sono relativamente stabili.

### 15A — ABAC e attributi

ABAC è utile quando il risultato dipende da attributi quali:

- tenant;
- department;
- clearance;
- resource owner;
- device trust;
- time.

Evita di creare un ruolo per ogni combinazione possibile.

### 16A — ACL resource-centric

Una ACL risponde naturalmente a:

> Chi può accedere a questa specifica risorsa?

È comune nei sistemi di:

- file;
- document sharing;
- repository;
- calendari.

### 17B — Claim come input

`role=admin` dentro un token validato può essere un dato fidato.

Ma la policy deve ancora verificare:

- quale action;
- quale resource;
- quale tenant;
- quale stato;
- quale context.

Claim ≠ authorization decision.

### 18A — Scope non significa accesso universale

`orders:write` può indicare autorità delegata generale.

L'applicazione deve ancora verificare, per esempio:

- ownership;
- tenant;
- order state;
- business action.

Scope e resource-level authorization sono complementari.

### 19A — Broken object-level authorization

L'identificatore cambia ma manca la verifica sullo specifico oggetto.

Il server deve controllare che il principal possa accedere proprio a invoice 101.

Nascondere gli ID non è una difesa.

### 20A — Property-level authorization

Accedere a un object non implica poter vedere ogni property.

La API deve controllare esplicitamente quali field possono essere:

- letti;
- scritti;
- modificati.

### 21A — Server-side enforcement

Il frontend non è il security boundary.

Il client può:

- modificare JavaScript;
- chiamare direttamente la API;
- costruire richieste manuali.

L'autorizzazione deve essere applicata dal backend.

### 22A — CORS è browser policy

CORS determina come browser e origin interagiscono.

Non impedisce a:

- curl;
- script server-side;
- bot;
- servizi backend

di inviare richieste HTTP.

Per questo non sostituisce authentication e authorization.

### 23A — Cookie automatici e CSRF

Nel classico scenario CSRF il browser allega automaticamente una credenziale valida a una richiesta che l'utente non intendeva effettuare.

I cookie di sessione sono l'esempio tipico.

Il threat model cambia quando le credenziali non vengono inviate automaticamente.

### 24A — XSS dentro il trusted origin

Con XSS, il codice dell'attaccante può essere eseguito nel contesto dell'applicazione.

Può quindi:

- leggere dati accessibili allo script;
- effettuare richieste;
- manipolare la UI;
- abusare di sessioni o token accessibili.

### 25A — Rate limiting è un livello

Rate limiting limita frequenza o consumo secondo una policy.

È utile contro:

- abuse;
- brute force;
- resource exhaustion.

Ma un grande DDoS può richiedere protezione a:

- edge;
- CDN;
- network;
- infrastructure provider.

### 26A — SSRF

Quando il server effettua richieste verso URL controllabili dall'utente, l'attaccante può tentare di raggiungere:

- localhost;
- reti private;
- metadata endpoint cloud;
- sistemi interni.

Questo è il classico rischio SSRF.

### 27A — Trust boundary

Una API di terze parti non è magicamente fidata.

Può:

- essere compromessa;
- cambiare formato;
- restituire payload enormi;
- rallentare;
- rispondere con dati inattesi.

Servono quindi validazione e limiti anche sui dati downstream.

### 28A — Defense in depth

La sicurezza nasce da controlli complementari.

Per esempio:

TLS
→ authentication
→ authorization
→ validation
→ resource limits
→ monitoring.

Se un livello fallisce, gli altri possono ancora ridurre l'impatto.

Nessun singolo prodotto è sufficiente.

## Punti da ricordare

### GraphQL

Schema forte e client-selected fields sono vantaggi.

Ma bisogna gestire:

- N+1;
- pagination;
- complexity;
- partial failures;
- field-level authorization;
- caching.

### OAuth e OpenID Connect

OAuth 2.0:

- delegated authorization.

OpenID Connect:

- authentication/identity layer.

### Token

Access token:

- resource access.

ID Token:

- authenticated identity verso il relying party.

JWT:

- formato.

Bearer:

- possession model.

Questi termini non sono sinonimi.

### Authorization

La decisione è concettualmente:

principal
+
action
+
resource
+
context
→ allow / deny.

RBAC, ABAC e ACL possono convivere.

Claim, role e scope sono input, non automaticamente il risultato.

### CORS

Browser cross-origin policy.

Non è API authentication.

### CSRF

Sfrutta credenziali che il browser allega automaticamente.

### XSS

Esegue contenuto attacker-controlled nel trusted browser context.

### Rate limiting

Protegge risorse e limita abuse.

Non equivale a una strategia DDoS completa.

### SSRF

Il server viene indotto a effettuare richieste verso destinazioni non previste.

### Defense in depth

Nessuna singola tecnologia rende sicuro il sistema.

Servono più boundary e controlli complementari.

## Versione sintetica da colloquio

In GraphQL distinguo request error ed execution error: questi ultimi possono produrre dati parziali, quindi non riduco la semantica GraphQL alla regola “HTTP 200 sempre”. Controllo inoltre N+1, pagination, query complexity e authorization field-level.

Per identity distinguo chiaramente OAuth 2.0, OpenID Connect, access token, ID Token e JWT. OAuth riguarda principalmente delegated authorization, OIDC aggiunge authentication e JWT è soltanto un formato che deve essere validato nel corretto trust context.

Per authorization considero principal, action, resource e context. RBAC, ABAC e ACL sono modelli complementari, mentre claim e scope sono input alla policy.

Per API security uso defense in depth. CORS non sostituisce access control, CSRF e XSS hanno threat model differenti, rate limiting non è una soluzione DDoS completa e ogni integrazione o URL controllabile dall'esterno rappresenta un trust boundary da proteggere.
