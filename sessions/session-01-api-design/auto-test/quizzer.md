# Quizzer – Sessione 01: API Design

## Istruzioni

Rispondi indicando solo le lettere, per esempio:

1B 2A 3B 4A 5A

---

## Domande

### 1. Perché una API è un “contratto” e non solo un endpoint?

A. Perché ogni API deve essere scritta in JSON e usare sempre HTTP.

B. Perché definisce in modo stabile cosa il client può chiedere, quali dati deve inviare, quali risposte può aspettarsi e quali errori possono arrivare.

C. Perché un endpoint API deve sempre corrispondere a una tabella del database.

D. Perché il client deve conoscere l’implementazione interna del server per usarla correttamente.

---

### 2. Stai costruendo una API Laravel per un gestionale interno con utenti, ordini, prodotti e report CSV. Quale scelta è più ragionevole come default?

A. REST, perché il dominio è fatto di risorse abbastanza chiare, i casi d’uso sono CRUD/report e REST è semplice da capire, testare e mantenere.

B. GraphQL, perché ogni API moderna deve avere un endpoint unico.

C. gRPC, perché Laravel funziona meglio solo con Protocol Buffers.

D. WebSocket, perché ogni operazione gestionale deve essere real-time.

---

### 3. Hai una mobile app con schermate molto diverse: profilo utente, notifiche, post, follower, suggerimenti. Quale problema può risolvere GraphQL rispetto a REST?

A. Elimina completamente il bisogno di autenticazione.

B. Permette al client di chiedere esattamente i dati necessari, riducendo over-fetching, under-fetching e troppe chiamate separate.

C. Rende automaticamente il database più veloce.

D. Sostituisce completamente HTTP status code, caching, sicurezza e autorizzazioni.

---

### 4. Due microservizi interni devono scambiarsi molti messaggi ad alta frequenza. Quando avrebbe senso considerare gRPC?

A. Quando controlliamo entrambi i servizi, vogliamo un contratto tipizzato, performance migliori e magari streaming.

B. Quando vogliamo esporre una API pubblica facile da provare nel browser.

C. Quando il client principale è una pagina HTML statica senza build tool.

D. Quando non vogliamo definire nessun contratto tra client e server.

---

### 5. Quale gruppo contiene buone regole pratiche per progettare endpoint REST puliti?

A. Usare nomi coerenti, risorse al plurale, metodi HTTP corretti, paginazione dove serve, errori chiari.

B. Usare sempre POST per tutto, così non bisogna pensare troppo.

C. Mettere verbi ovunque, tipo /getUser, /deleteProduct, /createOrder, perché sono più “espliciti”.

D. Fare endpoint enormi che restituiscono tutti i dati disponibili, così il client decide cosa usare.
