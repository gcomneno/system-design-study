# Unità 02 – Scelta del protocollo

[English](02-protocol-selection.md) | [Italiano](02-protocol-selection.it.md)

## Obiettivo didattico

Scegliere un meccanismo di comunicazione API partendo dai requisiti del sistema anziché dall'abitudine o dalla popolarità di una tecnologia.

La domanda importante non è “Qual è il protocollo migliore?”, ma:

> Quale modello di interazione e quali trade-off sono adatti a questo confine di comunicazione?

## Partire dai requisiti

Prima di scegliere un protocollo, individuare:

- chi comunica con chi;
- comunicazione request/response o bidirezionale;
- interazione sincrona o asincrona;
- sensibilità alla latenza;
- requisiti di throughput;
- dimensione del payload e necessità di encoding;
- requisiti di streaming;
- aspettative di delivery e affidabilità;
- compatibilità con browser e client;
- complessità operativa;
- tooling e developer experience.

La scelta del protocollo è quindi una decisione di design, non una decisione sintattica.

## HTTP/HTTPS

HTTP è la scelta predefinita per molte API client-server perché il modello request/response è ampiamente supportato e semplice da gestire.

Casi tipici:

- API pubbliche;
- comunicazione browser-server;
- applicazioni CRUD;
- integrazioni tra sistemi sviluppati indipendentemente;
- operazioni naturalmente esprimibili come richiesta seguita da risposta.

HTTPS aggiunge sicurezza del trasporto tramite TLS e dovrebbe essere la normale scelta di deployment per API di rete che trasportano dati non pubblici.

### Punti di forza

- ampia compatibilità;
- infrastruttura e tooling maturi;
- osservabilità e debugging semplici;
- semantica request/response ben compresa;
- buon adattamento alle API stateless.

### Trade-off

Il request/response HTTP non è sempre il modello migliore per aggiornamenti continui inviati dal server o workflow asincroni.

Scegliere HTTP soltanto perché è familiare può portare a polling, richieste inutili o interazioni lunghe poco naturali.

## WebSocket

WebSocket offre comunicazione persistente bidirezionale dopo un handshake iniziale.

Casi tipici:

- chat;
- applicazioni collaborative;
- dashboard live;
- interazioni multiplayer;
- aggiornamenti realtime inviati dal server.

### Punti di forza

- comunicazione bidirezionale;
- overhead ridotto dopo l'apertura della connessione;
- il server può inviare messaggi senza attendere una nuova richiesta del client;
- evita polling ripetuto in molti casi realtime.

### Trade-off

Le connessioni persistenti introducono problemi operativi:

- gestione del ciclo di vita della connessione;
- riconnessione;
- heartbeat;
- scaling orizzontale;
- load balancing;
- stato delle connessioni;
- backpressure.

WebSocket non è quindi “HTTP migliore”. Risolve un problema di interazione differente.

## AMQP e messaging

AMQP è un protocollo standardizzato di messaging. I sistemi basati su broker utilizzano comunemente produttori, consumer, code, routing e acknowledgement per disaccoppiare il lavoro.

Casi tipici:

- elaborazione asincrona;
- background job;
- workflow event-driven;
- integrazione tra servizi che operano indipendentemente;
- workload nei quali producer e consumer non devono essere attivi contemporaneamente.

### Punti di forza

- disaccoppiamento temporale;
- assorbimento dei picchi;
- elaborazione asincrona;
- routing e modelli di delivery flessibili.

### Trade-off

Il messaging introduce un confine da sistema distribuito.

Bisogna ragionare su:

- consegne duplicate;
- acknowledgement;
- retry;
- poison message;
- ordinamento;
- dead-letter handling;
- consumer idempotenti;
- monitoraggio della profondità delle code e del ritardo di elaborazione.

Una coda non garantisce magicamente che l'operazione di business avvenga exactly once.

## gRPC

gRPC modella la comunicazione come chiamate remote definite da un contratto di servizio.

Protocol Buffers è il formato predefinito per la definizione dell'interfaccia e dei messaggi, anche se gRPC non è concettualmente limitato a esso.

Casi tipici:

- comunicazione interna service-to-service;
- ambienti nei quali controlliamo entrambi i lati;
- contratti fortemente tipizzati;
- messaggi binari a basso overhead;
- RPC in streaming;
- sistemi con molte chiamate ripetute tra servizi.

### Punti di forza

- generazione dei binding client e server;
- contratti di servizio tipizzati ed espliciti;
- serializzazione binaria efficiente;
- RPC unary e streaming;
- buon adattamento ad architetture di servizi polyglot.

### Trade-off

- meno naturale per il consumo diretto da browser rispetto alle API HTTP convenzionali;
- workflow basato su codice generato;
- evoluzione dello schema da gestire attentamente;
- debugging meno immediatamente leggibile rispetto a JSON su HTTP;
- l'infrastruttura deve supportare correttamente il trasporto gRPC scelto.

