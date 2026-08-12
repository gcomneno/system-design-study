# Quizzer 04 – Sessione 01: GraphQL, Identity & API Security

## Perché questo quiz

Questo quiz copre soprattutto le Unità 09–12:

- GraphQL;
- authentication;
- OAuth 2.0 e OpenID Connect;
- JWT, access token e refresh token;
- authorization;
- RBAC, ABAC e ACL;
- claim e OAuth scope;
- object-level e field-level authorization;
- API security;
- CORS, CSRF e XSS;
- rate limiting;
- SSRF;
- defense in depth.

L'obiettivo è verificare i modelli mentali, non la memoria delle sigle.

## Istruzioni

Rispondi indicando soltanto le lettere, per esempio:

```text
1A 2B 3C 4D 5A 6B 7C 8D
```

Le risposte ragionate sono nel file:

`quizzer-04-graphql-identity-security-responses.md`

---

## Domande

### 1. Qual è uno dei motivi più validi per scegliere GraphQL?

A. Il client necessita response shape differenti e traversal di dati fortemente collegati.

B. Elimina automaticamente authentication e authorization.

C. Garantisce che venga eseguita una sola query database.

D. È sempre più semplice operativamente di HTTP REST.

---

### 2. Una query GraphQL è sintatticamente non valida. Quale classificazione è più corretta?

A. Execution error con `data` necessariamente completa.

B. Request error che impedisce la normale esecuzione.

C. Authorization error che deve sempre diventare HTTP 403.

D. Errore N+1.

---

### 3. Un resolver GraphQL fallisce mentre altri field possono essere risolti. Cosa può accadere?

A. GraphQL deve sempre eliminare tutta la risposta.

B. La risposta può contenere `data` parziale insieme a `errors`.

C. Il server deve necessariamente restituire HTTP 500 senza body.

D. Ogni sibling field deve essere ritentato automaticamente.

---

### 4. Quale affermazione sullo status HTTP delle risposte GraphQL è più accurata?

A. Ogni errore GraphQL deve sempre essere HTTP 200.

B. GraphQL e HTTP hanno semantiche distinte; il mapping dipende anche dal contratto GraphQL-over-HTTP.

C. GraphQL non può essere trasportato su HTTP.

D. Qualsiasi execution error deve obbligatoriamente essere HTTP 404.

---

### 5. Hai 100 post e risolvi separatamente l'autore di ciascuno. Qual è il problema?

A. CSRF.

B. N+1.

C. CORS.

D. TCP head-of-line blocking.

---

### 6. Perché limitare soltanto la profondità delle query GraphQL può non bastare?

A. Una query poco profonda può comunque richiedere enormi collection o resolver molto costosi.

B. La profondità influenza soltanto il CSS.

C. GraphQL non permette query annidate.

D. La query depth è una proprietà di OAuth.

---

### 7. Quale affermazione su OAuth 2.0 è corretta?

A. È principalmente un authorization framework per accesso delegato.

B. È semplicemente un formato JWT.

C. È un algoritmo di hashing delle password.

D. È sinonimo di Single Sign-On.

---

### 8. Quale ruolo svolge OpenID Connect rispetto a OAuth 2.0?

A. Aggiunge un identity/authentication layer standardizzato.

B. Sostituisce TLS.

C. Converte automaticamente tutti gli access token in password.

D. È un sistema di pagination.

---

### 9. Qual è la distinzione migliore tra access token e ID Token?

A. Sono sempre perfettamente intercambiabili.

B. L'access token è destinato al resource server; l'ID Token comunica identity information al relying party OpenID Connect.

C. L'ID Token serve solo a cifrare il database.

D. L'access token è sempre una password in Base64.

---

### 10. Quale affermazione sui JWT è più corretta?

A. Se riesco a decodificarlo, l'utente è autenticato.

B. JWT è un formato di token; il consumer deve validarlo nel corretto protocollo e trust context.

C. Ogni JWT è automaticamente cifrato.

D. Ogni JWT è necessariamente un OAuth access token.

---

### 11. Un JWT è firmato ma non cifrato. Cosa significa?

A. Il payload può essere leggibile anche se la firma ne protegge integrità/autenticità.

B. Nessuno può leggere i claim.

C. La firma rende inutile controllare issuer e audience.

D. Il token non può mai scadere.

---

### 12. Perché i refresh token richiedono particolare protezione?

A. Perché possono permettere di ottenere nuovi access token nel tempo.

B. Perché servono soltanto per comprimere JSON.

C. Perché sono sempre pubblici.

D. Perché sostituiscono l'authorization server.

---

### 13. Quale vantaggio può offrire la refresh-token rotation?

A. Trasforma OAuth in UDP.

B. Può aiutare a rilevare replay quando un vecchio refresh token viene riutilizzato.

C. Elimina ogni necessità di revoca.

D. Rende gli access token eterni.

---

### 14. Quale descrizione di RBAC è più corretta?

A. Assegna permessi a ruoli e ruoli ai principal.

