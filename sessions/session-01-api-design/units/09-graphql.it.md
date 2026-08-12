# Unità 09 – GraphQL

[English](09-graphql.md) | [Italiano](09-graphql.it.md)

## Obiettivo didattico

Comprendere GraphQL come linguaggio di query tipizzato e modello di esecuzione che permette ai client di richiedere una forma specifica della risposta.

Le principali domande di design sono:

- Quale contratto espone lo schema?
- Quanta flessibilità di query devono ricevere i client?
- Dove vive l'autorizzazione?
- Come vengono rappresentati i fallimenti parziali?
- Come impediamo query costose o abusive?
- Quando GraphQL risolve realmente un problema del client meglio di una API resource-oriented?

## Perché esiste GraphQL

Le API tradizionali a risorse espongono spesso forme della risposta definite dal server.

Un client può ricevere:

- più campi di quelli necessari;
- meno oggetti correlati di quelli necessari;
- diverse risorse che richiedono più richieste.

GraphQL cambia il modello di interazione.

Il client descrive i campi che desidera e il server esegue quella selezione rispetto a uno schema.

È particolarmente utile quando client o schermate differenti richiedono viste sostanzialmente differenti di dati correlati.

## Lo schema è il contratto

Lo schema GraphQL definisce il type system pubblico.

Descrive:

- object type;
- field;
- argument;
- scalar type;
- relazioni;
- entry point delle query;
- entry point delle mutation;
- nullability.

Esempio concettuale:

User

- id
- name
- posts

Post

- id
- title
- author

Lo schema non è semplice documentazione.

È un contratto eseguibile utilizzato per validazione ed esecuzione.

## Strong typing

Uno schema GraphQL fornisce ai client informazioni esplicite sui field disponibili e sui relativi tipi.

Questo supporta:

- validazione prima dell'esecuzione;
- tooling di introspection;
- generazione di tipi client;
- completamento negli IDE;
- discoverability.

Strong typing non garantisce automaticamente un buon domain design.

Uno schema modellato male può essere comunque fortemente tipizzato.

## Query

Le query leggono dati.

Il client può richiedere soltanto i field necessari per una specifica vista.

Esempio concettuale:

user(id: 42)

- name
- posts
  - title

La risposta segue la forma dei field richiesti.

Questo riduce alcune forme di over-fetching.

Può anche ridurre under-fetching quando informazioni correlate possono essere ottenute tramite una singola operazione.

## Mutation

Le mutation rappresentano operazioni che possono produrre side effect.

Esempi:

- createUser;
- createOrder;
- cancelOrder;
- updateProfile.

Una mutation può restituire field selezionati dal client esattamente come una query.

È utile perché il client può richiedere immediatamente le informazioni aggiornate necessarie dopo l'operazione.

## Query e mutation sono categorie semantiche

GraphQL non mappa direttamente le operazioni CRUD sui verbi HTTP.

Tipicamente, quando GraphQL viene trasportato su HTTP:

- le query possono essere inviate tramite GET o POST secondo il contratto di trasporto;
- le mutation vengono normalmente inviate tramite POST perché possono causare side effect.

Il tipo di operazione GraphQL descrive la semantica dell'esecuzione GraphQL.

Il metodo HTTP descrive la semantica del trasporto.

Sono livelli collegati ma non identici.

## Un endpoint non significa una sola operazione

Un servizio GraphQL viene comunemente esposto tramite un endpoint come:

`/graphql`

Questo non significa che il servizio possieda una sola operazione.

Lo schema può esporre molti field query e mutation dietro quell'endpoint.

Il contratto si sposta quindi da molti URL di risorse verso un singolo grafo tipizzato di operazioni e field.

## Over-fetching e under-fetching

### Over-fetching

Il server restituisce field non necessari al client.

GraphQL consente ai client di selezionare un insieme più piccolo di field.

### Under-fetching

La prima risposta non contiene abbastanza dati correlati, costringendo a richieste aggiuntive.

GraphQL permette a una singola operazione di attraversare field correlati.

Sono vantaggi reali, ma non significano che GraphQL produca sempre meno chiamate backend.

I resolver possono comunque eseguire molte operazioni interne.

Numero di richieste client-facing e costo di esecuzione backend sono problemi distinti.

## Il problema N+1

