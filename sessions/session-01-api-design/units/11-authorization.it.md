# Unità 11 – Autorizzazione

[English](11-authorization.md) | [Italiano](11-authorization.it.md)

## Obiettivo didattico

Comprendere come i sistemi decidono se un principal autenticato possa eseguire una specifica azione su una specifica risorsa.

La domanda fondamentale dell'autorizzazione è:

> Data questa identità, questa azione, questa risorsa e questo contesto, l'accesso deve essere consentito?

L'autenticazione stabilisce l'identità.

L'autorizzazione valuta permessi e policy.

## L'autorizzazione è una decisione

Una decisione di autorizzazione coinvolge normalmente diversi input:

- principal;
- azione richiesta;
- risorsa target;
- attributi della risorsa;
- attributi del principal;
- ambiente o contesto della richiesta;
- policy applicabile.

Un modello concettuale utile è:

principal + action + resource + context → allow o deny

È più preciso rispetto a chiedere soltanto:

> Quale ruolo possiede questo utente?

I ruoli possono essere un input utile, ma non rappresentano l'intero problema dell'autorizzazione.

## Autenticazione e autorizzazione rimangono separate

Supponiamo che una richiesta contenga un'identità autenticata valida.

Questo ci dice chi ha effettuato la richiesta.

Non determina automaticamente se possa:

- leggere una fattura;
- modificare il profilo di un altro utente;
- eliminare un repository;
- approvare un pagamento;
- accedere a record confidenziali.

L'autorizzazione inizia dopo che l'identità è stata stabilita.

## Principio del least privilege

Un principal dovrebbe ricevere soltanto l'autorità necessaria per svolgere la propria funzione.

Vale per:

- utenti;
- amministratori;
- servizi;
- automazioni;
- sistemi CI;
- applicazioni di terze parti.

Concedere permessi ampi perché più semplici da configurare aumenta l'impatto di errori e compromissione delle credenziali.

## RBAC

Role-Based Access Control assegna permessi ai ruoli e ruoli ai principal.

Esempi di ruoli:

- admin;
- editor;
- viewer.

Esempi di permessi:

admin:

- create;
- read;
- update;
- delete;
- manage users.

editor:

- create;
- read;
- update.

viewer:

- read.

Un utente riceve permessi tramite l'assegnazione di uno o più ruoli.

## Perché RBAC è utile

RBAC riduce la complessità della gestione dei permessi.

Senza ruoli, i permessi possono dover essere assegnati direttamente a ogni utente.

Con i ruoli:

users → roles → permissions

Funziona bene quando le responsabilità organizzative sono relativamente stabili.

Esempi tipici:

- pannelli amministrativi;
- CMS;
- sistemi business interni;
- accesso ai repository;
- strumenti di team management.

## Trade-off di RBAC

RBAC può diventare difficile quando le policy dipendono fortemente dal contesto.

Supponiamo che gli editor possano modificare documenti soltanto quando:

- appartengono allo stesso dipartimento;
- il documento non è classificato;
- l'accesso arriva da un dispositivo gestito;
- la richiesta avviene in uno specifico stato del workflow.

Creare un ruolo separato per ogni combinazione possibile può produrre role explosion.

In questi casi regole basate sugli attributi possono adattarsi meglio.

## ABAC

Attribute-Based Access Control valuta attributi di:

- subject;
- resource;
- action richiesta;
- environment.

Policy concettuale:

allow quando:

- subject.department = resource.department;
- action = read;
- resource.classification <= subject.clearance;
- device.trusted = true.

ABAC può esprimere policy che richiederebbero moltissimi ruoli in un modello RBAC puro.

## Attributi del subject

Esempi:

- dipartimento;
- tipo di impiego;
- security clearance;
- tenant;
- regione;
- età o stato di eligibility.

Descrivono il principal che effettua la richiesta.

## Attributi della risorsa

Esempi:

- owner;
- tenant;
- classification;
- status;
- regione;
- sensitivity.

Descrivono il target al quale si vuole accedere.

## Attributi dell'ambiente

Esempi:

- ora corrente;
- rete;
- trust del dispositivo;
- posizione geografica;
- livello di autenticazione.

Permettono policy contestuali.

## Punti di forza di ABAC

ABAC è utile per:

- policy fine-grained;
- sistemi multi-tenant;
- accesso dipendente dal contesto;
- grandi combinazioni di proprietà di utenti e risorse;
- regole che evolvono indipendentemente dai ruoli organizzativi.

## Trade-off di ABAC

Maggiore flessibilità produce maggiore complessità delle policy.

