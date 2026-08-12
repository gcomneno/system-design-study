# Unità 10 – Autenticazione

[English](10-authentication.md) | [Italiano](10-authentication.it.md)

## Obiettivo didattico

Comprendere come un sistema stabilisce un'identità e distinguere i meccanismi di autenticazione dai protocolli di autorizzazione, dai formati dei token e dalle decisioni sui permessi.

La domanda fondamentale è:

> Chi o cosa sta effettuando questa richiesta e quanta fiducia abbiamo in questa identità?

Concettualmente l'autenticazione precede l'autorizzazione, anche se nei sistemi reali i meccanismi coinvolti attraversano spesso diversi livelli di protocollo.

## Autenticazione versus autorizzazione

L'autenticazione stabilisce l'identità.

L'autorizzazione decide cosa quell'identità può fare.

Esempi:

- Autenticazione: questa richiesta appartiene all'utente 42.
- Autorizzazione: l'utente 42 può leggere questa fattura ma non può eliminarla.

Confondere questi concetti produce modelli di sicurezza deboli e contratti API fuorvianti.

## Le credenziali sono prove

L'autenticazione si basa su prove presentate o stabilite da un principal.

Esempi:

- password;
- identificatore di sessione;
- credenziale API;
- bearer token;
- certificato client;
- prova crittografica;
- assertion di un identity provider.

Una credenziale ha valore perché il sistema associa il suo possesso o la relativa prova a un'identità.

Proteggere le credenziali fa quindi parte del design dell'autenticazione.

## Basic authentication

HTTP Basic authentication trasmette una credenziale in stile username/password codificata per l'uso in un header HTTP.

Base64 è encoding, non encryption.

Basic authentication non deve quindi essere considerata sicura soltanto perché la credenziale appare illeggibile.

Quando viene usata Basic authentication, la sicurezza del trasporto è essenziale.

Anche sopra HTTPS, esporre ripetutamente una password longeva nel traffico applicativo può rendere Basic authentication meno desiderabile rispetto a token con autorità limitata.

## Autenticazione basata su sessione

Una web application tradizionale può autenticare l'utente una volta e mantenere poi una sessione server-side.

Flusso concettuale:

1. l'utente dimostra la propria identità;
2. il server crea stato di sessione;
3. il browser riceve un identificatore opaco della sessione;
4. le richieste successive trasportano tale identificatore;
5. il server lo risolve nello stato della sessione autenticata.

Vantaggi:

- revoca semplice;
- lo stato sensibile può rimanere server-side;
- integrazione browser matura.

Trade-off:

- storage condiviso o distribuito delle sessioni quando si scala;
- requisiti di sicurezza dei cookie;
- considerazioni CSRF quando i cookie autenticano le richieste.

L'autenticazione a sessione non è obsoleta solo perché esistono API token-based.

## Bearer token

Un bearer token funziona in base al possesso.

Il resource server accetta il token come evidenza di autorità secondo le proprie regole di validazione.

Questa proprietà è operativamente comoda ma sensibile:

> Chiunque ottenga un bearer token utilizzabile può potenzialmente esercitarne l'autorità.

I bearer token devono quindi essere protetti:

- in transito;
- nello storage;
- nei log;
- nello storage di browser o dispositivi;
- dalle divulgazioni accidentali.

Bearer è un modello di utilizzo del token, non una garanzia sul formato interno.

## Access token

Un access token rappresenta autorità concessa a un client per accedere a risorse protette.

Può codificare o fare riferimento a proprietà come:

- scope consentito;
- audience;
- expiration;
- subject;
- contesto di autorizzazione.

Un access token non deve necessariamente essere un JWT.

Può essere:

- opaco;
- strutturato;
- self-contained;
- reference-based.

Il resource server deve validarlo secondo il protocollo e il contratto di deployment.

## JWT

JWT significa JSON Web Token.

È un formato compatto per trasportare claim.

Claim tipici possono includere:

- issuer;
- subject;
- audience;
- expiration time;
- issued-at time;
- claim specifici dell'applicazione.

JWT descrive un formato di token.

Non significa automaticamente:

- OAuth;
- autenticazione;
- autorizzazione;
- encryption;
- sicurezza.

Un JWT deve essere interpretato all'interno di un protocollo e di un contesto di validazione.

## Firmato non significa cifrato

Un JWT firmato protegge integrità e autenticità secondo il meccanismo di firma.

Il payload non è automaticamente confidenziale.

Chi ottiene un normale JWT firmato codificato può essere in grado di leggerne i claim.

Le informazioni sensibili non dovrebbero quindi essere inserite in un token soltanto perché il token è firmato.

L'encryption è una proprietà crittografica separata.

## Validazione JWT

Accettare un JWT dovrebbe richiedere la validazione delle proprietà previste dal contratto applicativo.

Controlli tipici:

- algoritmo di firma accettato;
- firma;
- issuer;
- audience;
- expiration;
- vincoli not-before quando usati;
- scopo del token;
- chiave prevista e trust relationship.

Riuscire a fare parsing di un JWT non significa autenticare.