Una query GraphQL può sembrare compatta mentre genera accessi backend inefficienti.

Supponiamo che una query richieda:

- 100 post;
- autore di ogni post.

Un resolver ingenuo può:

1. recuperare 100 post;
2. effettuare una query aggiuntiva per l'autore di ciascun post.

Otteniamo 101 query backend.

Mitigazioni comuni:

- batching;
- loader request-scoped;
- join;
- prefetching;
- caching.

GraphQL risolve la flessibilità della forma della risposta.

Non risolve automaticamente l'efficienza dell'accesso ai dati.

## La nullability conta

GraphQL distingue field nullable e non-null.

Questo influenza la propagazione dei failure.

Se un field nullable fallisce durante l'esecuzione, quel field può diventare `null` mentre i dati sibling rimangono disponibili.

Se fallisce un field non-null, l'errore può propagarsi verso l'alto finché viene raggiunto un confine nullable.

La nullability dello schema non è quindi semplice decorazione del tipo.

Influenza il comportamento dei failure.

## Request error ed execution error

Questa distinzione è fondamentale.

### Request error

Un request error avviene prima che la normale esecuzione possa procedere.

Esempi:

- sintassi GraphQL non valida;
- validation failure;
- field sconosciuto;
- coercion non valida delle variabili;
- selezione ambigua dell'operazione.

In questi casi:

- l'esecuzione normale non procede;
- la risposta contiene `errors`;
- `data` è assente.

### Execution error

Un execution error si verifica durante la risoluzione di un field.

Esempi:

- failure di un servizio downstream;
- eccezione del resolver;
- failure nella coercion del risultato;
- authorization failure implementata durante la risoluzione del field.

L'esecuzione può continuare per altri field.

La risposta può quindi contenere contemporaneamente:

- `data` parziale;
- `errors`.

Questa è una delle differenze più importanti di GraphQL rispetto a un semplice modello request all-or-nothing.

## GraphQL non “restituisce sempre 200”

GraphQL definisce struttura e semantica delle GraphQL response.

Il trasporto HTTP è un problema separato.

Una regola semplicistica come:

> Ogni errore GraphQL restituisce HTTP 200

non è un modello sufficientemente accurato.

Failure del trasporto e request failure possono utilizzare appropriatamente status HTTP di errore.

Gli execution error possono invece produrre una GraphQL response valida contenente dati parziali.

Il mapping HTTP concreto dipende dal contratto GraphQL-over-HTTP implementato dal servizio.

La specifica GraphQL-over-HTTP è ancora in evoluzione, quindi client e server devono documentare esplicitamente il comportamento di trasporto scelto.

## Forma degli errori

Una GraphQL response può includere un array `errors`.

Gli errori possono trasportare informazioni come:

- message;
- source location;
- response path;
- extension definite dall'implementazione.

Il path è particolarmente utile per gli execution error perché identifica quale field selezionato è fallito.

I metadati applicativi degli errori dovrebbero essere stabili e machine-readable quando i client devono reagire programmaticamente.

## I dati parziali sono una feature e una responsabilità

Le response parziali possono aumentare la resilienza.

Esempio:

Una dashboard richiede:

- profilo utente;
- raccomandazioni;
- notifiche.

Se il servizio recommendations fallisce, l'applicazione può comunque mostrare profilo e notifiche.

Ma il successo parziale complica:

- osservabilità;
- gestione errori client;
- semantica di prodotto;
- caching;
- retry.

I client devono sapere se dati mancanti siano accettabili per uno specifico caso d'uso.

## Design dello schema

Un buon schema dovrebbe riflettere concetti utili del dominio anziché artefatti implementativi.

Evitare di esporre ciecamente:

- tabelle database;
- relazioni ORM;
- confini dei microservizi interni.

Lo schema è un grafo pubblico destinato ai client.

Deve ottimizzare per un modello di dominio client-facing coerente.

## Evitare nesting eccessivo

GraphQL permette ai client di attraversare profondamente le relazioni.

Questa flessibilità può diventare pericolosa.

Una query potrebbe chiedere:

user
→ posts
→ comments
→ authors
→ followers
→ posts
→ comments

Traversal profondi possono generare:

- alto costo CPU;
- risposte enormi;
- amplificazione delle query database;
- fan-out di richieste downstream.

