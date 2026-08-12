# Quizzer 03 Responses – Sessione 01: Protocols, Transport & REST Design

## Risposte corrette

1A 2B 3C 4B 5C 6B 7A 8A 9B 10A 11A 12B 13B 14B 15B 16B 17B 18B

## Correzione ragionata

### 1A — HTTP/HTTPS come default ragionevole

Una normale API pubblica request-response non richiede automaticamente connessioni persistenti, broker o datagram.

HTTP/HTTPS è spesso il punto di partenza più semplice e interoperabile.

La scelta cambia quando requisiti concreti giustificano un altro modello.

### 2B — Comunicazione persistente bidirezionale

WebSocket è particolarmente utile quando entrambe le parti devono comunicare frequentemente sulla stessa connessione.

Non serve soltanto perché un'applicazione usa la parola “real-time”.

### 3C — “Real-time = WebSocket”

È una semplificazione pericolosa.

Alcuni casi possono usare:

- polling;
- long polling;
- server-sent events;
- WebSocket;
- messaging intermediato.

La scelta dipende dal pattern concreto.

### 4B — Messaging asincrono

Il producer non deve aspettare il completamento dei consumer.

Questa è una forma di temporal decoupling.

I consumer possono lavorare indipendentemente e recuperare dopo failure temporanei.

### 5C — Delivery non significa business completion

Il broker può conoscere lo stato della consegna del messaggio.

Non può automaticamente garantire che:

- la transazione applicativa sia terminata;
- tutti i side effect siano riusciti;
- l'operazione sia stata eseguita exactly-once.

Delivery semantics e business semantics sono livelli differenti.

### 6B — Retry e redelivery

Crash e failure possono avvenire in punti ambigui.

Un consumer può elaborare un messaggio e fallire prima che la delivery venga definitivamente confermata.

La redelivery può quindi causare una seconda elaborazione.

Idempotenza e deduplicazione limitano il danno.

### 7A — Typed service-to-service RPC

gRPC è particolarmente interessante quando:

- controllo client e server;
- voglio un contratto forte;
- voglio generazione del codice;
- ho bisogno di streaming o RPC efficienti.

Non è automaticamente il miglior contratto pubblico browser-first.

### 8A — gRPC non è soltanto “protobuf”

Protocol Buffers è fortemente associato a gRPC ed è il formato normalmente usato.

Ma il concetto importante è il framework RPC e il relativo contratto di servizio, non una semplice equivalenza mentale con un formato di serializzazione.

### 9B — Byte stream affidabile e ordinato

TCP fornisce un flusso ordinato di byte.

Gestisce inoltre aspetti come:

- retransmission;
- flow control;
- congestion control.

Non conserva però automaticamente i confini dei messaggi applicativi.

### 10A — TCP non conserva le write

Due `send` applicative non implicano due `read` corrispondenti dall'altra parte.

L'applicazione deve definire il proprio framing, per esempio tramite:

- lunghezza;
- delimiter;
- protocol framing.

### 11A — Freschezza versus ritrasmissione

In voice, gaming o telemetry alcuni dati possono diventare inutili rapidamente.

Aspettare il recupero di ogni dato perso può essere peggiore di accettarne la perdita.

Questo non significa che UDP sia universalmente “più veloce”.

Significa che offre un modello differente su cui l'applicazione può costruire le garanzie necessarie.

### 12B — QUIC sopra UDP

QUIC usa UDP come substrato ma implementa molte funzionalità che un'applicazione non vorrebbe ricostruire da zero:

- loss recovery;
- reliability;
- congestion control;
- flow control;
- stream multiplexing;
- sicurezza crittografica.

HTTP/3 dimostra quindi perché il modello “HTTP = TCP” sia troppo rigido.

### 13B — /products/42

L'URL identifica una risorsa del dominio.

Il metodo HTTP può esprimere l'azione.

Questo mantiene separati:

- identity della risorsa;
- semantica dell'operazione.

### 14B — Convenzione, non legge

Usare:

`/products`

è una convenzione leggibile e consistente.

REST non è però definito dalla regola grammaticale “usa sempre nomi plurali”.

### 15B — Dominio pubblico versus persistenza

L'API è un contratto per il consumer.

Esporre direttamente:

- tabelle;
- join table;
- dettagli ORM;
- struttura interna;

crea accoppiamento con l'implementazione.

Il resource model può evolvere indipendentemente dalla persistenza interna.

### 16B — Nested collection e identity globale

È perfettamente ragionevole usare:

`/products/42/reviews`

per la collection contestuale e:

`/reviews/834`

per una review che possiede identità autonoma.

Nesting e identità non sono la stessa cosa.

### 17B — Gerarchie troppo profonde

Nesting eccessivo può introdurre domande difficili:

- la risorsa esiste indipendentemente?
- cambia URL se cambia parent?
- chi ne determina ownership?
- come la indirizzo senza conoscere tutta la gerarchia?

La struttura dell'URL dovrebbe aiutare il domain model, non imprigionarlo.

### 18B — Modellare il dominio, non soltanto CRUD

Un refund può avere:

- propria identity;
- authorization;
- audit trail;
- payment-provider interaction;
- failure;
- reconciliation.

Ridurre tutto a:

`PATCH status=refunded`

può nascondere un'importante operazione di business.

REST resource modeling non significa trasformare ogni workflow in un semplice update di colonna.

## Punti da ricordare

### Protocol selection

Non chiedere:

> Qual è la tecnologia migliore?

Chiedere:

> Quale interaction model richiedono client e server?

### WebSocket

È un canale persistente bidirezionale.

Richiede di pensare anche a:

- reconnect;
- heartbeat;
- scaling;
- fan-out;
- backpressure;
- authentication lifecycle.

### Messaging

Producer e consumer possono essere temporalmente disaccoppiati.

Ma:

delivery ≠ business completion

e:

retry → possibili duplicati.

### gRPC

Forte candidato per RPC interne tipizzate e streaming.

Non è automaticamente il miglior contratto pubblico.

### TCP

Affidabile + ordinato + byte stream.

Non conserva message boundaries.

### UDP

Datagram indipendenti senza reliability e ordering TCP-style integrati.

Può essere utile quando freshness conta più della perfetta delivery.

### QUIC

Costruisce moderne transport semantics sopra UDP.

Quindi:

UDP substrate ≠ applicazione senza reliability.

### REST resource design

Modellare:

- domain concepts;
- identity;
- collections;
- relationships.

Non copiare:

- procedure;
- tabelle;
- ORM.

### Domain actions

CRUD è uno strumento.

Il dominio viene prima.

Operazioni con semantica propria possono meritare modeling esplicito.

## Versione sintetica da colloquio

Scelgo il protocollo partendo dal communication pattern. HTTP è un buon default request-response, WebSocket serve quando ho comunicazione persistente bidirezionale, messaging asincrono quando voglio temporal decoupling e gRPC quando servizi controllati beneficiano di RPC tipizzate e streaming.

A livello transport distinguo TCP come byte stream affidabile e ordinato da UDP come servizio datagram senza quelle garanzie integrate. QUIC mostra che si possono costruire reliability e multiplexing sopra UDP.

Nel REST design modello risorse e identità del dominio, non tabelle database o verbi procedurali. Uso nesting quando esprime realmente una relazione utile, ma evito gerarchie profonde e tratto operazioni di business complesse come concetti del dominio anziché semplici modifiche di colonne.
