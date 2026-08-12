# Unit 05 – TCP vs UDP

[English](05-tcp-vs-udp.md) | [Italiano](05-tcp-vs-udp.it.md)

## Learning objective

Understand TCP and UDP as different transport abstractions and choose between transport properties based on application requirements.

The useful question is not:

> Is TCP safe and UDP fast?

The useful questions are:

- Do we need reliable delivery?
- Do we need ordered delivery?
- Do message boundaries matter?
- How should loss be handled?
- How much transport state is acceptable?
- Where should reliability, congestion control and recovery live?
- Is stale data still useful?

## Transport-layer responsibility

Application protocols define how applications communicate.

Transport protocols determine important properties of how data is carried between endpoints.

TCP and UDP expose very different abstractions to applications.

## TCP

TCP provides a connection-oriented, reliable, ordered byte stream.

Important properties include:

- connection establishment;
- ordered byte delivery;
- loss detection;
- retransmission;
- duplicate handling;
- flow control;
- congestion-control mechanisms;
- bidirectional communication.

The application sees a stream of bytes rather than independent application messages.

## TCP is a byte stream

This distinction matters.

If an application performs two writes:

- message A;
- message B;

TCP does not promise that the receiver will observe those exact write boundaries.

The receiving application sees an ordered stream of bytes.

Therefore application protocols running over TCP generally need their own framing strategy, such as:

- message length;
- delimiters;
- structured framing;
- protocol-defined frames.

Reliable byte delivery is not the same thing as message framing.

## Reliability

TCP tracks data using sequence information and detects losses.

When required data is missing, TCP retransmits it.

This allows the receiving application to observe the byte stream in order.

That reliability is extremely useful for:

- financial transactions;
- conventional HTTP traffic;
- authentication exchanges;
- database protocols;
- file transfers;
- operations where missing bytes cannot simply be ignored.

## Ordering has a latency consequence

Ordered delivery means later bytes may have to wait for earlier missing bytes.

Suppose data belonging to the same TCP stream arrives in this logical order:

1. segment A arrives;
2. segment B is lost;
3. segment C arrives.

The application cannot simply consume C as though B never existed if doing so would violate the ordered byte stream.

B must be recovered before the stream can progress across that gap.

This is one form of head-of-line blocking.

Reliability and ordering are therefore valuable guarantees, but guarantees have costs.

## TCP connection establishment

TCP is connection-oriented.

Before ordinary application data exchange, endpoints establish connection state.

The familiar TCP connection establishment uses synchronization and acknowledgement exchanges.

The important architectural point is not memorizing packet diagrams.

It is understanding that TCP maintains connection state and provides a richer transport abstraction than independent datagrams.

## UDP

UDP provides a connectionless datagram service with minimal protocol machinery.

Important properties include:

- independent datagrams;
- preserved message boundaries;
- no transport-level retransmission;
- no guaranteed delivery;
- no guaranteed ordering;
- no duplicate suppression guarantee;
- no TCP-style flow control;
- no TCP-style congestion-control service built into UDP itself.

Applications send discrete datagrams rather than a continuous byte stream.

## Message boundaries

Unlike TCP's byte stream, UDP preserves datagram boundaries.

If an application sends one UDP datagram, the receiver processes that datagram as a discrete message if it arrives.

This can simplify protocols where independent messages are meaningful.

But datagrams can still be:

- lost;
- duplicated;
- delayed;
- reordered.

The application must be designed accordingly.

## UDP does not mean “fast TCP”

UDP is not simply TCP with reliability switched off.

It exposes a different abstraction.

Using UDP shifts more responsibility toward the application or a higher-level protocol.

If an application requires:

- reliable delivery;
- retransmission;
- ordering;
- congestion control;
- duplicate detection;

those properties must be supplied somewhere else.

## When stale data has little value

Some realtime applications prefer fresh data over delayed recovery of old data.

Examples may include:

- interactive voice;
- live telemetry;
- certain game-state updates;
- realtime media.

If one old update is lost, retransmitting it much later may provide less value than continuing with newer information.

This is one reason datagram-oriented communication can be appropriate.

It does not mean loss is irrelevant.

Applications still need to decide which information:

- may be dropped;
- should be repaired;
- should be reconstructed;
- must be delivered reliably.

## Reliability can be built above UDP

A crucial modern example is QUIC.

QUIC uses UDP underneath but implements transport features above it, including:

- reliable streams;
- ordered delivery within a stream;
- loss recovery;
- congestion control;
- flow control;
- multiplexing;
- secure connection establishment.

Therefore this statement is wrong:

> UDP is unreliable, therefore every protocol using UDP is unreliable.

UDP defines the service of the underlying datagram layer.

A higher-level transport can add stronger guarantees.

## QUIC and independent streams

TCP exposes one ordered byte stream per connection.

