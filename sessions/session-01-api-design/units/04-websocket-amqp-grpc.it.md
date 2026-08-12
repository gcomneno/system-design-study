# Unità 04 – WebSocket, AMQP e gRPC

[English](04-websocket-amqp-grpc.md) | [Italiano](04-websocket-amqp-grpc.it.md)

## Obiettivo didattico

Comprendere perché WebSocket, protocolli di messaging come AMQP e gRPC risolvono problemi di comunicazione differenti anche se possono sembrare alternative a una normale API HTTP.

Il confronto utile non parte dai nomi delle tecnologie.

Parte da:

- direzione dell'interazione;
- durata della connessione;
- accoppiamento temporale;
- semantica di delivery;
- requisiti di streaming;
- controllo dei servizi coinvolti;
- complessità operativa.

## WebSocket

WebSocket fornisce un canale di comunicazione persistente e bidirezionale.

La connessione inizia con un opening handshake compatibile con l'infrastruttura HTTP. Dopo il completamento dell'handshake, la comunicazione utilizza il framing WebSocket sulla connessione stabilita.

Entrambi i peer possono quindi inviare messaggi indipendentemente.

### Casi d'uso tipici

- chat;
- editing collaborativo;
- applicazioni multiplayer;
- dashboard live;
- notifiche realtime;
- stato applicativo che cambia continuamente.

### Perché è diverso dal polling

Con il polling il client chiede ripetutamente se qualcosa è cambiato.

Questo può produrre richieste che non restituiscono informazioni utili.

Con WebSocket la connessione rimane disponibile e il server può inviare dati quando si verifica un evento.

Questo può ridurre cicli request/response inutili quando serve realmente comunicazione realtime bidirezionale.

### Aspetti operativi

Le connessioni persistenti introducono ulteriori responsabilità:

- riconnessione;
- timeout della connessione;
- strategie ping/pong o heartbeat;
- cleanup delle connessioni;
- load balancing;
- scaling orizzontale;
- fan-out tra istanze applicative;
- backpressure;
- rinnovo dell'autenticazione;
- osservabilità delle connessioni longeve.

WebSocket riduce il polling, ma non elimina la complessità dei sistemi distribuiti.

## AMQP

AMQP è un protocollo standardizzato di messaging.

Definisce concetti interoperabili relativi a:

- messaggi;
- source e target;
- trasferimenti;
- delivery state;
- settlement;
- outcome;
- flusso dei messaggi tra peer.

Le architetture broker-based con code sono un uso comune del messaging, ma AMQP non deve essere ridotto a “protocollo per code”.

## Messaging e disaccoppiamento temporale

Consideriamo un workflow di elaborazione ordini.

Un producer può pubblicare lavoro mentre il consumer è temporaneamente occupato o indisponibile.

Un sistema di messaging durevole può conservare quel lavoro finché un consumer non è in grado di elaborarlo.

Questo cambia l'accoppiamento tra i componenti.

Con una richiesta sincrona:

producer → attende consumer

Con messaging asincrono:

producer → infrastruttura di messaging → consumer

Producer e consumer non devono necessariamente essere attivi nello stesso momento.

## Delivery non significa completamento del business

Ricevere o accettare un messaggio non equivale automaticamente a completare l'operazione di business exactly once.

Il sistema deve ancora considerare:

- duplicati;
- retry;
- crash del consumer;
- redelivery;
- idempotenza;
- confini transazionali;
- poison message;
- dead-letter handling.

Per esempio, un consumer dei pagamenti potrebbe addebitare correttamente una carta e poi andare in crash prima di registrare il completamento del messaggio.

Se il messaggio viene consegnato nuovamente, ripetere ingenuamente l'operazione potrebbe addebitare il cliente due volte.

La semantica di delivery del messaggio e la semantica degli effetti di business devono quindi essere progettate separatamente.

## Delivery state e settlement

I protocolli di messaging possono tracciare lo stato di una delivery.