Possibili problemi:

- regole in conflitto;
- debugging difficile;
- denial difficili da spiegare;
- valutazione costosa;
- attributi stale;
- enforcement inconsistente.

L'autorizzazione fine-grained richiede buona osservabilità e test.

## ACL

Una Access Control List associa permessi direttamente a una risorsa.

Concettualmente:

documento 123:

- Alice → read;
- Bob → read, write;
- Carol → nessun accesso esplicito.

È un modello resource-centric.

Esempi comuni:

- documenti condivisi;
- file;
- repository;
- cloud object;
- calendari.

## Punti di forza delle ACL

Le ACL sono utili quando singole risorse richiedono relazioni di condivisione differenti.

Rispondono naturalmente a domande come:

> Chi può accedere esattamente a questo documento?

Può essere più naturale rispetto a inventare ruoli globali per ogni relazione di condivisione.

## Trade-off delle ACL

Su grande scala possono creare:

- enormi quantità di permission entry;
- audit difficili;
- regole di inheritance costose;
- revoca complicata;
- effective permission difficili da comprendere.

I sistemi introducono spesso gruppi o ruoli per evitare assegnazioni individuali a ogni utente.

## RBAC, ABAC e ACL possono convivere

I sistemi reali combinano frequentemente questi modelli.

Esempio di piattaforma documentale:

RBAC:

- administrator può gestire le impostazioni dell'organizzazione.

ABAC:

- employee può creare documenti soltanto nel proprio tenant.

ACL:

- documento 123 condiviso con Alice come editor e Bob come viewer.

Usare più modelli non è necessariamente cattivo design.

Ogni modello può risolvere un livello differente del problema.

## Ownership come attributo di autorizzazione

Una regola comune è:

> gli utenti possono modificare le risorse di cui sono proprietari.

L'ownership non deve essere semplicemente dedotta da un identificatore fornito dal client.

Il server deve valutare l'identità autenticata rispetto allo stato fidato della risorsa.

Per esempio:

utente autenticato = 42

richiesta:

`DELETE /documents/913`

il server controlla:

owner del documento 913 = 42?

Il client non può autorizzarsi inviando:

`owner_id = 42`

L'autorizzazione usa fatti fidati server-side.

## Autorizzazione multi-tenant

I sistemi multi-tenant richiedono particolare attenzione all'isolamento.

Una richiesta può essere valida per:

- utente corretto;
- ruolo corretto;

ma puntare comunque a una risorsa appartenente a un altro tenant.

Ogni percorso di accesso deve preservare i confini del tenant.

Una condizione comune è concettualmente:

principal.tenant_id == resource.tenant_id

L'isolamento non può dipendere soltanto dall'interfaccia che nasconde identificatori stranieri.

## Claim

Un claim è un'asserzione relativa a un subject o al contesto del token.

Esempi:

- subject identifier;
- issuer;
- audience;
- role;
- tenant;
- authentication method;
- attributi custom.

I claim possono fornire input utili alle decisioni di autorizzazione.

Ma:

> claim ≠ permission decision

L'applicazione necessita ancora di policy che definiscano cosa tali claim significhino rispetto alla risorsa e all'azione richiesta.

## Claim fidati

L'autorizzazione non deve fidarsi di valori arbitrari forniti dal client.

Un claim è utile soltanto se origine e integrità sono state validate secondo il protocollo di autenticazione o token.

Per esempio:

`role = admin`

dentro JSON non firmato della request non deve concedere accesso amministrativo.

Lo stesso valore all'interno di un token validato proveniente da un issuer fidato può invece costituire un input di autorizzazione.

Il contesto di trust conta.

## OAuth scope

Gli OAuth scope descrivono confini di accesso richiesti o concessi durante un authorization flow.

Esempi concettuali:

- `profile:read`;
- `orders:read`;
- `orders:write`.

Uno scope può comunicare quale autorità è stata concessa a un client.

Ma non risponde necessariamente a ogni domanda resource-level.

Per esempio:

`orders:write`

può permettere la modifica degli ordini in generale, mentre la policy applicativa deve ancora determinare:

- quale tenant;
- quale ordine;
- quale state transition;
- quale ownership.

Scope e autorizzazione applicativa si completano.

## Scope versus role

Un role descrive generalmente la funzione di un principal nel sistema.

Esempio:

`billing-admin`

Uno scope descrive comunemente autorità delegata associata a un client o token.

Esempio:

`invoices:read`

Possono sovrapporsi nell'implementazione, ma modellano concetti differenti.

Non usare i termini come sinonimi senza definire il contratto.

