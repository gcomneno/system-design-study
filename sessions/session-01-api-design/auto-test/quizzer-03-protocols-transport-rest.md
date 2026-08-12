# Quizzer 03 – Sessione 01: Protocols, Transport & REST Design

## Perché questo quiz

Questo quiz copre soprattutto le Unità 02–06:

- protocol selection;
- HTTP versus persistent communication;
- WebSocket;
- AMQP e messaging asincrono;
- gRPC;
- TCP versus UDP;
- QUIC;
- REST resource design.

L'obiettivo è verificare la capacità di scegliere un'architettura e giustificarne i trade-off, non memorizzare slogan tecnologici.

## Istruzioni

Rispondi indicando soltanto le lettere, per esempio:

```text
1A 2B 3C 4D 5A 6B 7C 8D 9A 10B 11C 12D
```

Le risposte ragionate sono nel file separato:

`quizzer-03-protocols-transport-rest-responses.md`

---

## Domande

### 1. Devi progettare una normale API pubblica per catalogo prodotti, ordini e profili utente. Qual è il default più ragionevole?

A. HTTP/HTTPS request-response, salvo requisiti che giustifichino altro.

B. WebSocket per ogni endpoint perché mantiene la connessione aperta.

C. AMQP direttamente dal browser perché le queue sono sempre più affidabili.

D. UDP perché ogni API deve minimizzare la latenza.

---

### 2. Quale requisito giustifica meglio l'uso di WebSocket?

A. Il client effettua una ricerca prodotti ogni dieci minuti.

B. Client e server devono scambiarsi frequentemente aggiornamenti bidirezionali su una connessione persistente.

C. Il server deve salvare un ordine nel database.

D. Il client deve scaricare un singolo PDF.

---

### 3. Qual è un errore comune nel ragionare su WebSocket?

A. Considerare reconnect e heartbeat.

B. Valutare il comportamento dietro load balancer.

C. Assumere che qualsiasi requisito definito “real-time” richieda automaticamente WebSocket.

D. Considerare backpressure e fan-out.

---

### 4. Un servizio ordini pubblica un evento e non deve attendere che email, analytics e fulfillment completino il proprio lavoro. Quale modello è più adatto?

A. Chiamata sincrona obbligatoria a tutti i consumer.

B. Messaging asincrono con producer e consumer temporalmente disaccoppiati.

C. Una singola transazione database condivisa fra tutte le applicazioni.

D. UDP broadcast verso tutti i servizi.

---

### 5. Un message broker conferma che un messaggio è stato consegnato a un consumer. Cosa puoi concludere con certezza sul business?

A. L'intero processo di business è necessariamente completato exactly-once.

B. Il database del consumer è sicuramente stato aggiornato.

C. La delivery del messaggio e il completamento del business sono concetti distinti.

D. Il messaggio non potrà mai essere consegnato di nuovo.

---

### 6. Perché un consumer di messaggi dovrebbe spesso essere idempotente?

A. Perché i broker non possono trasportare più di un messaggio.

B. Perché retry, crash e redelivery possono portare lo stesso evento a essere elaborato più volte.

C. Perché idempotenza significa elaborare sempre il messaggio due volte.

D. Soltanto perché HTTP richiede idempotenza ai consumer AMQP.

---

### 7. Quando gRPC è particolarmente interessante?

A. Quando due servizi controllati dalla stessa organizzazione beneficiano di contratti tipizzati, client generati e streaming.

B. Quando serve una pagina HTML completamente statica.

C. Quando non vogliamo definire alcun contratto.

D. Soltanto quando il database è PostgreSQL.

---

### 8. Quale affermazione su gRPC è più accurata?

A. Protocol Buffers è comunemente il formato predefinito, ma gRPC non va mentalmente ridotto a “protobuf = gRPC”.

B. gRPC è semplicemente un WebSocket con JSON.

C. gRPC funziona esclusivamente con una singola request e response.

D. gRPC elimina tutti i failure di rete.

---

### 9. Quale proprietà appartiene a TCP?

