# Unità 12 – Sicurezza delle API

[English](12-api-security.md) | [Italiano](12-api-security.it.md)

## Obiettivo didattico

Ragionare sulla sicurezza delle API come sistema a più livelli invece che come checklist di controlli isolati.

Una API sicura deve considerare:

- sicurezza del trasporto;
- autenticazione;
- autorizzazione;
- gestione degli input;
- consumo delle risorse;
- confini di sicurezza del browser;
- secret e credenziali;
- dipendenze downstream;
- esposizione di rete;
- monitoraggio e incident response.

Nessun singolo meccanismo risolve tutti questi problemi.

## La sicurezza è stratificata

Un modello mentale utile è defense in depth.

Per esempio:

HTTPS
→ identità autenticata
→ autorizzazione
→ validazione input
→ accesso sicuro ai dati
→ limiti sulle risorse
→ monitoraggio

Il fallimento di un livello non dovrebbe compromettere automaticamente tutti gli altri.

## Partire dal threat model

Le decisioni di sicurezza dovrebbero iniziare da domande come:

- Chi può chiamare l'API?
- È pubblica o interna?
- Quali dati espone?
- Quali operazioni possono avere effetti irreversibili?
- Quali credenziali vengono usate?
- Cosa accade se un token viene rubato?
- Quali sistemi downstream sono considerati fidati?
- Quante risorse può consumare una richiesta?
- Cosa potrebbe ottenere un attaccante automatizzando le chiamate?

Sicurezza senza threat model diventa facilmente configurazione cargo-cult.

## Sicurezza del trasporto

La comunicazione API sensibile dovrebbe utilizzare TLS.

TLS protegge i dati in transito contro osservazione passiva e modifiche non rilevate all'interno del canale protetto.

TLS non sostituisce:

- autenticazione;
- autorizzazione;
- storage sicuro;
- input validation;
- sicurezza degli endpoint.

Un'applicazione può usare HTTPS ed essere comunque completamente vulnerabile a livello applicativo.

## Autenticazione

L'autenticazione stabilisce l'identità del caller.

Problemi di sicurezza includono:

- furto di credenziali;
- password deboli;
- bearer token esposti;
- token scaduti o validati in modo errato;
- sessioni insicure;
- validazione JWT non corretta;
- gestione insicura dei refresh token.

Il design dell'autenticazione è stato trattato nell'Unità 10.

## Autorizzazione

L'autorizzazione determina cosa può fare un principal autenticato.

I controlli possono avvenire a livello:

- funzione;
- oggetto;
- proprietà o field;
- tenant;
- stato del workflow.

Una identità autenticata valida non implica il permesso di accedere a ogni oggetto dello stesso tipo.

Il design dell'autorizzazione è stato trattato nell'Unità 11.

## Broken object-level authorization

Consideriamo:

`GET /invoices/100`

Un utente può accedere legittimamente alla fattura 100.

Cambiare l'identificatore in:

`GET /invoices/101`

non deve esporre la fattura di un altro cliente soltanto perché l'identificatore esiste.

Il server deve autorizzare lo specifico oggetto.

Non fare affidamento su:

- identificatori difficili da indovinare;
- frontend che nasconde oggetti estranei;
- ID sequenziali ritenuti segreti.

Gli object identifier identificano risorse.

Non sono credenziali di autorizzazione.

## Broken property-level authorization

Un client può essere autorizzato ad accedere a una risorsa senza poter leggere o modificare ogni proprietà.

Esempio User:

- nome pubblico;
- email;
- role;
- salary;
- flag interni.

Il server deve controllare esplicitamente quali proprietà possono essere:

- restituite;
- accettate come input;
- modificate.

Serializzare ciecamente tutte le proprietà ORM può esporre informazioni sensibili.

Applicare ciecamente tutti i field forniti dal client può permettere modifiche non autorizzate.

## Function-level authorization

Operazioni differenti possono richiedere autorità differenti.

Per esempio:

- viewer → read;
- editor → modifica contenuti;
- administrator → elimina account;
- finance operator → approva refund.

Nascondere una route amministrativa nella UI non la mette in sicurezza.

Il backend deve applicare il permesso.

## Input validation

Ogni input esterno deve essere considerato non fidato finché non viene validato.

Fonti includono:

- path parameter;
- query parameter;
- header;
- body JSON;
- file upload;
- message queue;
- webhook;
- risposte di API di terze parti.

