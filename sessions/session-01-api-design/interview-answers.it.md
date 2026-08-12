# Risposte da colloquio – Sessione 01: API Design

[English](interview-answers.md) | [Italiano](interview-answers.it.md)

Questo interview bank consolida le principali decisioni di design coperte dalle Unità 01–12.

L'obiettivo non è memorizzare gli script parola per parola.

L'obiettivo è saper spiegare ragionamento, trade-off e failure mode dietro ogni risposta.

## 1. Cos'è una API?

Una API è un contratto tra sistemi.

Definisce:

- quali operazioni può richiedere un client;
- quali dati deve fornire;
- quali risposte può aspettarsi;
- quali errori possono verificarsi;
- quali garanzie comportamentali e vincoli si applicano.

Una buona API nasconde i dettagli implementativi ed espone un confine stabile, coerente e comprensibile.

L'idea centrale è che una API non è semplicemente un endpoint. È un contratto che consente alle implementazioni di client e server di evolvere indipendentemente rispettando una semantica concordata.

## 2. Come scegli il protocollo di una API?

Parto dal pattern di interazione, non dalla tecnologia che preferisco.

Mi chiedo:

- request/response oppure messaging asincrono?
- comunicazione unidirezionale o bidirezionale?
- browser-facing oppure service-to-service?
- bassa latenza oppure alto throughput?
- serve streaming?
- sono previste disconnessioni temporanee?
- servono schema forte e client generati?
- quale complessità operativa può sostenere il team?

HTTP è spesso il default per API client/server convenzionali.

WebSocket è adatto a comunicazione persistente e bidirezionale.

Messaging in stile AMQP è adatto a workflow asincroni e temporalmente disaccoppiati.

gRPC è adatto a RPC service-to-service fortemente tipizzate e streaming quando controllo entrambi i lati.

La cosa importante è far corrispondere il modello di comunicazione ai requisiti.

## 3. Qual è la differenza tra HTTP e HTTPS?

HTTP definisce la semantica applicativa di request e response.

HTTPS è HTTP trasportato tramite TLS.

TLS fornisce protezioni di trasporto come confidenzialità, integrità e autenticazione del peer all'interno del canale protetto.

HTTPS non autentica automaticamente l'utente applicativo e non corregge problemi di autorizzazione o vulnerabilità applicative.

Quindi considero HTTPS una necessaria protezione del trasporto, non un modello di sicurezza completo.

## 4. Quando useresti WebSocket?

Userei WebSocket quando l'applicazione necessita di un canale persistente e bidirezionale con basso overhead di interazione.

Esempi:

- collaborative editing;
- aggiornamenti di stato multiplayer;
- dashboard interattive;
- chat;
- eventi real-time server-driven dove entrambe le parti possono inviare messaggi.

Non sceglierei WebSocket soltanto perché qualcosa viene definito “real-time”.

Considererei anche reconnect, heartbeat, backpressure, rinnovo dell'autenticazione, fan-out e horizontal scaling.

## 5. Quando useresti messaging asincrono come AMQP?

Userei messaging asincrono quando producer e consumer beneficiano del disaccoppiamento temporale.

Esempi:

- elaborazione background;
- workflow degli ordini;
- notifiche;
- integration event;
- workload dove il producer non deve aspettare il risultato finale di business.

Il messaging cambia il failure model.

Delivery non significa automaticamente completamento del business e i retry possono produrre duplicati.

Per questo progetto consumer considerando idempotenza, redelivery, poison message e riconciliazione invece di assumere esecuzione business exactly-once.

## 6. Quando useresti gRPC?

Valuterei gRPC principalmente per comunicazione service-to-service quando controllo entrambi i lati e traggo beneficio da:

- contratto tipizzato esplicito;
- client generati;
- serializzazione efficiente;
- RPC unary e streaming;
- tooling forte attorno alle service definition.

Non lo sceglierei automaticamente per una API pubblica browser-first, dove API HTTP convenzionali sono spesso più semplici da esporre e debuggare.