B. Decide soltanto in base all'indirizzo IP.

C. È una lista di URL CORS consentiti.

D. È un formato di token.

---

### 15. Quando ABAC è particolarmente utile?

A. Quando la policy dipende da attributi del subject, della risorsa o dell'ambiente.

B. Soltanto quando esistono tre ruoli fissi.

C. Quando vogliamo eliminare tutte le policy.

D. Per sostituire HTTP con GraphQL.

---

### 16. Quale scenario è naturalmente adatto a una ACL?

A. Definire chi può leggere o modificare uno specifico documento condiviso.

B. Definire il congestion control TCP.

C. Definire lo schema GraphQL.

D. Configurare il certificato TLS.

---

### 17. Un JWT validato contiene `role=admin`. Cosa puoi concludere?

A. Qualsiasi operazione su qualsiasi risorsa è automaticamente autorizzata.

B. Il claim può essere un input fidato della policy, ma va ancora valutato rispetto ad action, resource e context.

C. Il client può modificare autonomamente quel claim nel request body.

D. Non serve più object-level authorization.

---

### 18. Uno scope OAuth `orders:write` cosa rappresenta meglio?

A. Autorità delegata che può essere un input alla decisione, ma non necessariamente autorizza ogni ordine concreto.

B. Il ruolo database dell'utente.

C. Una garanzia che qualsiasi ordine appartenga al caller.

D. Una regola CORS.

---

### 19. Alice può leggere `/invoices/100`, ma modificando l'URL in `/invoices/101` ottiene la fattura di Bob. Qual è il problema?

A. Broken object-level authorization.

B. N+1.

C. CSRF.

D. Broken TCP framing.

---

### 20. Una API restituisce correttamente il profilo utente, ma espone anche `salary` e flag interni a chi non dovrebbe vederli. Quale area è coinvolta?

A. Property/field-level authorization.

B. UDP ordering.

C. OAuth authorization code flow.

D. Cursor pagination.

---

### 21. Perché nascondere il pulsante “Delete” nella UI non è una protezione sufficiente?

A. Perché il client può chiamare direttamente il backend e il server deve applicare l'autorizzazione.

B. Perché ogni browser ignora il CSS.

C. Perché DELETE non esiste in HTTP.

D. Perché serve necessariamente GraphQL.

---

### 22. Quale affermazione su CORS è corretta?

A. È un meccanismo browser cross-origin e non sostituisce authentication o authorization dell'API.

B. Impedisce a `curl` di chiamare una API.

C. È una protezione DDoS completa.

D. Autentica automaticamente l'origine.

---

### 23. In quale scenario il rischio CSRF classico è particolarmente rilevante?

A. Quando il browser allega automaticamente cookie di autenticazione a una richiesta state-changing.

B. Quando UDP perde un datagram.

C. Quando una query SQL usa un indice.

D. Quando un worker AMQP effettua batching.

---

### 24. Qual è una conseguenza importante di XSS per una applicazione che usa API autenticate?

A. Script dell'attaccante può operare nel contesto fidato dell'applicazione e abusare delle capacità autenticate.

B. Trasforma automaticamente HTTP in HTTPS.

C. Impedisce ogni accesso al DOM.

D. Rende i token impossibili da rubare.

---

### 25. Quale affermazione sul rate limiting è più corretta?

A. È una forma utile di controllo del consumo e dell'abuso, ma non costituisce da sola una strategia DDoS completa.

B. Elimina qualsiasi attacco distribuito.

C. Serve esclusivamente a GraphQL.

D. Sostituisce authorization e input validation.

---

### 26. Un endpoint accetta un URL e il server scarica la risorsa indicata. Quale rischio va considerato esplicitamente?

A. SSRF.

B. RBAC role explosion.

C. TCP message framing.

D. GraphQL N+1.

---

### 27. Perché una risposta proveniente da una API di terze parti deve comunque essere validata?

A. Perché attraversa un trust boundary e può essere malformata, enorme, compromessa o inattesa.

B. Perché HTTPS converte sempre il JSON in codice eseguibile.

C. Perché le API esterne non possono usare TLS.

D. Soltanto perché CORS lo impone.

---

### 28. Quale affermazione descrive meglio defense in depth?

A. Affidarsi a più controlli complementari perché nessun singolo livello risolve tutte le minacce.

B. Installare un WAF e rimuovere authentication e authorization.

C. Usare HTTPS e smettere di validare input.

D. Mettere la API dietro VPN e considerare fidato qualsiasi caller interno.

---

## Dopo il quiz

Durante la fase di studio, rispondi senza consultare l'answer key.

La correzione deve verificare soprattutto se riesci a distinguere concetti che vengono spesso confusi:

- GraphQL response semantics versus HTTP transport;
- OAuth versus OpenID Connect;
- JWT format versus token semantics;
- authentication versus authorization;
- claim/scope versus policy decision;
- CORS versus API access control;
- CSRF versus XSS;
- rate limiting versus DDoS protection.
