# Unit 04 – WebSocket, AMQP and gRPC

[English](04-websocket-amqp-grpc.md) | [Italiano](04-websocket-amqp-grpc.it.md)

## Learning objective

Understand why WebSocket, messaging protocols such as AMQP, and gRPC solve different communication problems even though all three may appear as alternatives to a conventional HTTP API.

The useful comparison is not based on protocol names.

It is based on:

- interaction direction;
- connection lifetime;
- temporal coupling;
- delivery semantics;
- streaming requirements;
- service ownership;
- operational complexity.

## WebSocket

WebSocket provides a persistent two-way communication channel.

A connection begins with an opening handshake compatible with HTTP infrastructure. After the handshake succeeds, communication uses WebSocket framing over the established connection.

Both peers can then send messages independently.

### Typical use cases

- chat;
- collaborative editing;
- multiplayer applications;
- live dashboards;
- realtime notifications;
- continuously changing application state.

### Why it differs from polling

With polling, the client repeatedly asks whether something has changed.

This can produce requests that return no useful information.

With WebSocket, the connection remains available and the server can send data when an event occurs.

This can reduce unnecessary request/response cycles when realtime bidirectional communication is genuinely required.

### Operational concerns

Persistent connections introduce additional responsibilities:

- reconnect behavior;
- connection timeouts;
- ping/pong or heartbeat strategies;
- connection cleanup;
- load balancing;
- horizontal scaling;
- fan-out across application instances;
- backpressure;
- authentication renewal;
- observability of long-lived connections.

WebSocket reduces polling overhead, but it does not eliminate distributed-system complexity.

## AMQP

AMQP is a standardized messaging protocol.

It defines interoperable concepts around:

- messages;
- sources and targets;
- transfers;
- delivery states;
- settlement;
- outcomes;
- flow of messages between peers.

Broker-based queue architectures are a common use of messaging, but AMQP itself should not be reduced to “a queue protocol”.

## Messaging and temporal decoupling

Consider an order-processing workflow.

A producer may publish work while the consumer is temporarily busy or unavailable.

A durable messaging system can retain that work until a consumer is able to process it.

This changes the coupling between components.

With a synchronous request:

producer → waits for consumer

With asynchronous messaging:

producer → message infrastructure → consumer

The producer and consumer no longer necessarily need to execute at the same moment.

## Delivery is not business completion

Receiving or accepting a message is not automatically equivalent to completing the business operation exactly once.

A system still has to consider:

- duplicates;
- retries;
- consumer crashes;
- redelivery;
- idempotency;
- transaction boundaries;
- poison messages;
- dead-letter handling.

For example, a payment consumer might successfully charge a card and then crash before recording that the message was completed.

When the message is delivered again, blindly repeating the operation could charge the customer twice.

Therefore message delivery semantics and business-side-effect semantics must be designed separately.

## Delivery state and settlement

Messaging protocols can track the state of a delivery.

Conceptually, a message transfer may move through states representing outcomes such as:

- accepted;
- rejected;
- released;
- modified.

Settlement determines when peers can forget the delivery state.

This is more precise than saying only that “the queue guarantees delivery”.

The exact guarantee depends on protocol behavior, broker configuration and application design.

## gRPC

gRPC is an RPC framework built around explicitly defined services and methods.

Instead of primarily exposing resources such as:

`/users/42`

an RPC interface exposes callable operations defined by a service contract.

Protocol Buffers are the default interface definition language and message format.

From the service definition, tooling can generate client and server bindings.

## RPC styles

gRPC supports four important interaction models.

### Unary RPC

One request produces one response.

Conceptually:

client → request → server
client ← response ← server

### Server streaming

The client sends one request and receives a stream of responses.

Useful when one request produces a sequence of results.

### Client streaming

The client sends a stream of messages and eventually receives one response.

Useful when many pieces of input contribute to one operation.

### Bidirectional streaming

Client and server both exchange streams of messages.

The two directions can progress independently.

This supports rich service-to-service streaming communication.

## Flow control

Streaming creates a problem: a fast sender can overwhelm a slower receiver.

gRPC therefore participates in flow-control mechanisms that can delay additional writes until the receiving side has capacity.

This is an important engineering detail.

Streaming does not mean “send infinitely fast and hope”.

## gRPC strengths

gRPC is especially attractive when:

- both sides of the interface are controlled;
- services are implemented in different supported languages;
- generated bindings are useful;
- contracts should be strongly typed;
- binary serialization is appropriate;
- streaming is required;
- many service-to-service calls are performed.

## gRPC trade-offs

The same properties also introduce costs:

- schema-management discipline;
- generated-code workflow;
- different debugging experience from JSON APIs;
- infrastructure compatibility requirements;
- more friction for direct browser consumers;
- careful timeout and deadline design.

RPC also does not remove network uncertainty.

A remote function call is still remote.

Timeouts, partial failures, retries and ambiguous outcomes remain distributed-system concerns.

## They are not equivalent technologies

A common mistake is to compare:

- HTTP;
- WebSocket;
- AMQP;
- gRPC

as if one must replace all the others.

A real system may use all of them.

Example ecommerce architecture:

1. the browser calls a public HTTPS API;
2. checkout publishes an order-processing message;
3. inventory and payment workers consume asynchronous work;
4. internal services use gRPC;
5. order-status updates reach the browser through WebSocket.

Each mechanism serves a different boundary.

## Decision comparison

| Requirement | Likely fit |
|---|---|
| Persistent browser ↔ server realtime communication | WebSocket |
| Asynchronous durable work | Messaging / AMQP |
| Decouple producer lifetime from consumer lifetime | Messaging / AMQP |
| Typed internal RPC | gRPC |
| Unary service-to-service calls | gRPC or HTTP |
| Server/client streaming between controlled services | gRPC |
| Human-friendly public resource API | HTTP/REST |
| Browser receives frequent bidirectional updates | WebSocket |

This table provides design hints, not absolute rules.

## Failure modes to reason about

### WebSocket

- disconnected client;
- reconnect storm;
- lost application context;
- stale authentication;
- slow consumer;
- connection concentration on one server.

### Messaging

- duplicate message;
- consumer crash after side effect;
- poison message;
- backlog growth;
- ordering assumptions;
- retry storm.

### gRPC

- deadline exceeded;
- client and server disagree about whether an operation completed;
- retry of non-idempotent operations;
- slow stream consumer;
- schema incompatibility;
- unavailable downstream service.

## Common mistakes

### “WebSocket guarantees realtime”

It provides an appropriate communication mechanism, but end-to-end latency still depends on the application, network, queues, processing and infrastructure.

### “AMQP means queue”

Too narrow.

Queues are an important messaging pattern, but AMQP defines a broader interoperable messaging model.

### “The broker guarantees exactly-once business behavior”

No.

Delivery guarantees do not automatically make arbitrary application side effects exactly once.

### “gRPC makes remote calls behave like local functions”

Dangerous mental model.

The syntax may resemble a function call, but network failures and ambiguous outcomes still exist.

### “Streaming means there is no backpressure”

Incorrect.

Streaming systems still need flow control when sender and receiver operate at different rates.

## Interview answer

WebSocket, AMQP-style messaging and gRPC solve different communication problems.

I would consider WebSocket for persistent bidirectional realtime communication, especially with browser clients. I would use messaging when producers and consumers need temporal decoupling, buffering or durable asynchronous work. I would consider gRPC for controlled service-to-service communication where typed contracts, generated clients and streaming are valuable.

I would not choose among them only by throughput benchmarks. I would also consider failure semantics, retries, delivery guarantees, client compatibility, observability and operational complexity.

## Exercises for later study

1. Design a chat system and identify what WebSocket solves and what it does not solve.
2. Design order processing where the payment worker can be unavailable for ten minutes.
3. Explain how a message can be delivered once while a business operation still occurs twice.
4. Design a gRPC interface that uses unary and server-streaming RPCs for different operations.
5. Explain what should happen when a streaming consumer is slower than its producer.
6. Sketch a system that legitimately uses HTTPS, WebSocket, messaging and gRPC together.

## Source review notes

The private SOT correctly identifies the major use cases:

- WebSocket for realtime bidirectional communication;
- AMQP-style messaging for asynchronous producer/consumer workflows;
- gRPC for efficient service-to-service RPC.

During technical review the model was refined:

- WebSocket uses HTTP during connection establishment but becomes an independent framed protocol over the connection.
- AMQP is broader than a queue abstraction and includes explicit delivery-state and settlement concepts.
- Delivery guarantees are separated from exactly-once business effects.
- gRPC's four RPC styles are made explicit.
- Flow control is included as a core streaming concern.
- RPC syntax is deliberately separated from local-function semantics because remote calls still fail in distributed ways.