Concettualmente, un trasferimento può raggiungere outcome come:

- accepted;
- rejected;
- released;
- modified.

Il settlement determina quando i peer possono dimenticare lo stato della delivery.

È un modello più preciso rispetto a dire semplicemente che “la coda garantisce la consegna”.

La garanzia concreta dipende dal comportamento del protocollo, dalla configurazione del broker e dal design applicativo.

## gRPC

gRPC è un framework RPC costruito intorno a servizi e metodi definiti esplicitamente.

Invece di esporre principalmente risorse come:

`/users/42`

un'interfaccia RPC espone operazioni invocabili definite tramite un contratto di servizio.

Protocol Buffers è il linguaggio di definizione dell'interfaccia e il formato messaggi predefinito.

Dal service definition il tooling può generare binding client e server.

## Tipi di RPC

gRPC supporta quattro importanti modelli di interazione.

### Unary RPC

Una richiesta produce una risposta.

Concettualmente:

client → richiesta → server
client ← risposta ← server

### Server streaming

Il client invia una richiesta e riceve uno stream di risposte.

È utile quando una richiesta produce una sequenza di risultati.

### Client streaming

Il client invia uno stream di messaggi e infine riceve una risposta.

È utile quando molti input contribuiscono a una singola operazione.

### Bidirectional streaming

Client e server si scambiano entrambi stream di messaggi.

Le due direzioni possono avanzare indipendentemente.

Questo permette comunicazione streaming service-to-service più ricca.

## Flow control

Lo streaming introduce un problema: un sender veloce può sopraffare un receiver più lento.

gRPC partecipa quindi a meccanismi di flow control che possono ritardare ulteriori write finché il ricevente non dispone di capacità.

È un dettaglio ingegneristico importante.

Streaming non significa “manda alla massima velocità e spera”.

## Punti di forza di gRPC

gRPC è particolarmente interessante quando:

- controlliamo entrambi i lati dell'interfaccia;
- i servizi sono implementati in linguaggi supportati differenti;
- i binding generati sono utili;
- vogliamo contratti fortemente tipizzati;
- la serializzazione binaria è appropriata;
- serve streaming;
- vengono eseguite molte chiamate service-to-service.

## Trade-off di gRPC

Le stesse caratteristiche introducono costi:

- disciplina nella gestione degli schemi;
- workflow basato su codice generato;
- debugging differente dalle API JSON;
- requisiti di compatibilità infrastrutturale;
- maggiore attrito per consumer browser diretti;
- progettazione attenta di timeout e deadline.

RPC inoltre non elimina l'incertezza della rete.

Una remote function call rimane remota.

Timeout, partial failure, retry e risultati ambigui rimangono problemi da sistema distribuito.

## Non sono tecnologie equivalenti

Un errore comune consiste nel confrontare:

- HTTP;
- WebSocket;
- AMQP;
- gRPC

come se una dovesse sostituire tutte le altre.

Un sistema reale può usarle tutte.

Esempio ecommerce:

1. il browser chiama una API pubblica via HTTPS;
2. il checkout pubblica un messaggio per elaborare l'ordine;
3. worker inventory e payment consumano lavoro asincrono;
4. i servizi interni comunicano tramite gRPC;
5. gli aggiornamenti sullo stato dell'ordine raggiungono il browser tramite WebSocket.

Ogni meccanismo serve un confine differente.

## Confronto decisionale

| Requisito | Candidato probabile |
|---|---|
| Comunicazione realtime persistente browser ↔ server | WebSocket |
| Lavoro asincrono durevole | Messaging / AMQP |
| Disaccoppiare temporalmente producer e consumer | Messaging / AMQP |
| RPC tipizzato interno | gRPC |
| Chiamate unary service-to-service | gRPC o HTTP |
| Streaming client/server tra servizi controllati | gRPC |
| API pubblica a risorse leggibile facilmente | HTTP/REST |
| Il browser riceve frequenti aggiornamenti bidirezionali | WebSocket |

