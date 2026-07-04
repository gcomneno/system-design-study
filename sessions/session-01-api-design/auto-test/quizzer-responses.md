# Quizzer Responses – Sessione 01: API Design

## Risposte corrette

1B 2A 3B 4A 5A

## Correzione Bastarda Controllata

Risultato: 5/5 corrette. Promosso senza lancio di banana.

### 1B — giusta

Una API è contratto perché stabilisce cosa è ammesso chiedere, cosa va inviato, cosa torna indietro e quali errori possono arrivare.

Trappola: dire “è un endpoint JSON” è risposta da tutorialino sciancato. L’endpoint è solo un pezzo della superficie.

### 2A — giusta

Gestionale Laravel con utenti, ordini, prodotti e report CSV: REST è la scelta naturale. Risorse chiare, CRUD, filtri, paginazione, export.

Trappola: GraphQL qui rischia di essere overengineering col cappello elegante. gRPC non c’entra come default per un gestionale interno classico.

### 3B — giusta

GraphQL può aiutare quando la mobile app ha schermate diverse e dati annidati. Il client chiede esattamente ciò che serve.

Parole chiave da ricordare: over-fetching e under-fetching.

### 4A — giusta

gRPC ha senso quando controlli entrambi i servizi, vuoi contratto tipizzato, performance e magari streaming.

Trappola: non venderlo come API pubblica browser-first. A colloquio sarebbe una mezza buccia di banana.

### 5A — giusta

Endpoint REST puliti: risorse coerenti, metodi HTTP corretti, nomi chiari, paginazione, errori comprensibili.

Trappola mortale: POST /getUser, POST /deleteProduct, GET /createOrder. API progettata dal cinghiale bendato.

## Versione da colloquio

Una API è un contratto stabile tra client e server: definisce operazioni, dati richiesti, risposte, errori e vincoli. Per un gestionale Laravel con risorse chiare come utenti, ordini e prodotti sceglierei REST, perché è semplice, leggibile, facile da testare e si adatta bene a CRUD, filtri, paginazione ed export. Valuterei GraphQL se i client avessero bisogno di dati molto variabili o annidati, per ridurre over-fetching e under-fetching. Considererei gRPC soprattutto per comunicazione interna tra servizi, quando controllo entrambi i lati e mi servono contratti tipizzati, performance o streaming.
