# Quizzer 02 – Sessione 01: HTTP API Design

## Perché questo quiz

Il primo quiz copriva scelta del paradigma API (REST, GraphQL, gRPC) e principi generali.
Questo è più cattivo: simula domande da colloquio su HTTP reale — status code, errori, idempotenza, versioning, paginazione, rate limiting, auth.

Prima di rispondere, ricorda le regole operative:

- **Safe**: la richiesta non modifica lo stato sul server (`GET`, `HEAD`).
- **Idempotente**: ripetere la stessa richiesta N volte ha lo stesso effetto di farla una volta (`GET`, `PUT`, `DELETE`; `PATCH` dipende dalla semantica).
- **POST**: di default **non** idempotente — due retry possono creare due risorse.
- **401 Unauthorized**: identità assente, scaduta o non valida — “non so chi sei”.
- **403 Forbidden**: identità valida ma permesso negato — “so chi sei, ma non puoi”.
- **Breaking change**: rompe client esistenti (rimuovere/rinominare/cambiare semantica di campi usati). Aggiungere un campo opzionale di solito **non** rompe.

## Istruzioni

Rispondi indicando solo le lettere, per esempio:

```text
1A 2C 3B 4D 5A 6C 7B 8D 9A 10C
```

Non guardare `quizzer-02-http-api-design-responses.md` — non esiste ancora. Quello arriva dopo la correzione.

---

## Domande

### 1. Autenticazione vs autorizzazione: quale coppia descrive meglio la distinzione operativa?

A. Autenticazione = verificare l’identità; autorizzazione = decidere se quell’identità può eseguire l’azione.

B. Autenticazione = decidere i permessi RBAC; autorizzazione = emettere il JWT.

C. Sono sinonimi in REST: se passi il token, hai risolto entrambe.

D. Autorizzazione avviene sempre prima dell’autenticazione, altrimenti il server non sa quale utente controllare.

---

### 2. Devi creare un nuovo ordine. Il client non conosce ancora l’ID finale. Quale scelta HTTP è la più corretta?

A. `PUT /orders/{id}` con ID inventato dal client.

B. `POST /orders` con body dell’ordine.

C. `PATCH /orders` senza ID, perché PATCH è “più flessibile”.

D. `GET /orders/create` con i dati dell’ordine in query string.

---

### 3. Devi aggiornare **solo** il campo `phone` di `/users/42`. Il resto della risorsa resta invariato. Cosa scegli?

A. `PUT /users/42` inviando l’intero oggetto utente, obbligatoriamente.

B. `PATCH /users/42` con body parziale, per esempio `{"phone": "+39..."}`.

C. `POST /users/42/update-phone` perché è più esplicito del verbo HTTP.

D. `DELETE /users/42` seguito da `POST /users` con tutti i dati aggiornati.

---

### 4. Il client invia `PUT /users/42` con lo stesso body identico due volte a causa di un timeout di rete. Implementazione corretta: cosa ti aspetti?

A. Due utenti distinti, perché PUT crea sempre una nuova risorsa.

B. Un solo effetto sullo stato: la risorsa 42 è sostituita/aggiornata; la seconda richiesta è equivalente alla prima — PUT idempotente.

C. La seconda richiesta deve fallire sempre con `500 Internal Server Error`.

D. PUT non può essere idempotente se il body contiene campi nullable.

---

### 5. Il client invia `POST /orders` due volte con lo stesso payload, **senza** idempotency key, perché il primo response non è arrivato. Cosa è più realistico?

A. Il server deduplica automaticamente per definizione: POST è idempotente.

B. Possono essere creati **due ordini distinti** — POST di default non è idempotente.

C. La seconda richiesta restituisce sempre `409 Conflict`.

D. La seconda richiesta restituisce sempre `304 Not Modified`.

---

### 6. Richiesta a `GET /admin/reports` con header `Authorization: Bearer <token>` valido, ma l’utente ha ruolo `viewer` e non `admin`. Status code più appropriato?

A. `401 Unauthorized` — il token c’è, quindi è un problema di login.

B. `403 Forbidden` — l’utente è autenticato ma non autorizzato per quella risorsa.

C. `404 Not Found` — nascondi l’esistenza dell’endpoint agli utenti non admin.

D. `422 Unprocessable Entity` — il ruolo viewer non passa la validazione semantica.

---

### 7. Richiesta a `GET /me` **senza** header `Authorization` su endpoint protetto. Status code più appropriato?

A. `401 Unauthorized` — identità mancante o non dimostrata.

B. `403 Forbidden` — manca il permesso.

C. `400 Bad Request` — il client ha dimenticato un parametro query obbligatorio.

D. `500 Internal Server Error` — il middleware non è configurato.

---

### 8. Quale scenario → status code è la coppia **più difendibile** in un’API REST moderna?

A. Body JSON malformato (syntax error) → `422 Unprocessable Entity`

B. Email già registrata in signup → `409 Conflict`

C. Campo obbligatorio mancante nel JSON → `500 Internal Server Error`

D. Rate limit superato → `403 Forbidden`

---

### 9. Feed social con molti inserimenti in tempo reale. Paginazione con `?page=847&limit=20` (offset) su milioni di record dinamici. Problema principale?

A. Offset pagination è sempre la scelta migliore perché è la più semplice da implementare in SQL.

B. Con dataset molto dinamici, offset alto può essere lento, saltare o duplicare elementi quando i dati cambiano — cursor pagination è spesso più adatta.

C. La paginazione non serve: basta restituire tutto e far paginare il client.

D. Cursor pagination elimina ogni bisogno di autenticazione e rate limiting.

---

### 10. Stai evolvendo un’API REST già in produzione con client mobile e web. Quale modifica è **breaking**?

A. Aggiungere un campo opzionale `nickname` nella risposta di `GET /users/{id}`.

B. Rinominare il campo obbligatorio `email` in `contact_email` nella stessa risposta, senza periodo di transizione.

C. Aggiungere un nuovo endpoint opzionale `GET /users/{id}/preferences`.

D. Aggiungere un filtro query opzionale `?status=active` su `GET /users`.

---

## Dopo il quiz

Quando hai finito, incolla le risposte in chat con il formato:

```text
1A 2B 3C 4D 5A 6B 7A 8C 9B 10D
```

Poi arriva la correzione in **Modalità Bastarda Controllata** e il file `quizzer-02-http-api-design-responses.md`.
