# Unità 06 – Design delle risorse REST

[English](06-rest-resource-design.md) | [Italiano](06-rest-resource-design.it.md)

## Obiettivo didattico

Modellare un dominio applicativo come insieme di risorse stabili e comprensibili invece di progettare endpoint come una collezione di nomi di procedure remote.

Le domande fondamentali sono:

- Quali concetti meritano una propria identità?
- Quali identificatori devono rimanere stabili?
- Quali relazioni appartengono all'API pubblica?
- Quale rappresentazione devono scambiarsi i client?
- Quali dettagli devono rimanere nascosti dietro l'interfaccia?

## REST parte dalle risorse

L'astrazione centrale di REST è la risorsa.

Una risorsa è un target concettuale identificabile.

Esempi:

- un utente;
- un prodotto;
- un ordine;
- una collezione di ordini;
- il meteo di oggi in una località;
- lo stato corrente di un deployment.

Una risorsa non deve essere confusa con:

- una riga del database;
- un modello ORM;
- un file;
- uno specifico oggetto JSON.

Questi possono essere dettagli implementativi o rappresentazioni di una risorsa.

## Risorsa e rappresentazione

Una risorsa è il concetto indirizzato.

Una rappresentazione è costituita dai dati trasferiti per descrivere uno stato corrente o desiderato di quella risorsa.

Per esempio:

`/products/42`

può identificare la risorsa prodotto.

Il server può rappresentarla oggi come JSON e usare un altro media type in un'interazione differente senza cambiare la risorsa concettuale.

Questa separazione permette a implementazione e rappresentazione di evolvere indipendentemente dall'identità della risorsa.

## Identificatori delle risorse

Le risorse hanno bisogno di identificatori utilizzabili dai client in modo consistente.

Buoni identificatori dovrebbero normalmente riflettere concetti stabili del dominio anziché dettagli dell'implementazione interna.

Per esempio:

- `/products`
- `/products/42`
- `/orders/913`
- `/users/17/orders`

Sono convenzioni API comuni perché leggibili e prevedibili.

La grafia esatta o l'uso del plurale non determina se un'architettura sia RESTful.

La proprietà più importante è che gli identificatori facciano riferimento in modo consistente a risorse con semantica stabile.

## Collezioni e membri

Molte API espongono sia collezioni sia singole risorse.

Convenzione tipica:

| Identificatore | Significato |
|---|---|
| `/products` | collezione prodotti |
| `/products/42` | singolo prodotto |
| `/orders` | collezione ordini |
| `/orders/913` | singolo ordine |

I metodi HTTP esprimono poi la semantica richiesta su tali risorse.

Questo è generalmente più chiaro rispetto a codificare verbi CRUD generici negli identificatori.

Preferire:

`GET /products`

rispetto a una convenzione come:

`GET /getProducts`

quando l'operazione è naturalmente rappresentabile come recupero della risorsa products.

## Perché i sostantivi sono normalmente utili

Identificatori come:

- `/products`;
- `/orders`;
- `/users`;

mantengono l'interfaccia pubblica concentrata sui concetti del dominio.

Identificatori come:

- `/getProducts`;
- `/createOrder`;
- `/deleteUser`;

spesso duplicano informazioni già espresse dai metodi HTTP e fanno assomigliare l'interfaccia a RPC.

Questo non significa che ogni verbo in un URI sia proibito.

Alcuni concetti di dominio sono naturalmente azioni, processi o comandi e possono meritare una modellazione esplicita.

La domanda importante è se l'API espone un modello coerente di risorse, non se elimina meccanicamente ogni verbo.

## Non mappare direttamente il database

Un errore comune consiste nell'esporre ogni tabella come risorsa API.

Schema del database e API pubblica hanno obiettivi differenti.

Il database può contenere:

- tabelle associative;
- record interni di audit;
- strutture denormalizzate;
- identificatori specifici della persistenza;
- entità esclusivamente implementative.

L'API pubblica dovrebbe modellare i concetti necessari ai client.

Il confine di una risorsa è una decisione di API design, non un export automatico dell'ORM.

## Relazioni

Le risorse sono spesso in relazione tra loro.

Per esempio:

- un prodotto ha recensioni;
- un cliente ha ordini;
- un ordine ha line item.

Un identificatore nested leggibile può essere:

`/products/42/reviews`

quando la relazione con il prodotto 42 è centrale per il significato della collezione.

Le risorse nested possono rendere evidenti ownership e contesto.

## Evitare nesting eccessivo

Gerarchie profonde possono diventare fragili.

Per esempio, un identificatore concettualmente simile a:

`/customers/17/orders/913/items/6/adjustments/2`

può esporre troppo accoppiamento strutturale.

Domande da porsi:

- La risorsa figlia possiede una propria identità?
- Può essere indirizzata indipendentemente?
- Può cambiare parent?
- La relazione col parent è necessaria per comprenderla?
- Le regole di autorizzazione sono realmente limitate dal parent?

Se una risorsa possiede identità indipendente, un identificatore più piatto può essere più chiaro.

## Identità e ownership sono differenti

Supponiamo che la recensione 834 appartenga al prodotto 42.

Possono avere senso entrambi:

- `/products/42/reviews`
- `/reviews/834`

Il primo identifica una collezione nel contesto di un prodotto.

Il secondo identifica una singola recensione indipendentemente.

Collezioni nested e membri indirizzabili globalmente possono convivere.

## La stabilità semantica conta

Un identificatore dovrebbe continuare a riferirsi nel tempo allo stesso tipo concettuale di risorsa.

I client diventano accoppiati agli identificatori pubblici.

Cambiare un'implementazione è generalmente più semplice che cambiare la semantica pubblica delle risorse.

Questo è uno dei motivi per cui REST incoraggia la separazione tra:

- identificatori pubblici;
- rappresentazioni;
- dettagli implementativi.

## Granularità delle risorse

Le risorse possono essere troppo grandi oppure troppo piccole.

### Troppo grandi

Un unico enorme endpoint che restituisce un intero dominio può creare:

- payload enormi;
- elaborazione costosa;
- caching difficile;
- confini di autorizzazione troppo ampi;
- forte accoppiamento tra client.

### Troppo piccole

Un'API che espone indipendentemente ogni minuscolo oggetto interno può creare:

- round trip eccessivi;
- client troppo chatty;
- orchestrazione complessa;
- leakage del design interno.

La granularità corretta dipende dai workflow dei client e dai confini di consistenza.

## Modellare le risorse prima degli endpoint

Un processo di design utile è:

1. individuare i concetti importanti del dominio;
2. individuare quali concetti richiedono identità pubblica stabile;
3. individuare collezioni e relazioni;
4. stabilire cosa i client devono recuperare o modificare;
5. definire le rappresentazioni;
6. applicare la semantica HTTP;
7. revisionare naming e consistenza.

Partire troppo presto dai nomi degli endpoint produce spesso accidentalmente un'interfaccia RPC.

## CRUD non è il modello del dominio

Le operazioni CRUD sono meccanismi utili, ma un dominio contiene spesso concetti più ricchi.

Consideriamo un ordine.

Il suo lifecycle può includere:

- creazione;
- pagamento;
- cancellazione;
- spedizione;
- rimborso.

Trattare ogni transizione di business come aggiornamento arbitrario di un campo può nascondere invarianti importanti.

Per esempio modificare:

`status = "refunded"`

può non essere equivalente a eseguire un rimborso.

Quest'ultimo potrebbe richiedere:

- interazione con il payment provider;
- autorizzazione;
- record di audit;
- effetti sull'inventario;
- notifiche.

Il design resource-oriented deve comunque rappresentare la reale semantica del business.

## Comandi e operazioni simili ad azioni

Non tutte le operazioni si adattano elegantemente al CRUD semplice.

Per una transizione del dominio le opzioni possono includere:

- modificare lo stato di una risorsa;
- creare una risorsa subordinata che rappresenta l'azione;
- esporre un'operazione esplicita del dominio.

Per esempio, invece di fingere che un rimborso sia soltanto un aggiornamento arbitrario, un'API potrebbe modellare il refund come risorsa propria.

Il modello corretto dipende dal dominio.

REST resource design non è una gara per eliminare ogni verbo da ogni URI.

## Consistenza