## 7. Qual è la differenza pratica tra TCP e UDP?

TCP fornisce un byte stream affidabile e ordinato con gestione della connessione, ritrasmissione, flow control e congestion control.

UDP fornisce datagram indipendenti senza garanzie integrate di delivery, ordering o duplicate suppression.

La domanda di design importante non è semplicemente “affidabile versus veloce”.

È se dati mancanti o obsoleti siano preferibili rispetto all'attesa della ritrasmissione.

Voce, telemetria o gaming possono talvolta preferire freschezza rispetto alla delivery perfetta.

Evito anche di dire che HTTP significhi sempre TCP, perché HTTP/3 usa QUIC, che fornisce semantiche di trasporto affidabile sopra UDP.

## 8. Come progetti le risorse REST?

Modello concetti stabili del dominio invece di esporre tabelle database o nomi di remote procedure.

Preferisco identificatori resource-oriented come:

- `/products`;
- `/products/42`;
- `/orders/913`.

I metodi HTTP esprimono poi la semantica dell'interazione.

I nomi plurali sono una convenzione utile, non una legge di REST.

Evito anche di mappare ciecamente le relazioni ORM in URL profondamente annidati.

Il resource model pubblico deve riflettere come i client comprendono il dominio, non come avviene internamente la persistenza.

## 9. Cosa significa statelessness in REST?

Statelessness significa che ogni richiesta contiene le informazioni necessarie al server per comprendere quella interazione.

Il server non dovrebbe richiedere stato conversazionale nascosto derivante da richieste precedenti per interpretare quella corrente.

Questo migliora scalabilità e comportamento degli intermediari perché le richieste possono essere gestite indipendentemente.

Statelessness non significa che l'applicazione non memorizzi stato.

Risorse, database, sistemi di autenticazione e cache contengono ovviamente stato.

## 10. Qual è la differenza tra metodi HTTP safe e idempotenti?

Un metodo safe è definito read-only nella propria semantica richiesta.

GET e HEAD sono esempi tipici.

Un metodo idempotente può essere ripetuto con lo stesso effetto intenzionale dell'eseguirlo una sola volta.

GET, HEAD, PUT e DELETE sono idempotenti secondo la semantica HTTP.

POST non è idempotente per default.

PATCH non è garantito idempotente; dipende dalla specifica operazione di patch.

La distinzione è particolarmente importante quando avvengono retry dopo failure di rete ambigui.

## 11. Come gestiresti un timeout dopo la creazione di un pagamento?

Tratterei il risultato come sconosciuto.

Un timeout dimostra che il client non ha ricevuto una risposta.

Non dimostra che il server non abbia elaborato il pagamento.

Ritentare ciecamente un'operazione di pagamento non idempotente potrebbe addebitare due volte.

Progetterei quindi protezioni applicative come:

- idempotency key;
- identificatore stabile dell'operazione;
- deduplicazione;
- status lookup;
- riconciliazione.

È un problema di incertezza nei sistemi distribuiti, non semplicemente un errore HTTP.

## 12. Come progetti gli errori di una API?

Uso gli status code HTTP per la semantica generale del protocollo e codici applicativi stabili per condizioni specifiche del dominio.

Esempi:

- 400 per richieste malformate;
- 401 quando autenticazione manca o non è valida;
- 403 quando la policy rifiuta una richiesta compresa;
- 404 quando la risorsa è assente o intenzionalmente nascosta;
- 409 per conflitti con lo stato corrente;
- 422 per contenuto semanticamente non elaborabile;
- 429 per rate limiting;
- 500 per failure server inattesi.

Il body dell'errore deve fornire informazioni sufficienti al client legittimo senza esporre stack trace, credenziali o dettagli interni.

## 13. Offset pagination o cursor pagination?

Offset pagination è semplice e utile quando gli utenti devono navigare arbitrariamente tra le pagine.

Le debolezze emergono su dataset grandi o molto dinamici:

- offset elevati possono essere costosi;
- insert e delete possono spostare i confini delle pagine;
- i client possono osservare duplicati o elementi saltati.

Cursor pagination è spesso più adatta a feed grandi e dinamici perché il traversal continua da una posizione stabile dell'ordinamento.

Il trade-off è che salti arbitrari come “vai direttamente a pagina 847” diventano più difficili.

Nessuna strategia è universalmente migliore.

## 14. Come evolvi una API senza rompere i client?

Tratto la compatibilità come comportamentale oltre che strutturale.

Breaking change evidenti includono:

- rimuovere field;
- rinominare field;
- cambiare incompatibilmente i type;
- rendere obbligatorio un input opzionale.

Ma anche cambiare il significato di un field o trasformare silenziosamente una collection completa in una response parzialmente paginata può rompere i client.

Preferisco evoluzione backwards-compatible quando possibile.

Quando serve un contratto incompatibile introduco una versione esplicita e fornisco migrazione, deprecazione e periodo di convivenza.

## 15. Quando sceglieresti GraphQL?

Valuterei GraphQL quando i client richiedono response shape sostanzialmente differenti o dati fortemente collegati.

Può ridurre alcune forme di over-fetching e under-fetching perché i client selezionano i field necessari.

I trade-off includono:

- complessità dello schema;
- pattern N+1;
- controllo della query complexity;
- pagination;
- field-level authorization;
- diversa ergonomia del caching.

GraphQL ha valore quando questa flessibilità risolve un vero problema di prodotto, non semplicemente perché è di moda.

## 16. In cosa differiscono gli errori GraphQL dai normali errori HTTP?

Separo la semantica di esecuzione GraphQL dalla semantica del trasporto HTTP.

Un GraphQL request error può impedire completamente l'esecuzione, per esempio quando il documento non è sintatticamente valido o non supera la validation.

Un execution error avviene durante la risoluzione dei field.

In quel caso la response può contenere contemporaneamente `data` parziale e un array `errors`.

Per questo lo slogan “GraphQL restituisce sempre HTTP 200” è troppo semplicistico.

Il modello delle GraphQL response e il contratto GraphQL-over-HTTP scelto devono essere ragionati separatamente.

## 17. Cos'è il problema N+1 in GraphQL?

Una query client compatta può provocare molte query backend.

Per esempio:

1. recuperare 100 post;
2. risolvere separatamente ogni autore;
3. produrre 100 query database aggiuntive.

Il client ha effettuato una sola richiesta GraphQL, ma il server ha eseguito 101 accessi ai dati.

Mitigazioni tipiche includono batching, loader request-scoped, join, prefetching e caching.

GraphQL controlla la forma della risposta; non ottimizza automaticamente l'accesso backend.

## 18. Qual è la differenza tra autenticazione e autorizzazione?

L'autenticazione stabilisce chi o cosa sta effettuando la richiesta.

L'autorizzazione determina cosa può fare quel principal autenticato.

Per esempio:

- autenticazione: questo è l'utente 42;
- autorizzazione: l'utente 42 può leggere la fattura 100 ma non la fattura 101.

Una credenziale valida non implica permesso universale.

Il server deve ancora autorizzare azione e risorsa concrete.

## 19. OAuth 2.0 è un protocollo di autenticazione?

OAuth 2.0 è principalmente un authorization framework per accesso delegato.

Non deve essere trattato come un generico protocollo di login.

OpenID Connect aggiunge autenticazione standard dell'end user sopra OAuth 2.0.

Distinguo inoltre:

- access token: autorità destinata a un resource server;
- ID Token: informazioni sull'identità autenticata destinate al relying party OpenID Connect.

Usarli come intercambiabili crea problemi di sicurezza e interoperabilità.

## 20. Cos'è un JWT e cosa non garantisce?

JWT è un formato di token per trasportare claim.

Non significa automaticamente:

- OAuth;
- autenticazione;
- autorizzazione;
- confidenzialità;
- sicurezza.

Un JWT firmato protegge l'integrità secondo il meccanismo di firma, ma il payload può comunque essere leggibile.

Il consumer deve validare le proprietà richieste dal protocollo, come:

- firma;
- issuer;
- audience;
- lifetime;
- purpose del token.

Riuscire a decodificare un JWT non significa autenticare.

## 21. RBAC, ABAC o ACL?

Scelgo in base alla struttura della policy.

RBAC funziona bene per ruoli organizzativi stabili come admin, editor e viewer.

ABAC funziona bene quando le decisioni dipendono da attributi del principal, della risorsa o dell'ambiente.

Le ACL sono adatte a sharing specifico della singola risorsa, per esempio:

- Alice può modificare il documento 10;
- Bob può soltanto leggerlo.

I sistemi reali combinano spesso tutti e tre.

Per esempio:

- RBAC per capacità organization-wide;
- ABAC per condizioni tenant o clearance;
- ACL per condivisione di singoli documenti.

## 22. Role, claim e OAuth scope sono permessi?

Possono essere input dell'autorizzazione, ma non li tratto come decisione finale.

Un token validato può contenere:

- subject;
- role;
- scope;
- tenant claim.

L'applicazione deve comunque valutare la policy rispetto a fatti fidati server-side come:

- risorsa target;
- ownership;
- tenant;
- stato corrente del workflow.

Concettualmente:

identità e claim validati
→ valutazione della policy
→ allow o deny

Il token non sostituisce la authorization policy.

## 23. Quali sono i principi più importanti della sicurezza API?

Uso defense in depth.

Un tipico percorso di sicurezza è:

TLS
→ autenticazione
→ autorizzazione
→ input validation
→ uso sicuro degli interpreti
→ resource limit
→ monitoring

Considero inoltre:

- object-level authorization;
- property-level authorization;
- injection;
- SSRF;
- secret;
- timeout downstream;
- rate limiting;
- minacce browser;
- logging;
- esposizione di rete.

Nessun singolo meccanismo come HTTPS, OAuth, WAF o API gateway rende sicura da solo una API.

## 24. Perché CORS, CSRF e XSS sono problemi differenti?

CORS è principalmente un meccanismo browser per controllare l'accesso cross-origin.

Non autentica i client API e non impedisce a client command-line o server-side di effettuare richieste.

CSRF sfrutta la capacità del browser di allegare automaticamente credenziali, classicamente cookie, a richieste non intenzionali.

XSS permette a contenuto controllato dall'attaccante di essere eseguito nel contesto browser dell'applicazione.

Possono interagire: un XSS riuscito può spesso indebolire protezioni browser-side e abusare delle capacità API autenticate.

Li tratto quindi come minacce differenti associate a trust boundary differenti.

## Sintesi compatta da colloquio

Una API ben progettata è un contratto stabile e un confine del sistema.

Scelgo i protocolli in base ai requisiti dell'interazione e non alla popolarità: HTTP per normali API request/response, WebSocket per comunicazione persistente bidirezionale, messaging asincrono per temporal decoupling e gRPC per RPC interne tipizzate quando appropriato.

Per le API HTTP modello le risorse attorno al dominio, uso deliberatamente la semantica di metodi e status, progetto i retry attorno all'idempotenza e tratto i timeout come risultati ambigui.

Per collection grandi definisco presto ordinamento deterministico e pagination, ed evolvo i contratti pubblici in modo backwards-compatible quando possibile.

GraphQL è utile quando la response shape controllata dal client giustifica i costi aggiuntivi di schema, resolver, autorizzazione e complexity management.

Per la sicurezza separo autenticazione da autorizzazione, OAuth da OpenID Connect, formato JWT da semantica dei token e claim dalle vere decisioni di policy.

Infine tratto la sicurezza API come defense in depth attraverso trasporto, identità, autorizzazione, input boundary, resource limit, browser security, dipendenze e observability.