Un servizio di produzione necessita di controlli sul costo delle query.

## Depth limiting

Una mitigazione consiste nel limitare la profondità del nesting.

Per esempio, un servizio può rifiutare operazioni più profonde di una soglia configurata.

I depth limit sono semplici e utili, ma da soli non bastano.

Una query poco profonda può essere comunque costosissima.

Esempio:

richiedere 100.000 elementi da una collection di primo livello.

## Complexity analysis

Un approccio più forte assegna costi stimati ai field o alle operazioni.

Il sistema può rifiutare query il cui costo calcolato supera una soglia.

Il costo può tenere conto di:

- field nested;
- dimensioni delle collection;
- resolver costosi;
- fan-out;
- chiamate esterne.

Depth e complexity control si completano.

## La pagination serve ancora

GraphQL non elimina la pagination.

Le collection grandi devono comunque essere limitate.

Le API GraphQL espongono comunemente modelli di pagination basati su:

- cursor;
- edge;
- node;
- page information.

Gli stessi problemi discussi per REST restano validi:

- ordinamento deterministico;
- page size limitato;
- continuation state;
- dataset dinamici.

La selezione dei field da parte del client non giustifica collection senza limiti.

## L'autorizzazione è più difficile di un controllo per endpoint

In una API in stile REST l'autorizzazione può spesso essere ragionata per endpoint o risorsa.

GraphQL può richiedere molti field correlati in una sola operazione.

L'autorizzazione può quindi dover considerare:

- permessi object-level;
- permessi field-level;
- traversal delle relazioni;
- permessi sulle mutation.

Un utente autorizzato a vedere un oggetto `User` non è necessariamente autorizzato a vedere ogni field di quell'oggetto.

La flessibilità dello schema aumenta la granularità richiesta all'autorizzazione.

## Authentication rimane separata

GraphQL non definisce l'autenticazione applicativa.

L'autenticazione avviene tipicamente attraverso il trasporto o l'infrastruttura applicativa circostante.

Esempi:

- session cookie;
- bearer token;
- OAuth access token.

Il livello di esecuzione GraphQL applica poi l'autorizzazione usando identità e claim risultanti.

## Caching

GraphQL cambia l'ergonomia del caching.

Le API HTTP a risorse espongono spesso risorse GET naturalmente indirizzabili che gli intermediari possono mettere in cache usando la semantica HTTP standard.

GraphQL invia comunemente molte operazioni differenti a un singolo endpoint.

Il caching si sposta quindi spesso verso:

- normalized cache client;
- persisted query;
- application cache;
- resolver-level caching;
- strategie CDN progettate specificamente per GraphQL.

GraphQL può essere cachato, ma richiede un modello mentale differente.

## Persisted operation

Un servizio può registrare operazioni approvate e permettere ai client di inviare un identificatore anziché testo di query arbitrario.

Possibili vantaggi:

- richieste più piccole;
- allow-listing più semplice;
- miglior controllo della query complexity;
- caching prevedibile;
- superficie di attacco ridotta.

Le persisted operation scambiano flessibilità con controllo operativo.

## Evoluzione dello schema

Gli schemi GraphQL sono progettati per evolvere in modo compatibile.

Modifiche comunemente compatibili:

- aggiungere nuovi field;
- aggiungere nuovi type;
- aggiungere argument opzionali.

Modifiche potenzialmente breaking:

- rimuovere field;
- cambiare incompatibilmente i type dei field;
- rendere non-null un field nullable senza migrazione sicura;
- rimuovere enum value usati dai client;
- cambiare la semantica di un field.

I metadata di deprecazione permettono ai vecchi field di rimanere disponibili mentre i client migrano.

## Quando GraphQL è un candidato forte

GraphQL è interessante quando:

- i client richiedono forme della risposta sostanzialmente differenti;
- i dati sono fortemente collegati;
- i team frontend necessitano iterazione rapida e indipendente;
- uno schema tipizzato e discoverable ha valore;
- over-fetching e under-fetching sono problemi reali del prodotto.

## Quando GraphQL può essere superfluo

GraphQL può essere eccessivo quando:

- il dominio espone risorse semplici e stabili;
- le forme della risposta variano poco;
- il caching HTTP convenzionale è molto importante;
- la semplicità operativa è una priorità;
- il team non necessita traversal controllato dal client.