## Token versus policy

Un token può trasportare informazioni come:

- subject;
- scope;
- role;
- claim.

Il token è un artefatto di input.

La authorization policy valuta se la richiesta debba essere consentita.

Concettualmente:

token validato
→ identità e claim
→ authorization policy
→ allow / deny

Il token non sostituisce la policy.

## Policy enforcement point

L'autorizzazione deve essere applicata nel punto in cui avviene realmente l'accesso.

Esempi:

- endpoint HTTP;
- resolver GraphQL;
- service method;
- database access layer;
- message consumer.

Controllare il permesso soltanto nella UI non è autorizzazione.

Un attaccante può bypassare la UI e chiamare direttamente il backend.

## Policy centralizzata versus distribuita

Un sistema può implementare autorizzazione:

- direttamente in ogni servizio;
- tramite shared library;
- tramite policy engine;
- tramite servizio esterno di autorizzazione;
- con approccio ibrido.

Policy centralizzata può migliorare la consistenza.

Ma una dipendenza centralizzata può introdurre:

- latenza;
- problemi di availability;
- problemi di cache consistency;
- complessità operativa.

L'architettura corretta dipende da scala e complessità delle policy.

## Default deny

Un modello robusto parte normalmente da:

> deny salvo policy esplicita che consenta accesso.

È più sicuro rispetto ad assumere accesso e tentare di elencare ogni condizione proibita.

Nuove risorse e azioni non devono diventare accessibili accidentalmente perché nessuno ha scritto una deny rule.

## L'autorizzazione deve essere server-side

I controlli client-side migliorano la user experience.

Per esempio nascondere il pulsante Delete a un viewer è utile.

Ma il server deve rifiutare indipendentemente la richiesta proibita.

Il codice client è controllato dal client.

Non può essere il security boundary.

## Object-level authorization

Un utente può avere permesso su un oggetto ma non su un altro dello stesso tipo.

Esempio:

`GET /invoices/10` → consentito

`GET /invoices/11` → proibito

perché invoice 11 appartiene a un altro customer.

La sola authorization endpoint-level non è sufficiente.

Il server deve autorizzare lo specifico target object.

## Field-level authorization

Alcune API espongono risorse contenenti field con sensibilità differente.

Esempio User:

- nome pubblico;
- avatar;
- email;
- salary.

Un principal può essere autorizzato a recuperare l'oggetto User ma non ogni field.

È particolarmente importante in GraphQL, dove i client scelgono dinamicamente i field.

## Action-level authorization

Leggere una risorsa e modificarla sono permessi differenti.

Azioni tipiche:

- read;
- create;
- update;
- delete;
- approve;
- publish;
- refund;
- administer.

Modellare le vere azioni del business invece di ridurre ogni permesso a CRUD generico quando il dominio richiede precisione.

## Autorizzazione e stato della risorsa

I permessi possono dipendere dallo stato corrente.

Esempio:

un editor può modificare un articolo quando:

`status = draft`

ma non dopo:

`status = published`.

L'autorizzazione può quindi dipendere da:

principal + action + resource + current state

È un altro caso in cui il solo controllo del ruolo può non bastare.

## Time-of-check versus time-of-use

L'autorizzazione può diventare stale tra il controllo del permesso e l'esecuzione.

Concettualmente:

1. il permesso viene controllato;
2. cambia lo stato della risorsa;
3. l'operazione viene eseguita sulla decisione precedente.

I sistemi critici possono richiedere controllo di autorizzazione e state transition nello stesso confine transazionale o di consistenza.

L'autorizzazione non è sempre un singolo controllo middleware.

## Caching delle autorizzazioni

Mettere in cache le decisioni può migliorare le performance.

Ma introduce problemi di invalidazione.

Supponiamo:

1. Alice ha permesso admin;
2. la decisione viene cachata per dieci minuti;
3. il ruolo admin di Alice viene revocato;
4. la decisione cached continua a consentire accesso.

La durata accettabile della cache dipende dai requisiti di sicurezza.

Performance e velocità di revoca sono trade-off.

## Auditabilità

Le decisioni sensibili dovrebbero spesso essere auditabili.

Informazioni utili:

- principal;
- action;
- resource;
- decision;
- policy o reason;
- timestamp;
- correlation identifier.

Gli audit log devono evitare segreti non necessari pur supportando le investigazioni.

## Denial spiegabili

Autorizzazioni complesse beneficiano da motivazioni comprensibili.

La diagnostica interna può distinguere:

- tenant errato;
- role insufficiente;
- scope mancante;
- stato della risorsa incompatibile;
- condizione della policy fallita.

