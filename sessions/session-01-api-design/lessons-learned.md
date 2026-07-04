# Note – Sessione 01: API Design

## API come contratto

Una API non è soltanto un endpoint che restituisce JSON.

È un contratto tra client e server: definisce quali operazioni sono disponibili, quali dati il client deve inviare, quali risposte può aspettarsi e quali errori possono verificarsi.

Una buona API espone un’interfaccia stabile e nasconde i dettagli interni dell’implementazione.

## API come astrazione

Il client non deve sapere come il server salva un utente, quale database usa o quali servizi interni vengono chiamati.

Il client deve conoscere solo il contratto pubblico: endpoint, metodo, payload, risposta, errori e vincoli.

## API come confine

Una API crea un confine chiaro tra componenti o servizi.

Per esempio:

- servizio utenti;
- servizio ordini;
- servizio pagamenti;
- servizio notifiche.

Ogni servizio espone funzionalità precise senza rivelare le proprie scelte interne.

## REST

REST è adatto quando il dominio è fatto di risorse chiare.

Esempi:

- `/users`
- `/orders`
- `/products`

Usa i metodi HTTP:

- GET per leggere;
- POST per creare;
- PUT/PATCH per aggiornare;
- DELETE per eliminare.

REST è spesso una buona scelta per CRUD, gestionali, API pubbliche o semi-pubbliche, integrazioni e sistemi dove semplicità, caching HTTP e debugging sono importanti.

## GraphQL

GraphQL è utile quando i client hanno bisogno di dati molto specifici, variabili o annidati.

Risolve soprattutto due problemi:

- over-fetching: il client riceve più dati del necessario;
- under-fetching: il client riceve pochi dati e deve fare altre chiamate.

È adatto a UI complesse, mobile app e dashboard con schermate molto diverse.

Il costo è maggiore complessità lato server: schema, resolver, autorizzazioni campo per campo, caching e controllo delle query costose.

## gRPC

gRPC è adatto soprattutto alla comunicazione interna tra servizi.

È utile quando:

- controlliamo entrambi i lati;
- vogliamo contratti tipizzati;
- servono buone performance;
- serve streaming;
- il traffico è server-to-server.

Non è di solito la prima scelta per API pubbliche browser-first.

## Principi di design

Una buona API dovrebbe essere:

- consistente;
- semplice;
- sicura;
- performante.

Consistenza significa non cambiare naming e stile da un endpoint all’altro.

Semplicità significa che il comportamento deve essere prevedibile.

Sicurezza significa autenticazione, autorizzazione, validazione input, rate limiting e gestione corretta degli errori.

Performance significa evitare payload enormi, round trip inutili, assenza di paginazione, query inefficienti e caching assente.

## Risposta da colloquio

Una API è un contratto stabile tra sistemi. Definisce quali operazioni un client può richiedere, quali dati deve inviare, quali risposte può aspettarsi, quali errori possono verificarsi e quali vincoli deve rispettare. Una buona API nasconde i dettagli interni, espone un’interfaccia coerente e permette ai sistemi di evolvere senza accoppiarsi troppo.