Loss affecting that stream can delay later stream bytes while the missing data is recovered.

QUIC can carry multiple independent streams within one connection.

Each stream has its own ordering.

A loss affecting one stream does not necessarily prevent unrelated application data on another stream from progressing.

This is one reason HTTP/3 uses QUIC.

## Reliability is not business certainty

Even TCP's reliable delivery does not tell an application whether a business operation completed successfully.

Consider:

1. client sends a payment request;
2. server processes the payment;
3. connection fails before the response reaches the client.

TCP cannot tell the client whether the business transaction committed.

The client still faces an ambiguous outcome.

This is why APIs may require:

- idempotency keys;
- transaction identifiers;
- deduplication;
- safe retry policies;
- reconciliation.

Transport reliability and business-operation semantics are separate layers.

## TCP vs UDP comparison

| Property | TCP | UDP |
|---|---|---|
| Abstraction | Byte stream | Datagram |
| Connection-oriented | Yes | No |
| Delivery guarantee | Reliable while connection remains viable | No |
| Ordering | Ordered byte stream | Not guaranteed |
| Retransmission | Built in | Not built in |
| Message boundaries | Not preserved | Preserved |
| Duplicate handling | Part of reliable stream behavior | Application may need to handle duplicates |
| Flow control | Yes | Not provided by UDP itself |
| Congestion control | TCP provides it | UDP itself does not |
| Application complexity | Lower when reliable stream is desired | Higher if additional guarantees are needed |

This table describes TCP and UDP themselves, not every protocol that can be built above them.

## Decision framework

### Prefer a reliable ordered stream when

- every byte matters;
- application messages depend on earlier data;
- the application benefits from built-in retransmission;
- the protocol naturally maps to a stream;
- implementing transport reliability independently would add unnecessary complexity.

TCP or another reliable stream transport is a natural candidate.

### Consider datagram-oriented transport when

- individual messages are independent;
- stale information may be less valuable than fresh information;
- the application needs control over recovery behavior;
- custom realtime semantics are required;
- a higher-level protocol such as QUIC provides the desired transport properties.

UDP may be an appropriate substrate.

## Common mistakes

### “TCP is safe”

Too vague.

TCP provides specific transport properties such as reliable ordered byte delivery.

It does not make the application secure, correct or transactionally safe.

### “UDP is faster”

Not a useful universal rule.

Performance depends on workload, loss, congestion, protocol design, implementation and network conditions.

UDP has less built-in transport machinery, but the application may need to recreate substantial machinery above it.

### “TCP guarantees the operation happened”

Incorrect.

TCP can reliably deliver bytes while the connection is functioning, but application side effects can still have ambiguous outcomes.

### “UDP packets always arrive once or not at all”

Incorrect.

Datagrams can be lost, duplicated, delayed or reordered.

### “UDP cannot provide reliable applications”

Incorrect.

A higher-level protocol can implement reliability over UDP.

QUIC is an important example.

### “TCP preserves application messages”

Incorrect.

TCP preserves byte order, not application write boundaries.

## Interview answer

TCP and UDP expose different transport abstractions.

TCP gives applications a connection-oriented reliable ordered byte stream with retransmission, flow control and congestion-control behavior. UDP provides independent datagrams with preserved message boundaries but does not itself guarantee delivery, ordering or duplicate suppression.

I would not choose between them simply by saying TCP is slower and UDP is faster. I would start from the application's required semantics: whether every piece of data must arrive, whether order matters, whether stale data is useful, how recovery should work, and where I want transport complexity to live.

I would also separate the underlying transport from the higher-level protocol. QUIC demonstrates that a reliable multiplexed transport can be implemented over UDP.

## Exercises for later study

1. Explain why TCP reliability does not make payment retries automatically safe.
2. Design a framing mechanism for an application protocol running over a TCP byte stream.
3. Explain how a realtime voice application might handle lost data differently from a file-transfer application.
4. Explain why UDP datagrams can require duplicate detection.
5. Compare head-of-line blocking in one TCP stream with independent streams in QUIC.
6. Explain why “HTTP uses TCP” is no longer a universally correct statement.
7. Decide which properties are needed for a multiplayer game's player-position updates versus purchase transactions.

## Source review notes

The private SOT introduces the useful first-level distinction that TCP favors reliable ordered communication while UDP provides lower-level datagram communication without those built-in guarantees.

The public material deliberately refines several simplifications:

- TCP is described as a reliable ordered byte stream rather than merely “safe”.
- UDP is described through its actual datagram semantics rather than merely “fast”.
- TCP does not preserve application-message boundaries.
- UDP may deliver duplicated or reordered datagrams.
- transport reliability is separated from business-operation certainty.
- QUIC is included to show that reliability can be implemented above UDP.
- protocol choice is based on required semantics rather than a simple performance ranking.