A. Preserva automaticamente i confini dei messaggi applicativi.

B. Fornisce un byte stream affidabile e ordinato.

C. Non esegue alcuna forma di congestion control.

D. Ogni pacchetto perso viene ignorato per privilegiare dati più recenti.

---

### 10. Perché un'applicazione sopra TCP deve ancora definire framing o delimitazione dei messaggi?

A. Perché TCP presenta un byte stream e non conserva i confini delle singole write applicative.

B. Perché TCP converte sempre i payload in UDP.

C. Perché TCP può trasferire soltanto testo.

D. Perché ogni messaggio TCP deve essere un documento JSON completo.

---

### 11. Quale scenario può favorire un modello datagram-oriented o una tecnologia costruita sopra UDP?

A. Un workload dove alcuni dati vecchi possono diventare inutili e la freschezza è più importante della ritrasmissione di ogni dato perso.

B. Una transazione bancaria dove ogni modifica deve essere elaborata esattamente una volta grazie a UDP.

C. Un sistema dove l'applicazione pretende che UDP fornisca delivery ordinata nativa.

D. Un protocollo che necessita obbligatoriamente del byte stream TCP.

---

### 12. Quale affermazione su HTTP/3 e QUIC è corretta?

A. Dimostra che HTTP significa sempre TCP.

B. QUIC usa UDP come base ma implementa sopra di esso funzionalità come reliability, congestion control e stream multiplexing.

C. QUIC elimina ogni possibile packet loss.

D. QUIC è una forma di REST resource naming.

---

### 13. Quale URL esprime meglio un resource model REST convenzionale?

A. `/getProductById?id=42`

B. `/products/42`

C. `/executeProductLookup/42`

D. `/database/products/table-row/42`

---

### 14. Quale affermazione sui nomi plurali nelle API REST è più corretta?

A. REST impone formalmente che ogni URL contenga nomi plurali.

B. Sono una convenzione utile e coerente, non una legge fondamentale di REST.

C. Sono vietati perché REST richiede soltanto verbi.

D. Sono validi soltanto con GraphQL.

---

### 15. Perché esporre direttamente tabelle e relazioni ORM come API può essere un cattivo design?

A. Perché HTTP non può trasportare dati provenienti da database relazionali.

B. Perché il resource model pubblico dovrebbe rappresentare il dominio dei client e non necessariamente la struttura di persistenza interna.

C. Perché ogni API deve usare esclusivamente file.

D. Perché gli ID database non possono mai apparire negli URL.

---

### 16. Hai una risorsa review con identità propria. Quale design può essere perfettamente ragionevole?

A. Solo `/products/42/reviews/834`, perché una risorsa nested non può mai avere URL indipendente.

B. `/products/42/reviews` per la collection nel contesto del prodotto e `/reviews/834` per la review identificata globalmente.

C. Soltanto `/getReview?product=42&review=834`.

D. Nessun endpoint: le relazioni non appartengono a REST.

---

### 17. Qual è il problema principale di nesting eccessivo come:

`/customers/17/orders/913/items/6/adjustments/2`

A. Gli URL REST non possono contenere più di due slash.

B. Può legare troppo l'identità della risorsa alla gerarchia e rendere routing, ownership e accesso indipendente più complessi.

C. HTTP rifiuta automaticamente URL con cinque segmenti.

D. Impedisce l'uso di TLS.

---

### 18. Devi modellare il refund di un pagamento con autorizzazioni, audit e side effect propri. Quale ragionamento è migliore?

A. Ogni workflow deve essere obbligatoriamente `PATCH status=refunded`.

B. Il refund può meritare una risorsa o operazione di dominio esplicita invece di essere ridotto meccanicamente a CRUD.

C. REST vieta completamente le operazioni di dominio.

D. Basta modificare direttamente la riga del database dal client.

---

## Dopo il quiz

Durante la fase di studio, rispondi senza guardare il file delle soluzioni.

La correzione dovrà concentrarsi non solo sulla lettera corretta ma sul motivo per cui le alternative rappresentano cattivi modelli mentali.