La validazione deve considerare:

- tipo;
- formato;
- valori consentiti;
- lunghezza;
- limiti numerici;
- dimensione delle collection;
- invarianti del dominio.

La validazione riduce la superficie di attacco e impedisce a dati malformati di raggiungere livelli più profondi.

## Validazione non significa escaping

La validazione chiede:

> Questo input è accettabile per questa operazione?

Encoding, escaping o parameterization chiedono:

> Come può essere usato in sicurezza questo valore nello specifico interprete o contesto di output?

Entrambi possono essere necessari.

Uno non sostituisce l'altro.

## Injection

Injection avviene quando dati non fidati vengono interpretati come parte di un comando o query anziché come dati.

Possibili target:

- SQL;
- NoSQL;
- comandi del sistema operativo;
- LDAP;
- template engine;
- altri interpreti.

Una difesa fondamentale consiste nel mantenere separati dati e sintassi eseguibile.

Per i database questo significa comunemente usare query parametrizzate o API database progettate correttamente anziché concatenazione di stringhe.

La validazione rimane utile ma non dovrebbe essere l'unica difesa contro injection.

## Un ORM non impedisce automaticamente injection

Usare un ORM può ridurre la costruzione diretta di stringhe, ma query raw insicure o espressioni dinamiche possono reintrodurre vulnerabilità.

La sicurezza dipende da come viene usata l'astrazione.

La scelta del framework non elimina la necessità di comprendere il data flow.

## Consumo delle risorse

Ogni richiesta API consuma risorse.

Possibili costi:

- CPU;
- memoria;
- bandwidth;
- lavoro database;
- storage;
- chiamate API esterne;
- costo economico.

Un attaccante non necessita sempre di un exploit tradizionale.

Far eseguire ripetutamente lavoro legittimo ma costoso può bastare a degradare il servizio.

## Rate limiting

Il rate limiting limita la frequenza con cui un client può effettuare richieste o specifiche operazioni.

Possibili dimensioni:

- indirizzo IP;
- account;
- token;
- tenant;
- endpoint;
- operazione;
- capacità globale del servizio.

Operazioni differenti possono richiedere limiti differenti.

Per esempio:

- normali letture dei prodotti;
- tentativi di login;
- password recovery;
- verifica OTP;
- generazione di report costosi

non dovrebbero necessariamente condividere una sola policy.

## Rate limiting non è protezione DDoS completa

Rate limiting è un meccanismo di resource protection.

Grandi attacchi distribuiti possono richiedere anche controlli a livello:

- CDN;
- edge network;
- load balancer;
- infrastructure provider;
- network firewall;
- servizio specializzato di mitigazione DDoS.

Il rate limiting applicativo rimane utile ma non deve essere descritto come strategia DDoS completa.

## Limitare il consumo delle risorse

Le API devono considerare limiti su:

- upload;
- request body;
- page size;
- numero di record richiesti;
- GraphQL complexity;
- batch size;
- operazioni concorrenti;
- execution time;
- chiamate downstream.

Una singola richiesta può essere pericolosa anche con frequenza bassa.

## Timeout

Le chiamate verso servizi downstream dovrebbero generalmente avere un tempo di attesa limitato.

Senza timeout, dipendenze lente possono consumare:

- thread;
- connessioni;
- memoria;
- capacità dei worker.

Il design dei timeout va combinato con:

- retry policy;
- backoff;
- circuit breaking quando appropriato;
- concorrenza limitata.

Un timeout protegge risorse ma può creare esiti ambigui per alcune operazioni.

## CORS

Cross-Origin Resource Sharing controlla come i browser consentono a script provenienti da una origin di accedere a risorse di un'altra origin.

È costruito sopra il modello di sicurezza same-origin del browser.

Una tipica policy CORS definisce quali origin possono effettuare richieste cross-origin mediate dal browser e accedere alle risposte.

## CORS non è autenticazione API

CORS non deve essere usato come protezione principale di una API.

Un client non-browser può effettuare richieste HTTP senza essere soggetto all'enforcement CORS del browser.

Quindi:

origin consentita ≠ client autenticato

e:

origin bloccata ≠ attaccante bloccato a livello di rete.

L'API necessita ancora di autenticazione e autorizzazione proprie.

## Configurazione CORS

I permessi CORS dovrebbero normalmente essere limitati a ciò che richiede l'applicazione.