Scegliere GraphQL perché è di moda aggiunge complessità senza necessariamente aggiungere valore.

## REST versus GraphQL non è una classifica qualitativa

REST e GraphQL ottimizzano modelli di interazione differenti.

Una API HTTP resource-oriented enfatizza:

- risorse definite dal server;
- semantica HTTP;
- URL indirizzabili individualmente.

GraphQL enfatizza:

- selezione dei field definita dal client;
- traversal di un grafo tipizzato;
- esecuzione guidata dallo schema.

Un sistema può anche legittimamente esporre entrambi per consumer differenti.

## Errori comuni

### “GraphQL restituisce sempre HTTP 200”

Troppo semplicistico.

Bisogna distinguere semantica delle GraphQL response e semantica del trasporto HTTP.

### “Una richiesta GraphQL significa una query database”

Errato.

I resolver possono produrre fan-out su molte operazioni backend.

### “GraphQL elimina la pagination”

Errato.

Le collection grandi richiedono ancora limiti.

### “I client possono chiedere qualsiasi cosa, quindi l'autorizzazione non serve”

Esattamente il contrario.

Il traversal flessibile richiede spesso autorizzazione più granulare.

### “Il depth limiting risolve le query costose”

Non da solo.

Query larghe ma poco profonde possono comunque essere molto costose.

### “GraphQL è REST con un endpoint”

Modello mentale errato.

Type system, semantica di esecuzione e selezione dei field da parte del client cambiano fondamentalmente il contratto.

### “GraphQL è sempre migliore per il frontend”

Soltanto quando la sua flessibilità risolve problemi che giustificano la maggiore complessità operativa e dello schema.

## Risposta da colloquio

GraphQL è un linguaggio di query tipizzato e un modello di esecuzione nel quale lo schema definisce il contratto e i client selezionano i field necessari.

Il suo vantaggio principale è la flessibilità per client con requisiti di dati differenti o profondamente correlati, riducendo alcune forme di over-fetching e under-fetching.

Il trade-off è una maggiore complessità server. Devo progettare confini dello schema, prevenire accessi N+1, paginare le collection, controllare depth e query complexity, gestire autorizzazione field-level e progettare il caching diversamente.

Distinguo inoltre gli errori GraphQL dagli errori HTTP. Un request error può impedire completamente l'esecuzione, mentre un execution error può produrre dati parziali insieme all'array `errors`. Per questo “GraphQL restituisce sempre HTTP 200” non è una regola di design sufficientemente accurata.

## Esercizi per lo studio successivo

1. Modella un piccolo schema GraphQL ecommerce con Product, Review, User e Order.
2. Progetta una query che dimostri intenzionalmente la riduzione dell'over-fetching.
3. Costruisci un esempio concettuale N+1 e proponi batching.
4. Spiega come la nullability influenza la propagazione degli execution error.
5. Classifica alcuni esempi come request error o execution error.
6. Progetta regole di autorizzazione dove il nome pubblico di User è visibile ma l'email è riservata.
7. Crea un attacco con query profonda e uno con query poco profonda ma costosa.
8. Confronta strategie di caching REST e GraphQL per un catalogo prodotti.
9. Decidi se un pannello amministrativo CRUD beneficia realmente di GraphQL.
10. Progetta la deprecazione compatibile di un vecchio field GraphQL.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- GraphQL come soluzione per la forma della risposta controllata dal client;
- schema e type system;
- query per leggere dati;
- mutation per modificare dati;
- selezione di field nested;
- dati parziali e field `errors` nella response;
- schema design modulare;
- depth limit per query nested.

Il materiale pubblico raffina ed estende quel modello:

- request error ed execution error GraphQL vengono separati esplicitamente;
- viene respinta come troppo ampia l'affermazione secondo cui GraphQL “restituisce sempre HTTP 200”;
- semantica GraphQL e semantica del trasporto GraphQL-over-HTTP vengono separate;
- vengono incluse nullability e propagazione degli errori;
- vengono introdotti N+1 e batching;
- il query depth viene affiancato dalla complexity analysis;
- la pagination rimane necessaria per collection grandi;
- l'autorizzazione viene trattata a granularità object e field;
- vengono inclusi caching e persisted operation;
- evoluzione e deprecazione dello schema vengono trattate come problemi di gestione del contratto.
