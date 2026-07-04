# Interview Answers – Sessione 01: API Design

## Cos’è una API?

Una API è un contratto stabile tra sistemi. Definisce quali operazioni un client può richiedere, quali dati deve inviare, quali risposte può aspettarsi, quali errori possono verificarsi e quali vincoli deve rispettare.

Una buona API nasconde i dettagli interni dell’implementazione ed espone un’interfaccia coerente, sicura e prevedibile.

## Quando useresti REST?

Userei REST quando il dominio è organizzabile in risorse chiare, come utenti, ordini, prodotti o pagamenti.

È una buona scelta per CRUD, gestionali, integrazioni esterne e API pubbliche o semi-pubbliche, perché sfrutta bene HTTP, status code, caching, tooling e debugging.

## Quando useresti GraphQL?

Valuterei GraphQL quando il client ha bisogno di dati molto variabili, annidati o specifici per schermata.

È utile per ridurre over-fetching e under-fetching, soprattutto in mobile app, dashboard complesse o frontend con molte viste diverse.

Il costo è maggiore complessità lato server: schema, resolver, autorizzazioni campo per campo, caching e controllo delle query costose.

## Quando useresti gRPC?

Userei gRPC soprattutto per comunicazione interna tra servizi, quando controllo entrambi i lati e mi servono contratti tipizzati, buone performance o streaming.

Non lo sceglierei come prima opzione per una API pubblica browser-first, dove REST o GraphQL sono spesso più semplici da consumare.

## Quali principi seguiresti per progettare una buona API?

Seguirei quattro principi principali:

- consistenza;
- semplicità;
- sicurezza;
- performance.

Una API deve usare naming coerente, comportamenti prevedibili, autenticazione, autorizzazione, validazione input, rate limiting, paginazione, payload controllati e gestione chiara degli errori.

## Cosa significa che una API è stateless?

Significa che ogni richiesta contiene tutte le informazioni necessarie per essere processata.

Il server non dovrebbe dipendere da richieste precedenti per capire cosa fare. Questo semplifica scalabilità, bilanciamento del carico e affidabilità.

## Come gestiresti il versioning di una API REST?

Per cambiamenti breaking userei versioning esplicito, per esempio `/api/v1`.

Per cambiamenti compatibili, come aggiungere campi opzionali, eviterei una nuova versione e manterrei retrocompatibilità.

La regola è non rompere i client esistenti senza deprecazione chiara e periodo di transizione.

## Come progetteresti gli errori di una API?

Userei status code HTTP coerenti e risposte JSON prevedibili.

Esempio:

- `400` per input non valido;
- `401` per utente non autenticato;
- `403` per utente autenticato ma non autorizzato;
- `404` per risorsa non trovata;
- `409` per conflitto;
- `422` per validazione semantica fallita;
- `500` per errore interno.

La risposta dovrebbe contenere un messaggio chiaro, un codice applicativo e dettagli utili senza esporre informazioni sensibili.

## Cosa significa idempotenza?

Una operazione è idempotente quando ripeterla più volte produce lo stesso effetto finale.

In REST, `GET`, `PUT` e `DELETE` dovrebbero essere idempotenti. `POST` di solito non lo è, perché spesso crea una nuova risorsa a ogni chiamata.

L’idempotenza è importante in caso di retry, timeout e sistemi distribuiti.

## Risposta sintetica da colloquio

Una API ben progettata è un contratto stabile, non solo un endpoint. Deve esporre operazioni chiare, nascondere l’implementazione interna, gestire errori e sicurezza in modo prevedibile, e permettere ai client di evolvere senza accoppiarsi troppo al server. Sceglierei REST per CRUD e risorse chiare, GraphQL per client con dati variabili o annidati, e gRPC per comunicazione interna ad alte performance tra servizi controllati.