Aspetti importanti:

- origin consentite;
- metodi consentiti;
- header consentiti;
- richieste con credential;
- comportamento della preflight.

Configurazioni wildcard ampie senza comprendere il comportamento delle credential possono creare esposizione inutile.

## CSRF

Cross-Site Request Forgery sfrutta la capacità del browser di allegare automaticamente credenziali alle richieste.

Lo scenario classico riguarda web application autenticate tramite cookie.

Concettualmente:

1. la vittima è autenticata verso un'applicazione fidata;
2. il browser conserva un cookie di autenticazione;
3. la vittima visita contenuto controllato dall'attaccante;
4. l'attaccante induce il browser a inviare una richiesta state-changing;
5. il browser allega automaticamente la credenziale del sito fidato.

Il target può vedere una richiesta validamente autenticata anche se l'utente non intendeva effettuare l'azione.

## CSRF dipende dal modello delle credenziali

Il rischio CSRF dipende dal modo in cui le credenziali vengono allegate alle richieste.

Le applicazioni browser autenticate tramite cookie richiedono analisi CSRF esplicita perché i browser possono inviare automaticamente i cookie.

Una API dove JavaScript allega esplicitamente un bearer token mantenuto nello stato applicativo ha un threat model differente.

Questo non significa che tali applicazioni siano immuni dagli attacchi browser.

Per esempio XSS può esporre token o effettuare richieste autenticate dalla origin dell'applicazione.

## Difese CSRF

A seconda dell'architettura, i controlli possono includere:

- protezione CSRF fornita dal framework;
- synchronizer token;
- meccanismi double-submit correttamente progettati;
- cookie SameSite;
- validazione di Origin o relativo request context;
- custom header per browser API-driven;
- riautenticazione per operazioni particolarmente sensibili.

La difesa corretta dipende dall'architettura di autenticazione e del client.

## XSS

Cross-Site Scripting permette a contenuto controllato dall'attaccante di essere eseguito come contenuto attivo nel contesto browser dell'applicazione.

Possibili conseguenze:

- impersonificazione dell'account;
- furto di informazioni sensibili accessibili allo script;
- modifica del comportamento della pagina;
- richieste eseguite come l'utente;
- bypass di alcune difese browser-side.

XSS è principalmente un problema web-client/applicativo, ma influenza direttamente la sicurezza delle API quando il browser possiede capacità API autenticate.

## Prevenire XSS

Le difese dipendono dal contesto di output.

Principi importanti:

- output encoding appropriato al contesto;
- evitare DOM sink pericolosi;
- sanitizzazione HTML quando è necessario supportare HTML;
- funzionalità di sicurezza del framework;
- Content Security Policy come defense in depth.

CSP non deve essere considerata sostituto della corretta gestione dell'output.

## CSRF e XSS sono differenti

CSRF abusa della relazione autenticata del browser con un'altra applicazione.

XSS esegue contenuto controllato dall'attaccante all'interno del contesto browser fidato dell'applicazione.

Possono interagire.

Una vulnerabilità XSS può spesso compromettere protezioni CSRF perché lo script malevolo può operare con i privilegi dell'applicazione stessa.

## SSRF

Server-Side Request Forgery avviene quando un attaccante influenza il server facendogli effettuare richieste verso destinazioni indesiderate.

Possibili target:

- servizi interni;
- endpoint metadata cloud;
- servizi localhost;
- indirizzi di rete privati;
- sistemi esterni controllati dall'attaccante.

Le funzionalità che accettano URL richiedono particolare attenzione.

Esempi:

- target webhook;
- import di immagini;
- URL preview;
- callback URL;
- import remoto di documenti.

## Difese SSRF

A seconda del caso d'uso, le difese possono includere:

- allow-list delle destinazioni;
- validazione degli scheme;
- validazione degli indirizzi risolti;
- blocco dell'accesso a reti private/interne;
- controllo dei redirect;
- network egress policy;
- protezione degli endpoint cloud metadata.

La sola validazione sintattica dell'URL non è una difesa SSRF forte.

## Anche le API di terze parti sono input non fidato

I dati provenienti da un'altra API non devono ricevere automaticamente più fiducia del normale input utente.

Un servizio downstream può:

- essere compromesso;
- restituire dati malformati;
- cambiare comportamento;
- rispondere lentamente;
- restituire payload enormi;
- effettuare redirect inattesi.

