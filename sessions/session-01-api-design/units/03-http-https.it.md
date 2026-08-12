# Unità 03 – HTTP e HTTPS

[English](03-http-https.md) | [Italiano](03-http-https.it.md)

## Obiettivo didattico

Comprendere HTTP come protocollo di livello applicativo e HTTPS come comunicazione HTTP protetta da un canale di trasporto sicuro.

L'obiettivo è separare tre aspetti che vengono spesso confusi:

- semantica HTTP;
- trasporto utilizzato per portare HTTP;
- autenticazione e autorizzazione applicative.

## HTTP come protocollo applicativo

HTTP definisce un modello di interazione request/response tra client e server.

Una richiesta comunica un'intenzione verso una risorsa. Una risposta comunica l'esito.

Tra gli elementi importanti della comunicazione HTTP troviamo:

- metodo della richiesta;
- URI di destinazione;
- header;
- contenuto opzionale;
- status code della risposta;
- campi della risposta;
- contenuto opzionale della risposta.

La semantica HTTP non dipende dall'implementazione interna del server.

Il client interagisce con un'interfaccia pubblica mentre il server può cambiare database, framework, servizi interni o strategie di storage senza modificare quel contratto.

## Risorse e metodi

HTTP separa l'identità di una risorsa dall'azione richiesta su quella risorsa.

Per esempio, l'URI può identificare un prodotto mentre il metodo HTTP comunica l'operazione da eseguire.

Tra i metodi comuni troviamo:

- GET;
- POST;
- PUT;
- PATCH;
- DELETE.

La semantica dettagliata dei metodi safe e idempotenti viene trattata nell'Unità 07.

## Header

I campi HTTP trasportano metadati e informazioni di controllo.

Esempi comuni:

- `Content-Type`;
- `Accept`;
- `Authorization`;
- `Cache-Control`;
- campi per richieste condizionali;
- metadati di tracing o correlazione.

Gli header fanno parte del contratto del protocollo e non dovrebbero diventare un contenitore arbitrario per dati applicativi.

## Status code

Le risposte contengono status code che descrivono l'esito della richiesta.

Le classi principali sono:

- 1xx — informazioni;
- 2xx — successo;
- 3xx — redirezione;
- 4xx — condizioni relative alla richiesta del client o all'autorizzazione;
- 5xx — errori lato server.

Gli status code specifici e il design degli errori API vengono trattati nell'Unità 07.

## HTTP è stateless a livello di protocollo

HTTP è un protocollo request/response stateless.

Questo non significa che le applicazioni non possano mantenere stato.

Le applicazioni mantengono normalmente:

- stato nel database;
- sessioni autenticate;
- carrelli;
- stato dei workflow;
- cache.

La distinzione importante è che HTTP stesso non richiede al server di ricordare le richieste precedenti per interpretare la semantica della richiesta successiva.

Stato applicativo e stato del protocollo sono concetti differenti.

## HTTPS

HTTPS utilizza la semantica HTTP sopra una connessione protetta.

TLS fornisce il canale sicuro.

Le principali proprietà di sicurezza comprendono:

- confidenzialità;
- integrità;
- autenticazione dei peer.

Nel normale modello web il server viene autenticato verso il client. TLS può autenticare anche il client, ma l'autenticazione client è opzionale.

## HTTPS non autentica l'utente applicativo

Questa distinzione è fondamentale.

Una connessione HTTPS valida dimostra che il client ha stabilito un canale protetto con l'endpoint server autenticato.

Non dimostra automaticamente che l'applicazione sappia quale utente umano sta effettuando la richiesta.

L'identità applicativa può ancora richiedere meccanismi come:

- sessioni;
- bearer token;
- OAuth;
- client credential;
- altri schemi di autenticazione.

Questi verranno trattati nell'unità dedicata all'autenticazione.

## Cosa protegge TLS

TLS è progettato per proteggere i dati durante il transito tra i peer comunicanti.

Aiuta a impedire:

- intercettazione passiva;
- modifica non rilevata del traffico protetto;
- falsificazione dei messaggi all'interno del canale protetto.

TLS da solo non protegge i dati dopo che hanno raggiunto un endpoint.

Se un attaccante compromette application server, database o dispositivo client, HTTPS non sostituisce la sicurezza degli endpoint.

## Versioni HTTP e trasporto

Non bisogna identificare HTTP con TCP.

La semantica HTTP rimane sostanzialmente condivisa tra le versioni moderne, ma i relativi meccanismi di trasporto differiscono.

Un modello ad alto livello utile è:

| Versione | Modello di trasporto tipico |
|---|---|
| HTTP/1.1 | TCP, opzionalmente protetto da TLS per HTTPS |
| HTTP/2 | comunemente TLS sopra TCP |
| HTTP/3 | QUIC, che gira sopra UDP e integra la sicurezza TLS |

HTTP/3 mostra perché protocollo applicativo e protocollo di trasporto devono essere ragionati separatamente.

## Perché HTTP/3 cambia il modello mentale

Le spiegazioni introduttive più vecchie presentano spesso uno stack fisso:

HTTP → TCP → IP

Rimane utile per comprendere molti deployment HTTP/1.1 e HTTP/2, ma non è universale.

HTTP/3 mappa la semantica HTTP su QUIC.

QUIC fornisce caratteristiche come:

- stream multiplexati;
- affidabilità a livello di stream;
- flow control;
- apertura della connessione a bassa latenza;
- handshake crittografico integrato.

Di conseguenza anche “UDP è inaffidabile, quindi qualsiasi cosa sopra UDP è inaffidabile” è un modello incompleto.

Un trasporto di livello superiore come QUIC può implementare affidabilità e ordinamento pur utilizzando datagram UDP sottostanti.

## Conseguenze di design

### Usare HTTPS come default

Per API di produzione che comunicano attraverso reti non fidate, HTTP in chiaro normalmente non dovrebbe trasportare credenziali, token, dati personali o altre informazioni sensibili.

### Non confondere sicurezza del trasporto e autorizzazione

HTTPS protegge il canale.

L'autorizzazione determina se un'identità autenticata può eseguire un'operazione.

Sono livelli di sicurezza indipendenti.

### Trattare la semantica HTTP come contratto

Metodi, status code, header, caching e semantica delle rappresentazioni non sono decorazioni.

Client e intermediari dipendono da essi.

Usarli male rende le API più difficili da ritentare, cachare, debuggare, monitorare ed evolvere.

## Errori comuni

### “HTTPS significa che l'utente è autenticato”

Errato.

TLS normalmente autentica l'endpoint server. L'autenticazione dell'utente applicativo è un problema separato.

### “HTTP gira sempre sopra TCP”

Incompleto.

HTTP/3 gira sopra QUIC, che utilizza UDP.

### “UDP significa applicazioni inaffidabili”

Troppo semplicistico.

UDP non fornisce direttamente affidabilità in stile TCP, ma protocolli costruiti sopra UDP possono implementare proprie semantiche di consegna affidabile.

### “HTTP stateless significa che il server non può memorizzare stato”

Errato.

La statelessness di HTTP non vieta stato applicativo o persistente.

### “200 significa qualsiasi operazione API riuscita”

Troppo generico.

HTTP definisce diversi status code di successo con semantiche differenti.

## Risposta da colloquio

HTTP è un protocollo request/response di livello applicativo che definisce semantica intorno a risorse, metodi, campi e status code delle risposte.

HTTPS non è uno stile differente di API design: è comunicazione HTTP protetta da un canale sicuro tramite TLS.

TLS fornisce confidenzialità, integrità e autenticazione dei peer, ma non sostituisce autenticazione o autorizzazione applicative.

Tengo inoltre separata la semantica HTTP dal trasporto sottostante. HTTP/1.1 e HTTP/2 usano comunemente TCP, mentre HTTP/3 mappa la stessa semantica HTTP su QUIC sopra UDP. Questa distinzione è importante quando si ragiona su latenza, multiplexing, affidabilità e vincoli di deployment.

## Esercizi per lo studio successivo

1. Spiega la differenza tra statelessness HTTP e stato applicativo.
2. Spiega perché HTTPS non elimina la necessità dell'autenticazione tramite bearer token.
3. Un servizio usa HTTPS ma registra ogni access token in chiaro nei log. Individua quale problema di sicurezza HTTPS risolve e quale no.
4. Confronta il modello mentale di HTTP/2 sopra TCP con HTTP/3 sopra QUIC.
5. Spiega perché dire “UDP è inaffidabile, quindi HTTP/3 è inaffidabile” è scorretto.

## Note di revisione della sorgente

La SOT privata introduce correttamente HTTP come fondamento di molte API e HTTPS come comunicazione cifrata.

Durante la revisione tecnica alcuni punti sono stati raffinati:

- la semantica HTTP viene separata dal trasporto sottostante;
- HTTPS non viene descritto come autenticazione dell'utente applicativo;
- la sicurezza TLS viene descritta in termini di confidenzialità, integrità e autenticazione dei peer;
- HTTP/3 e QUIC vengono inclusi per evitare l'assunzione ormai incompleta che HTTP debba necessariamente girare sopra TCP.
