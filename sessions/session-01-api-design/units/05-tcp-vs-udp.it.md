# Unità 05 – TCP vs UDP

[English](05-tcp-vs-udp.md) | [Italiano](05-tcp-vs-udp.it.md)

## Obiettivo didattico

Comprendere TCP e UDP come astrazioni di trasporto differenti e scegliere le proprietà del trasporto in base ai requisiti dell'applicazione.

La domanda utile non è:

> TCP è sicuro e UDP è veloce?

Le domande utili sono:

- Serve delivery affidabile?
- Serve ordinamento?
- I confini dei messaggi sono importanti?
- Come deve essere gestita la perdita?
- Quanto stato di trasporto è accettabile?
- Dove devono vivere reliability, congestion control e recovery?
- Un dato diventato vecchio conserva ancora valore?

## Responsabilità del livello di trasporto

I protocolli applicativi definiscono come comunicano le applicazioni.

I protocolli di trasporto determinano proprietà importanti del modo in cui i dati vengono portati tra endpoint.

TCP e UDP espongono alle applicazioni astrazioni molto differenti.

## TCP

TCP fornisce un byte stream affidabile, ordinato e connection-oriented.

Tra le proprietà importanti troviamo:

- apertura della connessione;
- consegna ordinata dei byte;
- rilevazione delle perdite;
- ritrasmissione;
- gestione dei duplicati;
- flow control;
- meccanismi di congestion control;
- comunicazione bidirezionale.

L'applicazione vede uno stream di byte anziché messaggi applicativi indipendenti.

## TCP è un byte stream

Questa distinzione è importante.

Se un'applicazione effettua due write:

- messaggio A;
- messaggio B;

TCP non garantisce che il receiver osservi esattamente gli stessi confini delle write.

L'applicazione ricevente vede uno stream ordinato di byte.

I protocolli applicativi sopra TCP hanno quindi generalmente bisogno di una propria strategia di framing, per esempio:

- lunghezza del messaggio;
- delimitatori;
- framing strutturato;
- frame definiti dal protocollo.

Delivery affidabile dei byte e framing dei messaggi non sono la stessa cosa.

## Affidabilità

TCP traccia i dati tramite informazioni di sequenza e rileva le perdite.

Quando mancano dati necessari, TCP li ritrasmette.

Questo permette all'applicazione ricevente di osservare il byte stream nell'ordine corretto.

Questa affidabilità è estremamente utile per:

- transazioni finanziarie;
- normale traffico HTTP;
- scambi di autenticazione;
- protocolli database;
- trasferimento file;
- operazioni nelle quali non è possibile ignorare byte mancanti.

## L'ordinamento ha conseguenze sulla latenza

La consegna ordinata significa che byte successivi possono dover attendere byte precedenti mancanti.

Supponiamo che i dati dello stesso stream TCP arrivino logicamente così:

1. arriva il segmento A;
2. il segmento B viene perso;
3. arriva il segmento C.

L'applicazione non può semplicemente consumare C come se B non fosse mai esistito se questo violerebbe il byte stream ordinato.

B deve essere recuperato prima che lo stream possa progredire oltre quel punto.

Questa è una forma di head-of-line blocking.

Affidabilità e ordinamento sono quindi garanzie preziose, ma le garanzie hanno costi.

## Apertura della connessione TCP

TCP è connection-oriented.

Prima del normale scambio di dati applicativi, gli endpoint stabiliscono lo stato della connessione.

La nota procedura di apertura TCP utilizza scambi di sincronizzazione e acknowledgement.

Il punto architetturale importante non è memorizzare il diagramma dei pacchetti.

È capire che TCP mantiene stato di connessione e fornisce un'astrazione di trasporto più ricca rispetto a datagrammi indipendenti.

## UDP

UDP fornisce un servizio datagram connectionless con un meccanismo di protocollo minimo.

Tra le proprietà importanti troviamo:

- datagram indipendenti;
- confini dei messaggi preservati;
- nessuna ritrasmissione a livello UDP;
- nessuna garanzia di delivery;
- nessuna garanzia di ordinamento;
- nessuna garanzia di soppressione dei duplicati;
- nessun flow control in stile TCP;
- nessun servizio di congestion control in stile TCP incorporato in UDP.

Le applicazioni inviano datagram discreti anziché un byte stream continuo.

## Confini dei messaggi

A differenza del byte stream TCP, UDP preserva i confini dei datagrammi.