## Matrice decisionale

| Requisito | Candidato forte |
|---|---|
| API pubblica request/response convenzionale | HTTP/HTTPS |
| CRUD o API a risorse browser-facing | HTTP/HTTPS |
| Comunicazione realtime persistente e bidirezionale | WebSocket |
| Workflow asincrono producer/consumer | Messaging / AMQP |
| RPC tipizzato interno service-to-service | gRPC |
| Client e server evolvono indipendentemente | In genere HTTP con contratto pubblico stabile |
| Il lavoro deve sopravvivere alla temporanea indisponibilità del consumer | Messaging durevole |
| Stream continuo tra servizi controllati | gRPC streaming o altra tecnologia di streaming |
| Il browser deve ricevere aggiornamenti realtime dal server | WebSocket, o altro meccanismo push browser-compatible secondo la direzionalità |

La tabella è un punto di partenza, non un algoritmo automatico di scelta.

## I sistemi ibridi sono normali

I sistemi reali combinano spesso più meccanismi di comunicazione.

Esempio:

1. un browser chiama una REST API via HTTPS;
2. l'API pubblica un job asincrono;
3. i worker consumano il job tramite messaging;
4. i servizi interni comunicano tramite gRPC;
5. il browser riceve l'avanzamento realtime tramite WebSocket.

Non è incoerenza. Ogni confine ha requisiti differenti.

## Errori comuni

### “Uso gRPC perché è più veloce”

Le performance da sole non bastano.

Bisogna considerare interoperabilità, tooling operativo, osservabilità, compatibilità browser, gestione degli schemi ed esperienza del team.

### “Uso WebSocket per qualsiasi cosa realtime”

Alcuni sistemi richiedono soltanto aggiornamenti server-to-client, refresh periodici o eventi con requisiti realtime meno severi.

Le connessioni persistenti hanno un costo.

### “Una coda garantisce che l'operazione di business avvenga exactly once”

La semantica di consegna del messaggio e gli effetti di business sono problemi differenti.

I consumer richiedono spesso idempotenza e deduplicazione anche quando l'infrastruttura di messaging offre forti garanzie di delivery.

### “REST, WebSocket, AMQP e gRPC sono alternative intercambiabili”

Risolvono problemi di comunicazione sovrapposti ma differenti.

Il confronto utile parte dagli interaction pattern e dai confini del sistema, non semplicemente dai nomi dei protocolli.

## Risposta da colloquio

Quando scelgo un meccanismo di comunicazione API parto dall'interaction pattern e dai requisiti operativi, invece di scegliere prima una tecnologia.

Per una normale API pubblica request/response partirei generalmente da HTTPS. Per comunicazione realtime persistente e bidirezionale valuterei WebSocket. Per workflow asincroni nei quali producer e consumer devono essere disaccoppiati temporalmente userei messaging. Per comunicazione service-to-service controllata che beneficia di contratti tipizzati e streaming, gRPC è un candidato forte.

La decisione finale dipende anche da compatibilità, requisiti di latenza e throughput, semantica di delivery, osservabilità, complessità operativa e capacità del team.

## Esercizi per lo studio successivo

1. Progetta i confini di comunicazione di un checkout ecommerce e giustifica dove useresti HTTP, messaging ed eventualmente gRPC.
2. Decidi come implementare gli aggiornamenti live dello stato di un ordine nel browser e spiega quando polling o WebSocket possono essere appropriati.
3. Una richiesta di pagamento va in timeout dopo essere stata inviata dal client. Spiega perché la sola scelta del protocollo non risolve il rischio di operazioni duplicate.
4. Confronta chiamate HTTP sincrone e messaging asincrono quando il servizio inventory downstream è temporaneamente indisponibile.
5. Spiega perché un'architettura può usare legittimamente più meccanismi di comunicazione contemporaneamente.

## Note di revisione della sorgente

La SOT privata fornisce il framework iniziale per la scelta del protocollo, soprattutto rispetto a interaction pattern, performance, payload, sicurezza, compatibilità e developer experience.

Durante la revisione tecnica alcune semplificazioni della sorgente sono state intenzionalmente raffinate:

- WebSocket viene trattato come protocollo bidirezionale sopra TCP, non semplicemente come “HTTP senza polling”.
- AMQP viene trattato come protocollo di messaging; l'architettura queue-and-broker è un importante modello d'uso ma non costituisce l'intera definizione di AMQP.
- Protocol Buffers viene descritto come IDL e formato messaggi predefinito di gRPC, non come requisito assoluto.
- La scelta del protocollo viene trattata come decisione architetturale multidimensionale e non come semplice classifica di velocità.