Le integrazioni API esterne necessitano di:

- TLS;
- autenticazione dove richiesta;
- validazione;
- limiti di dimensione;
- timeout;
- redirect policy;
- gestione dei failure.

Esistono trust boundary anche tra servizi.

## WAF

Un Web Application Firewall può fornire un ulteriore livello difensivo.

Può aiutare a:

- bloccare pattern di richieste malevole conosciute;
- applicare policy grossolane sul traffico;
- fornire protezione virtuale durante il deployment di una correzione;
- aumentare la visibilità sul traffico sospetto.

Un WAF non può dimostrare che l'applicazione sia sicura.

Deve completare, non sostituire:

- autorizzazione corretta;
- query parametrizzate;
- validazione;
- secure coding;
- patching.

## Controlli di rete

Le API interne possono usare anche restrizioni network-level come:

- private network;
- firewall rule;
- VPN;
- service mesh policy;
- mutual TLS.

Questi controlli riducono l'esposizione.

Non dovrebbero normalmente essere l'unico meccanismo di autorizzazione.

Un attaccante o workload compromesso già all'interno della rete fidata può comunque tentare chiamate non autorizzate.

## Non fidarsi soltanto della rete

L'idea:

> È interno, quindi è fidato.

è fragile.

I sistemi moderni dovrebbero assumere che singoli servizi, credenziali o macchine possano essere compromessi.

Service identity e authorization rimangono utili anche nelle reti private.

## Secret

I secret includono:

- API key;
- password;
- signing key;
- encryption key;
- credenziali database;
- token di terze parti.

Non devono essere:

- committati nel source control;
- incorporati nel codice client pubblico;
- scritti inutilmente nei log;
- restituiti nei messaggi di errore.

Usare un appropriato meccanismo di secrets management e definire procedure di rotazione.

## Logging

Gli eventi rilevanti per la sicurezza devono essere osservabili.

Eventi utili:

- autenticazioni fallite;
- authorization denial;
- violazioni ripetute dei rate limit;
- operazioni amministrative sospette;
- modifica delle credenziali;
- indicatori di token replay;
- pattern di accesso anomali.

Ma i log stessi possono diventare depositi di dati sensibili.

Evitare di registrare:

- password;
- bearer token;
- refresh token;
- private key;
- dati personali non necessari.

## Error handling

Le risposte di errore devono fornire abbastanza informazioni ai client legittimi senza esporre dettagli interni inutili.

Evitare di mostrare:

- stack trace;
- query SQL;
- path interni;
- credenziali;
- secret;
- topologia infrastrutturale.

La diagnostica dettagliata appartiene a sistemi interni protetti di observability.

## Security header e controlli browser

Le applicazioni browser-facing possono beneficiare anche di controlli come:

- attributi sicuri dei cookie;
- Content Security Policy;
- restrizioni sul framing;
- protezioni dal MIME sniffing;
- referrer policy.

Completano la sicurezza API ma operano principalmente ai confini browser/applicazione.

## La sicurezza non può essere delegata a un singolo componente

Nessuno di questi è sufficiente da solo:

- HTTPS;
- API gateway;
- WAF;
- OAuth;
- JWT;
- VPN;
- CORS;
- rate limiting.

Ognuno protegge contro specifiche classi di minacce.

L'architettura determina come i controlli lavorano insieme.

## Review pratica della sicurezza

Per ogni operazione API chiedersi:

1. Chi può raggiungerla?
2. Come viene stabilita l'identità?
3. Quale azione viene autorizzata?
4. A quale esatto oggetto e proprietà si può accedere?
5. Quale input è non fidato?
6. Quale interprete utilizza quell'input?
7. Quanto lavoro può innescare la richiesta?
8. Quali sistemi downstream vengono contattati?
9. Quali credenziali vengono esposte?
10. Cosa viene registrato nei log?
11. Come verrà rilevato l'abuso?
12. Cosa succede quando le dipendenze falliscono?

Questo trasforma la sicurezza da elenco di prodotti a processo di design.

## Errori comuni

### “CORS protegge la mia API dagli attaccanti”

Errato.

CORS limita principalmente il comportamento dei browser.

L'API necessita ancora di autenticazione e autorizzazione.

### “Rate limiting impedisce DDoS”

Troppo forte.

È uno strumento di resource control, non una difesa completa contro distributed denial of service.