L'autenticazione deriva dalla sua validazione corretta all'interno di un protocollo fidato.

## OAuth 2.0

OAuth 2.0 è un authorization framework.

Il suo scopo principale è consentire a un client di ottenere accesso limitato a risorse protette.

Ruoli tipici:

- resource owner;
- client;
- authorization server;
- resource server.

OAuth separa la credenziale dell'utente dall'autorità delegata al client.

Un'applicazione di terze parti non deve quindi ricevere la password dell'utente per ottenere accesso limitato.

## OAuth da solo non è login

Un errore comune è dire:

> OAuth autentica l'utente tramite Google o GitHub.

OAuth 2.0 standardizza di per sé autorizzazione delegata.

Non definisce un risultato standard di identità dell'end user.

Quando serve autenticazione interoperabile dell'utente sopra OAuth 2.0, OpenID Connect fornisce l'identity layer.

La distinzione è importante perché un access token è destinato al resource server, non a essere usato arbitrariamente dal client come prova d'identità.

## OpenID Connect

OpenID Connect aggiunge un authentication layer sopra OAuth 2.0.

Permette a un relying party di verificare l'identità dell'end user autenticato.

Un artefatto centrale è l'ID Token.

L'ID Token comunica al relying party claim relativi all'evento di autenticazione e al subject.

Quindi:

- OAuth access token → autorità per accedere a una risorsa;
- OpenID Connect ID Token → informazioni di identità/autenticazione destinate al client.

Gli scopi sono differenti anche quando entrambi sono rappresentati tramite JWT.

## Access token versus ID Token

Non devono essere trattati come intercambiabili.

### Access token

Audience:

- resource server.

Scopo:

- autorizzare l'accesso a risorse protette.

### ID Token

Audience:

- client OpenID Connect / relying party.

Scopo:

- comunicare identità autenticata.

Usare un access token come se fosse un ID Token può creare problemi di sicurezza e interoperabilità.

## Access e refresh token

Gli access token sono comunemente short-lived.

Lifetime brevi riducono il periodo utile di un token rubato.

Un refresh token può permettere al client di ottenere nuovi access token senza ripetere l'intera interazione di autorizzazione dell'utente.

I refresh token sono quindi credenziali particolarmente sensibili.

La compromissione di un refresh token longevo può permettere all'attaccante di rinnovare ripetutamente l'accesso.

## Sicurezza dei refresh token

Il design dei refresh token dipende dal tipo di client e dal threat model.

Controlli importanti possono includere:

- storage sicuro;
- binding al client;
- sender-constrained token;
- refresh-token rotation;
- scadenza dopo inattività;
- revoca dopo security event;
- replay detection.

Non esiste una regola universale secondo cui ogni refresh token debba fisicamente vivere su un application server.

Architetture client differenti hanno capacità differenti.

Conta la proprietà di sicurezza, non uno slogan memorizzato sullo storage.

## Refresh-token rotation

Con la rotation:

1. il client presenta refresh token A;
2. l'authorization server emette un nuovo access token e refresh token B;
3. A viene invalidato;
4. un successivo riutilizzo di A può segnalare replay.

L'authorization server può quindi invalidare la token family o il grant associato.

La rotation fornisce quindi un meccanismo per rilevare alcuni scenari di furto del refresh token.

## Trade-off della durata dei token

Access token molto longevi:

- riducono il traffico di refresh;
- aumentano il danno in caso di furto.

Access token molto brevi:

- riducono la finestra di esposizione;
- aumentano l'attività di rinnovo;
- dipendono maggiormente dai meccanismi di refresh.

Non esiste una durata universalmente corretta.

Dipende da:

- sensibilità dell'applicazione;
- tipo di client;
- requisiti di revoca;
- user experience;
- threat model.

## Stateless non significa assenza di stato di sicurezza

L'autenticazione JWT viene spesso definita stateless perché un resource server può validare un token self-contained senza consultare una sessione a ogni richiesta.

Ma il sistema complessivo può ancora richiedere stato per:

- signing key;
- credenziali revocate;
- famiglie di refresh token;
- disabilitazione utenti;
- consent;
- authorization grant;
- key rotation;
- security event.

“JWT rende l'autenticazione stateless” è quindi una semplificazione architetturale, non una proprietà universale dell'intero identity system.

## Trade-off della revoca

Le sessioni server-side permettono revoca immediata in modo semplice:

- invalidare il record della sessione;
- le richieste successive falliscono.

Un access token self-contained e longevo è più difficile da revocare immediatamente se i resource server lo validano senza consultare stato centrale.

Possibili strategie:

- lifetime brevi;
- revocation list;
- introspection;
- key rotation in casi eccezionali;
- propagazione di security event.

Validazione stateless e revoca immediata spingono l'architettura in direzioni differenti.

## Single Sign-On

Single Sign-On permette a una relazione di autenticazione di supportare l'accesso a più applicazioni.

SSO è un pattern di esperienza e architettura, non un singolo protocollo.

Tecnologie usate negli ecosistemi SSO includono:

- OpenID Connect;
- SAML;
- sistemi identity specifici dell'organizzazione.