Qualunque convenzione venga scelta dovrebbe rimanere prevedibile.

Se le collection sono plurali, usare il plurale in modo consistente.

Se gli identificatori sono UUID, non esporre improvvisamente sequence ID del database altrove senza ragione.

Se le relazioni vengono annidate in base all'ownership, applicare lo stesso principio alle risorse simili.

La consistenza riduce il carico cognitivo dei consumer dell'API.

## Nascondere l'implementazione

Un client non dovrebbe aver bisogno di conoscere:

- nomi delle tabelle;
- nomi delle classi ORM;
- quale microservizio possiede i dati;
- quante chiamate interne avvengono;
- come viene memorizzata la risorsa.

Questa libertà permette all'implementazione server di evolvere mantenendo il contratto pubblico.

## Errori comuni

### “Una risorsa è una riga del database”

Troppo limitante.

Una risorsa è un target concettuale dotato di identità.

La sua rappresentazione può essere composta usando diversi sistemi.

### “REST richiede sostantivi plurali”

No.

I nomi plurali delle collection sono una convenzione utile, non un vincolo che definisce REST.

### “Ogni endpoint che contiene un verbo non è RESTful”

Troppo semplicistico.

La questione importante è se l'API possiede una semantica coerente delle risorse e rispetta i vincoli architetturali.

### “Gli URL nested devono rispecchiare le relazioni tra oggetti”

Non automaticamente.

Un nesting profondo può esporre struttura implementativa e creare accoppiamento inutile.

### “Espongo l'ORM e l'API è finita”

Pericoloso.

Persistence model e contratto pubblico evolvono per motivi differenti.

### “Fare PATCH del campo status modella qualsiasi workflow”

Non necessariamente.

Le transizioni di business possono possedere invarianti e side effect che meritano modellazione esplicita.

## Risposta da colloquio

Quando progetto una REST API parto identificando risorse stabili del dominio invece di scrivere nomi di endpoint basati sui verbi.

Una risorsa è un'entità o collezione concettuale dotata di identificatore; non è necessariamente una riga del database. I client scambiano rappresentazioni di quelle risorse mentre i dettagli implementativi rimangono nascosti.

Normalmente uso convenzioni URI prevedibili come nomi plurali per le collection perché aumentano la consistenza, ma non tratto queste convenzioni come la definizione di REST.

Evito anche di copiare automaticamente le relazioni del database in URL profondamente nested. Scelgo confini e granularità delle risorse sulla base di workflow del client, identità, ownership, autorizzazione e semantica reale del dominio.

## Esercizi per lo studio successivo

1. Modella le principali risorse di un ecommerce contenente prodotti, clienti, carrelli, ordini, pagamenti e rimborsi.
2. Decidi se una recensione debba essere indirizzabile soltanto attraverso il prodotto oppure anche tramite un proprio identificatore.
3. Trasforma un'API RPC con `/getUsers`, `/createUser` e `/deleteUser` in un'interfaccia resource-oriented.
4. Decidi se un rimborso d'ordine debba essere un aggiornamento di campo, un'azione oppure una risorsa propria.
5. Individua un caso in cui un nesting profondo delle risorse crea accoppiamento inutile.
6. Spiega perché un'API pubblica non dovrebbe rispecchiare automaticamente lo schema del database.
7. Progetta gli identificatori per “carrello corrente” e per un carrello storico e spiega la differenza semantica.

## Note di revisione della sorgente

La SOT privata fornisce utili convenzioni pratiche:

- modellare le entità del dominio come risorse;
- preferire identificatori resource-oriented rispetto a verbi CRUD;
- distinguere collection e singoli membri;
- usare risorse nested per esprimere relazioni significative.

Il materiale pubblico raffina queste idee:

- una risorsa REST è un mapping concettuale con identità, non semplicemente un'entità del database;
- le rappresentazioni sono separate dalle risorse;
- i sostantivi plurali vengono trattati come convenzione e non come requisito REST;
- gli identificatori nested vengono valutati in base a identità e ownership anziché generati meccanicamente;
- il design delle risorse pubbliche viene deliberatamente separato dallo schema di persistenza;
- le transizioni del dominio possono richiedere modelli più ricchi del CRUD generico.
