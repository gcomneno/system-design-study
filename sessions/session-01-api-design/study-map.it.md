# Mappa di studio – Sessione 01: API Design

[English](study-map.md) | [Italiano](study-map.it.md)


## Scopo

Questa mappa traccia la trasformazione del materiale sorgente privato su API Design in materiale didattico pubblico e originale.

La sorgente privata viene usata soltanto come input di studio. I documenti pubblici devono essere scritti autonomamente, concisi, revisionati tecnicamente e riutilizzabili senza riprodurre il transcript sorgente.

## Copertura della sorgente

La SOT privata attuale contiene otto lezioni sorgente distinguibili:

1. What APIs are
2. API protocols
3. TCP vs UDP
4. REST API design
5. GraphQL
6. Authentication
7. Authorization
8. API security

Questi confini descrivono il materiale ricevuto. Non determinano la struttura del corso pubblico.

## Architettura didattica

Il materiale pubblico viene organizzato in dodici unità di apprendimento.

| Unità | Argomento | Concetti principali | Stato |
|---|---|---|---|
| 01 | Fondamenti delle API | contratti, astrazione, confini tra servizi, principi di design, lifecycle | Preparata |
| 02 | Scelta del protocollo | interaction pattern, latenza, throughput, compatibilità, trade-off | Preparata |
| 03 | HTTP e HTTPS | request/response, metodi, header, TLS, sicurezza del trasporto | Preparata |
| 04 | WebSocket, AMQP e gRPC | realtime, messaggistica asincrona, RPC, streaming | Preparata |
| 05 | TCP vs UDP | affidabilità, ordinamento, connessione, trade-off di latenza | Preparata |
| 06 | Design delle risorse REST | risorse, nomi, collezioni, identificatori, risorse annidate | Preparata |
| 07 | Semantica HTTP ed errori | metodi safe/idempotenti, status code, contratti di errore | Preparata |
| 08 | Query ed evoluzione delle API | filtri, ordinamento, paginazione, cursor vs offset, versioning | Preparata |
| 09 | GraphQL | schema, tipi, query, mutation, errori, profondità delle query | Preparata |
| 10 | Autenticazione | Basic, Bearer, OAuth 2, JWT, access/refresh token, SSO | Preparata |
| 11 | Autorizzazione | RBAC, ABAC, ACL, claim, scope, enforcement delle policy | Preparata |
| 12 | Sicurezza delle API | rate limiting, CORS, injection, WAF, VPN, CSRF, XSS | Preparata |

## Modello degli artefatti

Ogni unità dovrebbe produrre, quando utile:

- note di studio concise;
- lessons learned;
- trade-off ingegneristici;
- failure mode ed errori comuni;
- esempi pratici;
- domande da colloquio e risposte modello;
- esercizi;
- quiz di autovalutazione;
- file separato con risposte e correzioni.

Non è necessario creare un file distinto per ogni artefatto di ogni unità. Materiale strettamente correlato può essere accorpato quando rende il percorso più chiaro.

## Materiale esistente

Il materiale preparato comprende ora:

- lessons learned introduttive su API Design;
- percorso didattico completo in dodici unità;
- interview bank bilingue completo sulle Unità 01–12;
- esercizi incorporati nelle unità didattiche;
- Quiz 01 con risposte revisionate — fondamentali API e scelta del paradigma;
- Quiz 02 con answer key — HTTP API Design;
- Quiz 03 con answer key — Protocols, Transport & REST Design;
- Quiz 04 con answer key — GraphQL, Identity & API Security.

Nel complesso questi artefatti coprono l'intero percorso di studio della Sessione 01.
## Politica di revisione tecnica

La SOT privata è un input, non un'autorità.

Prima che un'affermazione della sorgente diventi materiale pubblico canonico, bisogna verificare se è:

- tecnicamente corretta;
- sufficientemente attuale per l'argomento;
- espressa con il giusto livello di precisione;
- priva di trade-off o eccezioni importanti;
- semplificata al punto da creare un modello mentale sbagliato.

La formulazione della sorgente non deve essere copiata negli artefatti pubblici.

## Criteri di completamento

La Sessione 01 è considerata preparata quando:

- tutte le dodici unità sono coperte da materiale originale;
- le affermazioni importanti della sorgente sono state revisionate tecnicamente;
- il materiale da colloquio copre l'intero percorso;
- esistono esercizi per le principali decisioni progettuali;
- quiz e soluzioni coprono l'intero percorso;
- i controlli di hygiene e bilingui sono verdi;
- nessun materiale della SOT privata è tracciato da Git.

## Stato

**Preparata.**

Tutti i criteri di preparazione della Sessione 01 risultano soddisfatti.

La fase successiva è lo studio attivo: utilizzare unità, esercizi, interview material e quiz già preparati. Nuovo materiale di supporto verrà creato soltanto quando durante lo studio emergeranno dubbi, lacune o necessità concrete.