Se un'applicazione invia un datagram UDP, il receiver tratta quel datagram come messaggio discreto se arriva.

Questo può semplificare protocolli nei quali i messaggi indipendenti hanno significato.

I datagram possono però essere:

- persi;
- duplicati;
- ritardati;
- riordinati.

L'applicazione deve essere progettata di conseguenza.

## UDP non significa “TCP veloce”

UDP non è semplicemente TCP con l'affidabilità disattivata.

Espone un'astrazione differente.

Usare UDP sposta più responsabilità verso l'applicazione o verso un protocollo di livello superiore.

Se servono:

- delivery affidabile;
- ritrasmissione;
- ordinamento;
- congestion control;
- rilevazione dei duplicati;

queste proprietà devono essere fornite da qualche altro livello.

## Quando i dati vecchi valgono poco

Alcune applicazioni realtime preferiscono dati freschi rispetto al recupero tardivo di dati ormai vecchi.

Esempi possono includere:

- voce interattiva;
- telemetria live;
- alcuni aggiornamenti di stato nei videogiochi;
- media realtime.

Se un vecchio aggiornamento viene perso, ritrasmetterlo molto più tardi può avere meno valore rispetto a continuare con informazioni nuove.

Questo è uno dei motivi per cui la comunicazione a datagrammi può essere appropriata.

Non significa che la perdita sia irrilevante.

L'applicazione deve comunque decidere quali informazioni:

- possono essere scartate;
- devono essere recuperate;
- possono essere ricostruite;
- devono essere consegnate in modo affidabile.

## L'affidabilità può essere costruita sopra UDP

Un esempio moderno fondamentale è QUIC.

QUIC usa UDP al livello sottostante ma implementa sopra di esso funzionalità di trasporto, tra cui:

- stream affidabili;
- delivery ordinata all'interno dello stream;
- loss recovery;
- congestion control;
- flow control;
- multiplexing;
- apertura sicura della connessione.

Questa affermazione è quindi sbagliata:

> UDP è inaffidabile, quindi ogni protocollo sopra UDP è inaffidabile.

UDP definisce il servizio del livello datagram sottostante.

Un trasporto di livello superiore può aggiungere garanzie più forti.

## QUIC e stream indipendenti

TCP espone un byte stream ordinato per connessione.

La perdita che interessa quello stream può ritardare byte successivi mentre i dati mancanti vengono recuperati.

QUIC può trasportare più stream indipendenti all'interno della stessa connessione.

Ogni stream dispone del proprio ordinamento.

Una perdita che interessa uno stream non impedisce necessariamente a dati applicativi indipendenti di un altro stream di progredire.

Questo è uno dei motivi per cui HTTP/3 utilizza QUIC.

## Affidabilità non significa certezza del business

Nemmeno la delivery affidabile di TCP comunica all'applicazione se un'operazione di business sia stata completata con successo.

Consideriamo:

1. il client invia una richiesta di pagamento;
2. il server elabora il pagamento;
3. la connessione fallisce prima che la risposta raggiunga il client.

TCP non può comunicare al client se la transazione di business è stata committata.

Il client si trova ancora davanti a un risultato ambiguo.

Per questo le API possono richiedere:

- idempotency key;
- identificatori di transazione;
- deduplicazione;
- policy di retry sicure;
- riconciliazione.

Affidabilità del trasporto e semantica dell'operazione di business appartengono a livelli differenti.

## Confronto TCP vs UDP

| Proprietà | TCP | UDP |
|---|---|---|
| Astrazione | Byte stream | Datagram |
| Connection-oriented | Sì | No |
| Garanzia di delivery | Affidabile finché la connessione rimane utilizzabile | No |
| Ordinamento | Byte stream ordinato | Non garantito |
| Ritrasmissione | Integrata | Non integrata |
| Confini dei messaggi | Non preservati | Preservati |
| Gestione duplicati | Parte del comportamento dello stream affidabile | L'applicazione può dover gestire duplicati |
| Flow control | Sì | Non fornito da UDP |
| Congestion control | TCP lo fornisce | UDP da solo no |
| Complessità applicativa | Minore quando serve uno stream affidabile | Maggiore se servono garanzie aggiuntive |

La tabella descrive TCP e UDP stessi, non ogni protocollo costruibile sopra di essi.

## Framework decisionale

### Preferire uno stream affidabile e ordinato quando