OAuth 2.0 può partecipare a moderne identity architecture, ma OAuth stesso non deve essere usato come sinonimo di SSO.

## Autenticazione dei servizi

L'autenticazione non riguarda soltanto esseri umani.

Anche i servizi hanno bisogno di identità.

Possibili meccanismi:

- client credentials;
- workload identity;
- mutual TLS;
- signed assertion;
- identity token cloud-native.

Un'identità di servizio dovrebbe ricevere soltanto l'autorità necessaria al proprio ruolo.

Identità umane e workload identity richiedono spesso lifecycle e security policy differenti.

## Failure di autenticazione

Una API HTTP protetta restituisce comunemente `401 Unauthorized` quando l'autenticazione non è stata stabilita con successo.

Esempi:

- credenziale mancante;
- bearer token non valido;
- credenziale scaduta che richiede nuova autenticazione.

Il rifiuto di autorizzazione dopo autenticazione riuscita è normalmente un problema differente e spesso corrisponde a `403 Forbidden`.

## Errori comuni

### “OAuth è login”

Errato.

OAuth 2.0 riguarda principalmente autorizzazione delegata.

Usare un identity protocol come OpenID Connect quando serve autenticazione standard dell'end user.

### “JWT significa autenticazione”

Errato.

JWT è un formato di token.

### “JWT è cifrato”

Non necessariamente.

Un JWT firmato può essere integrity-protected mentre i claim restano leggibili.

### “I bearer token sono sicuri perché il server li verifica”

Incompleto.

Chi ruba un bearer token valido può essere in grado di usarlo.

### “Un JWT access token è sempre migliore di un token opaco”

No.

Token opachi e self-contained hanno trade-off operativi e di sicurezza differenti.

### “JWT elimina lo stato server”

Troppo semplicistico.

L'identity system complessivo conserva frequentemente molto stato di sicurezza.

### “I refresh token devono stare sempre solo sul server”

Troppo assoluto.

Storage e protezione dipendono dal tipo di client e dall'architettura.

### “Access token e ID Token sono intercambiabili”

Pericoloso.

Hanno audience e scopi differenti.

## Risposta da colloquio

L'autenticazione stabilisce chi o cosa effettua una richiesta; l'autorizzazione decide cosa tale identità può fare.

Distinguo session authentication, bearer-token usage, formati di token e protocolli di identità invece di considerarli sinonimi.

OAuth 2.0 è un authorization framework, mentre OpenID Connect aggiunge autenticazione standard dell'end user. Un OAuth access token è destinato ad autorizzare l'accesso a un resource server, mentre un OpenID Connect ID Token comunica identità autenticata al relying party.

JWT è soltanto un formato di token. Può contenere claim ed essere firmato o cifrato secondo la propria costruzione, ma fare semplicemente parsing di un JWT non autentica nessuno. Il consumer deve validare firma, issuer, audience, lifetime e purpose del token.

Nei sistemi token-based progetto inoltre esplicitamente expiration, refresh, rotation, revocation e storage sicuro. Access token brevi riducono l'esposizione, mentre i refresh token richiedono maggiore protezione perché possono estendere l'accesso nel tempo.

## Esercizi per lo studio successivo

1. Spiega la differenza tra OAuth 2.0 e OpenID Connect.
2. Spiega perché un access token non dovrebbe essere usato automaticamente come prova di login.
3. Confronta una sessione server-side e un access token self-contained.
4. Spiega perché un JWT firmato può comunque esporre claim confidenziali.
5. Progetta i passi di validazione per un JWT ricevuto da una API.
6. Descrivi cosa accade se un bearer token finisce nei log applicativi.
7. Progetta lifetime di access e refresh token per una banking app e giustifica i trade-off.
8. Spiega refresh-token rotation e replay detection.
9. Confronta la revoca immediata in un sistema a sessione con la revoca dei token self-contained.
10. Progetta separatamente l'autenticazione per utenti umani e servizi interni.

## Note di revisione della sorgente

La SOT privata introduce correttamente:

- autenticazione come identificazione del soggetto;
- Basic authentication;
- bearer token;
- OAuth 2.0;
- JWT;
- access e refresh token;
- Single Sign-On;
- distinzione tra autenticazione e successiva autorizzazione.

Il materiale pubblico raffina intenzionalmente quel modello:

- OAuth 2.0 viene trattato come authorization framework e non come login protocol;
- OpenID Connect viene introdotto come authentication layer standard costruito sopra OAuth 2.0;
- access token e ID Token vengono separati per purpose e audience;
- la sicurezza dei bearer token viene spiegata tramite possession semantics;
- JWT viene trattato come formato e non come sinonimo di autenticazione o OAuth;
- token firmati e cifrati vengono distinti;
- vengono esplicitati i requisiti di validazione JWT;
- la sicurezza dei refresh token dipende da client type e threat model anziché da una regola universale sullo storage server-side;
- vengono inclusi refresh-token rotation e replay detection;
- la validazione stateless viene separata dallo stato dell'identity system complessivo;
- viene inclusa l'autenticazione di service/workload oltre a quella degli utenti umani.