La tabella offre indicazioni progettuali, non regole assolute.

## Failure mode da considerare

### WebSocket

- client disconnesso;
- reconnect storm;
- contesto applicativo perso;
- autenticazione diventata stale;
- consumer lento;
- concentrazione delle connessioni su un solo server.

### Messaging

- messaggio duplicato;
- crash del consumer dopo un side effect;
- poison message;
- crescita del backlog;
- assunzioni errate sull'ordinamento;
- retry storm.

### gRPC

- deadline exceeded;
- client e server non concordano sul completamento dell'operazione;
- retry di operazioni non idempotenti;
- consumer lento di uno stream;
- incompatibilità dello schema;
- servizio downstream indisponibile.

## Errori comuni

### “WebSocket garantisce realtime”

Fornisce un meccanismo di comunicazione adatto, ma la latenza end-to-end dipende ancora da applicazione, rete, code, elaborazione e infrastruttura.

### “AMQP significa coda”

Troppo limitante.

Le code sono un importante pattern di messaging, ma AMQP definisce un modello interoperabile più ampio.

### “Il broker garantisce comportamento business exactly once”

No.

Le garanzie di delivery non rendono automaticamente exactly once side effect applicativi arbitrari.

### “gRPC fa comportare le chiamate remote come funzioni locali”

Modello mentale pericoloso.

La sintassi può assomigliare a una funzione, ma failure di rete e risultati ambigui continuano a esistere.

### “Streaming significa assenza di backpressure”

Errato.

I sistemi streaming devono comunque gestire il flow control quando sender e receiver procedono a velocità differenti.

## Risposta da colloquio

WebSocket, messaging in stile AMQP e gRPC risolvono problemi di comunicazione differenti.

Valuterei WebSocket per comunicazione realtime persistente e bidirezionale, soprattutto con client browser. Userei messaging quando producer e consumer devono essere disaccoppiati temporalmente, serve buffering o lavoro asincrono durevole. Valuterei gRPC per comunicazione service-to-service controllata quando sono utili contratti tipizzati, client generati e streaming.

Non sceglierei tra queste tecnologie soltanto confrontando benchmark di throughput. Considererei anche failure semantics, retry, delivery guarantee, compatibilità dei client, osservabilità e complessità operativa.

## Esercizi per lo studio successivo

1. Progetta una chat e indica cosa risolve WebSocket e cosa non risolve.
2. Progetta l'elaborazione ordini quando il worker dei pagamenti può rimanere indisponibile per dieci minuti.
3. Spiega come un messaggio possa essere consegnato una volta ma un'operazione di business possa comunque avvenire due volte.
4. Progetta un'interfaccia gRPC usando unary e server-streaming RPC per operazioni differenti.
5. Spiega cosa deve accadere quando un consumer streaming è più lento del producer.
6. Disegna un sistema che utilizzi legittimamente HTTPS, WebSocket, messaging e gRPC insieme.

## Note di revisione della sorgente

La SOT privata identifica correttamente i principali casi d'uso:

- WebSocket per comunicazione realtime bidirezionale;
- messaging in stile AMQP per workflow asincroni producer/consumer;
- gRPC per RPC service-to-service efficiente.

Durante la revisione tecnica il modello è stato raffinato:

- WebSocket utilizza HTTP nella fase di apertura della connessione ma diventa un protocollo framed indipendente sulla connessione.
- AMQP è più ampio dell'astrazione di una coda e include concetti espliciti di delivery state e settlement.
- Le delivery guarantee vengono separate dagli effetti di business exactly once.
- Vengono resi espliciti i quattro tipi di RPC gRPC.
- Il flow control viene incluso come problema fondamentale dello streaming.
- La sintassi RPC viene separata intenzionalmente dalla semantica delle funzioni locali perché le chiamate remote possono comunque fallire in modi propri dei sistemi distribuiti.