- ogni byte è importante;
- i messaggi applicativi dipendono da dati precedenti;
- l'applicazione beneficia della ritrasmissione integrata;
- il protocollo si adatta naturalmente a uno stream;
- implementare autonomamente reliability aggiungerebbe complessità inutile.

TCP o un altro trasporto a stream affidabile è un candidato naturale.

### Considerare un trasporto a datagrammi quando

- i singoli messaggi sono indipendenti;
- informazioni vecchie possono valere meno di informazioni fresche;
- l'applicazione necessita controllo sul comportamento di recovery;
- servono semantiche realtime personalizzate;
- un protocollo di livello superiore come QUIC fornisce le proprietà desiderate.

UDP può essere un substrato appropriato.

## Errori comuni

### “TCP è sicuro”

Troppo vago.

TCP fornisce specifiche proprietà di trasporto, come delivery affidabile e ordinata dei byte.

Non rende l'applicazione sicura, corretta o transactional-safe.

### “UDP è più veloce”

Non è una regola universale utile.

Le performance dipendono da workload, perdita, congestione, design del protocollo, implementazione e condizioni di rete.

UDP ha meno meccanismi integrati, ma l'applicazione potrebbe doverne ricostruire molti sopra di esso.

### “TCP garantisce che l'operazione sia avvenuta”

Errato.

TCP può consegnare byte in modo affidabile mentre la connessione funziona, ma gli effetti applicativi possono comunque avere esiti ambigui.

### “I pacchetti UDP arrivano una volta oppure non arrivano”

Errato.

I datagram possono essere persi, duplicati, ritardati o riordinati.

### “UDP non può produrre applicazioni affidabili”

Errato.

Un protocollo di livello superiore può implementare reliability sopra UDP.

QUIC è un esempio importante.

### “TCP preserva i messaggi applicativi”

Errato.

TCP preserva l'ordine dei byte, non i confini delle write applicative.

## Risposta da colloquio

TCP e UDP espongono astrazioni di trasporto differenti.

TCP offre alle applicazioni un byte stream affidabile, ordinato e connection-oriented, con ritrasmissione, flow control e comportamento di congestion control. UDP offre datagram indipendenti e preserva i confini dei messaggi, ma non garantisce direttamente delivery, ordinamento o soppressione dei duplicati.

Non sceglierei tra i due dicendo semplicemente che TCP è più lento e UDP più veloce. Partirei dalle semantiche richieste dall'applicazione: se tutti i dati devono arrivare, se l'ordine conta, se dati vecchi hanno ancora valore, come deve funzionare il recovery e a quale livello voglio collocare la complessità del trasporto.

Separerei inoltre il trasporto sottostante dal protocollo di livello superiore. QUIC dimostra che un trasporto affidabile e multiplexato può essere implementato sopra UDP.

## Esercizi per lo studio successivo

1. Spiega perché l'affidabilità TCP non rende automaticamente sicuri i retry di un pagamento.
2. Progetta un meccanismo di framing per un protocollo applicativo sopra un byte stream TCP.
3. Spiega perché un'applicazione di voce realtime può gestire la perdita diversamente da un trasferimento file.
4. Spiega perché i datagram UDP possono richiedere rilevazione dei duplicati.
5. Confronta l'head-of-line blocking di un singolo stream TCP con stream indipendenti in QUIC.
6. Spiega perché “HTTP usa TCP” non è più un'affermazione universalmente corretta.
7. Decidi quali proprietà servono agli aggiornamenti della posizione di un giocatore rispetto alle transazioni di acquisto in un gioco multiplayer.

## Note di revisione della sorgente

La SOT privata introduce l'utile distinzione iniziale secondo cui TCP favorisce comunicazione affidabile e ordinata mentre UDP offre comunicazione datagram senza tali garanzie integrate.

Il materiale pubblico raffina intenzionalmente diverse semplificazioni:

- TCP viene descritto come byte stream affidabile e ordinato anziché semplicemente “sicuro”.
- UDP viene descritto attraverso la sua reale semantica datagram anziché semplicemente “veloce”.
- TCP non preserva i confini dei messaggi applicativi.
- UDP può consegnare datagram duplicati o riordinati.
- l'affidabilità del trasporto viene separata dalla certezza dell'operazione di business.
- QUIC mostra che reliability può essere implementata sopra UDP.
- la scelta del protocollo parte dalle semantiche richieste e non da una semplice classifica di performance.