Le API esterne possono intenzionalmente esporre meno informazioni per sicurezza.

Osservabilità interna e disclosure esterna sono problemi differenti.

## 401 versus 403

Failure di autenticazione e denial di autorizzazione devono rimanere distinti.

Modello tipico:

401:

> autenticazione mancante o non valida.

403:

> richiesta compresa, ma la policy la rifiuta.

Un servizio sensibile può restituire 404 invece di 403 per nascondere l'esistenza di una risorsa.

## Errori comuni

### “L'utente ha ruolo admin, quindi non servono altri controlli”

Troppo semplicistico.

Tenant, ownership, action e context possono comunque contare.

### “I claim sono permessi”

Non necessariamente.

I claim forniscono assertion che la policy può utilizzare.

### “Gli scope sono ruoli”

Non necessariamente.

Rappresentano comunemente autorità delegata associata a token o client.

### “L'autorizzazione avviene nel frontend”

Errato.

I controlli frontend sono presentation logic, non security boundary.

### “Se l'endpoint è protetto, ogni oggetto restituito è autorizzato”

Errato.

Serve ancora object-level authorization.

### “RBAC e ABAC sono concorrenti e devo sceglierne esattamente uno”

No.

I modelli ibridi sono comuni.

### “Le ACL non scalano”

Troppo assoluto.

Possono scalare con data modeling, grouping, inheritance e indexing accurati, ma introducono complessità gestionale.

### “L'autorizzazione è un singolo middleware check”

Non sempre.

Stato delle risorse e transizioni di business possono richiedere enforcement più profondo.

## Risposta da colloquio

L'autorizzazione decide se un principal autenticato possa eseguire una specifica azione su una specifica risorsa nel contesto corrente.

Distinguo i modelli di autorizzazione dai meccanismi dei token. RBAC assegna permessi attraverso ruoli ed è adatto a responsabilità organizzative stabili. ABAC valuta attributi del subject, della risorsa e dell'ambiente ed è utile per policy contestuali fine-grained. Le ACL associano permessi a singole risorse e sono naturali nei modelli di condivisione come i documenti.

I sistemi reali combinano spesso questi approcci.

Claim, role e OAuth scope sono input dell'autorizzazione; non costituiscono da soli la decisione. Valido prima identità e token, poi valuto claim fidati rispetto allo stato server-side della risorsa e alla policy.

Applico inoltre l'autorizzazione server-side a livello di oggetto e azione, uso default deny, preservo i confini tenant e considero revoca, caching e auditabilità parte del design.

## Esercizi per lo studio successivo

1. Modella un CMS con ruoli admin, editor e viewer.
2. Individua dove RBAC puro produce role explosion e sostituiscine una parte con ABAC.
3. Progetta una ACL per document sharing con utenti e gruppi.
4. Progetta l'autorizzazione di una invoice API multi-tenant.
5. Spiega perché uno scope `orders:write` può non bastare ad autorizzare uno specifico ordine.
6. Decidi quali claim JWT siano utili input di autorizzazione e quali fatti vadano letti dallo stato server-side della risorsa.
7. Progetta object-level e field-level authorization per un tipo GraphQL User.
8. Spiega come il caching delle autorizzazioni influenza la revoca dei permessi.
9. Modella un workflow editoriale in cui i permessi cambiano tra draft e published.
10. Progetta le informazioni di audit per un'azione amministrativa sensibile.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- autorizzazione come fase che determina cosa può fare un utente autenticato;
- RBAC;
- ABAC;
- ACL;
- ruoli e permessi;
- attributi di utenti, risorse e ambiente;
- permission list specifiche delle risorse;
- OAuth e informazioni contenute nei token come meccanismi utili all'autorizzazione.

Il materiale pubblico raffina ed estende quel modello:

- l'autorizzazione viene espressa esplicitamente come principal + action + resource + context;
- vengono introdotti least privilege e default deny;
- RBAC, ABAC e ACL vengono trattati come modelli complementari anziché scelte mutuamente esclusive;
- ownership e tenant boundary vengono trattati come fatti fidati server-side;
- i claim vengono separati dalle policy decision;
- gli OAuth scope vengono separati da role e resource-level permission;
- i token validati vengono trattati come input della policy e non come motori di autorizzazione;
- vengono aggiunte object-level, field-level e action-level authorization;
- l'enforcement viene richiesto server-side;
- vengono inclusi resource state, time-of-check/time-of-use, caching e revoca;
- auditabilità e denial spiegabili vengono trattati come aspetti operativi dell'autorizzazione.