### “HTTPS rende sicura l'API”

Errato.

Protegge il canale di trasporto, non la logica applicativa.

### “Usiamo un ORM, quindi SQL injection è impossibile”

Errato.

Query raw o dinamiche insicure possono ancora introdurre injection.

### “CSRF riguarda ogni API esattamente allo stesso modo”

Errato.

Il rischio dipende fortemente dal comportamento del browser e da come vengono allegate le credenziali.

### “Con bearer token CSRF è impossibile”

Troppo assoluto.

Il threat model cambia, ma compromissioni browser come XSS possono ancora abusare delle capacità autenticate.

### “Un WAF corregge il codice vulnerabile”

No.

È un livello aggiuntivo, non un sostituto della correzione.

### “Le API interne non necessitano autorizzazione”

Pericoloso.

La posizione di rete da sola non è un forte trust boundary.

### “Le risposte delle API di terze parti sono dati fidati”

Errato.

Le dipendenze esterne costituiscono un altro input boundary.

## Risposta da colloquio

Tratto la sicurezza API come defense in depth.

Parto da TLS per la sicurezza del trasporto, quindi autentico il caller e autorizzo la specifica azione sulla specifica risorsa. Valido gli input non fidati, mantengo separati dati e sintassi degli interpreti, limito il consumo di risorse, proteggo le credenziali e progetto le chiamate downstream con timeout e validazione espliciti.

Distinguo inoltre i controlli browser dall'access control dell'API. CORS viene applicato dai browser e non sostituisce l'autenticazione. CSRF è particolarmente rilevante quando il browser allega automaticamente credenziali come cookie, mentre XSS può eseguire codice nel contesto browser fidato e abusare delle capacità API autenticate.

Il rate limiting è utile contro abuso e consumo delle risorse ma non è una soluzione DDoS completa. Analogamente WAF, VPN o API gateway rappresentano soltanto livelli di sicurezza.

Il principio centrale è identificare trust boundary e failure mode anziché assumere che un singolo prodotto renda sicura l'API.

## Esercizi per lo studio successivo

1. Costruisci il threat model di una API pubblica di checkout ecommerce.
2. Spiega perché modificare un invoice ID può rivelare broken object-level authorization.
3. Progetta rate limit differenti per login, ricerca prodotti e generazione report.
4. Spiega perché CORS non può proteggere una API da un client command-line.
5. Confronta il rischio CSRF tra cookie authentication e bearer-token authentication esplicita.
6. Spiega come XSS possa compromettere una sessione API altrimenti correttamente autenticata.
7. Progetta difese per un endpoint che scarica un'immagine da un URL fornito dall'utente.
8. Individua un rischio injection anche in presenza di ORM.
9. Progetta la gestione sicura dei dati restituiti da una API di spedizione di terze parti.
10. Spiega cosa può e non può correggere un WAF.
11. Progetta una logging policy utile alle investigazioni senza registrare credenziali.
12. Analizza un servizio interno e spiega perché l'accesso VPN da solo non costituisce autorizzazione sufficiente.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- rate limiting;
- CORS;
- SQL e NoSQL injection;
- firewall e WAF;
- VPN;
- CSRF;
- XSS;
- diversi livelli difensivi.

Il materiale pubblico raffina ed estende intenzionalmente quel modello:

- CORS viene trattato come meccanismo cross-origin applicato dal browser e non come autenticazione API;
- rate limiting viene trattato come uno dei controlli sul consumo delle risorse e non come protezione DDoS completa;
- frequenza delle richieste e limiti sulle risorse consumate da ogni richiesta vengono separati;
- CSRF viene collegato al comportamento delle credenziali nel browser invece di essere applicato indiscriminatamente a ogni API;
- XSS viene trattato come vulnerabilità browser/applicativa capace di compromettere capacità API autenticate;
- vengono inclusi esplicitamente broken object-level, property-level e function-level authorization;
- le difese injection distinguono validazione e uso sicuro degli interpreti;
- SSRF viene aggiunto come importante minaccia API;
- le risposte delle API di terze parti vengono trattate come input non fidato;
- WAF, firewall, VPN e controlli di rete vengono trattati come defense in depth e non come sostituti della sicurezza applicativa;
- vengono inclusi secret, logging, error disclosure e timeout downstream;
- la sicurezza viene organizzata attorno a threat model e trust boundary.
