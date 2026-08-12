# Unit 02 – Protocol Selection

[English](02-protocol-selection.md) | [Italiano](02-protocol-selection.it.md)

## Learning objective

Choose an API communication mechanism from system requirements rather than from habit or popularity.

The important question is not “Which protocol is best?” but:

> Which interaction model and trade-offs fit this communication boundary?

## Start from requirements

Before selecting a protocol, identify:

- who communicates with whom;
- request/response or bidirectional communication;
- synchronous or asynchronous interaction;
- latency sensitivity;
- throughput requirements;
- payload size and encoding needs;
- streaming requirements;
- delivery and reliability expectations;
- browser and client compatibility;
- operational complexity;
- tooling and developer experience.

Protocol selection is therefore a design decision, not a syntax decision.

## HTTP/HTTPS

HTTP is the default choice for many client-server APIs because its request/response model is widely supported and easy to operate.

Typical fit:

- public APIs;
- browser-to-server communication;
- CRUD-style applications;
- integrations between independently developed systems;
- operations naturally expressed as requests followed by responses.

HTTPS adds transport security through TLS and should be the normal deployment choice for networked APIs carrying non-public data.

### Strengths

- broad compatibility;
- mature infrastructure and tooling;
- straightforward observability and debugging;
- well-understood request/response semantics;
- good fit for stateless APIs.

### Trade-offs

HTTP request/response is not always the best interaction model for continuous server-driven updates or asynchronous workflows.

Choosing HTTP only because it is familiar can lead to polling, unnecessary requests, or awkward long-running interactions.

## WebSocket

WebSocket provides persistent two-way communication after an opening handshake.

Typical fit:

- chat;
- collaborative applications;
- live dashboards;
- multiplayer interactions;
- server-driven realtime updates.

### Strengths

- bidirectional communication;
- low overhead after connection establishment;
- server can send messages without waiting for a new client request;
- avoids repeated polling for many realtime use cases.

### Trade-offs

Persistent connections introduce operational concerns:

- connection lifecycle management;
- reconnection;
- heartbeats;
- horizontal scaling;
- load balancing;
- connection state;
- backpressure.

WebSocket is therefore not “better HTTP”. It solves a different interaction problem.

## AMQP and messaging

AMQP is a standardized messaging protocol. Broker-based systems commonly use messaging concepts such as producers, consumers, queues, routing and acknowledgements to decouple work.

Typical fit:

- asynchronous processing;
- background jobs;
- event-driven workflows;
- integration between independently operating services;
- workloads where producer and consumer should not have to run at the same time.

### Strengths

- temporal decoupling;
- buffering of bursts;
- asynchronous processing;
- flexible routing and delivery patterns.

### Trade-offs

Messaging introduces a distributed-system boundary.

Designers must reason about:

- duplicate delivery;
- acknowledgement;
- retries;
- poison messages;
- ordering;
- dead-letter handling;
- idempotent consumers;
- monitoring queue depth and processing lag.

A queue does not magically provide exactly-once business processing.

## gRPC

gRPC models communication as remote procedure calls defined by a service contract.

Protocol Buffers are the default interface definition and message format, although gRPC is not conceptually limited to them.

Typical fit:

- internal service-to-service communication;
- environments where both sides are controlled;
- strongly typed contracts;
- low-overhead binary messages;
- streaming RPCs;
- systems with many repeated inter-service calls.

### Strengths

- generated client and server bindings;
- explicit typed service contracts;
- efficient binary serialization;
- unary and streaming RPC models;
- strong fit for polyglot service architectures.

### Trade-offs

- less natural for direct browser consumption than conventional HTTP APIs;
- generated-code workflow;
- schema evolution must be handled carefully;
- debugging is less immediately human-readable than JSON over HTTP;
- infrastructure must support the chosen gRPC transport correctly.

## Decision matrix

| Requirement | Strong candidate |
|---|---|
| Conventional public request/response API | HTTP/HTTPS |
| Browser-facing CRUD or resource API | HTTP/HTTPS |
| Persistent realtime bidirectional communication | WebSocket |
| Asynchronous producer/consumer workflow | Messaging / AMQP |
| Typed internal service-to-service RPC | gRPC |
| Client and server evolve independently | Usually HTTP with a stable public contract |
| Work must survive temporary consumer unavailability | Durable messaging |
| Continuous stream between controlled services | gRPC streaming or another streaming technology |
| Browser must receive server-driven realtime events | WebSocket, or another browser-compatible push mechanism depending on directionality |

The table is a starting point, not a protocol-selection algorithm.

## Hybrid systems are normal

Real systems often combine communication mechanisms.

Example:

1. a browser calls a REST API over HTTPS;
2. the API publishes an asynchronous job;
3. workers consume that job through messaging;
4. internal services communicate through gRPC;
5. the browser receives realtime progress through WebSocket.

This is not inconsistency. Each boundary has different requirements.

## Common mistakes

### “Use gRPC because it is faster”

Performance alone is insufficient.

Consider interoperability, operational tooling, observability, browser compatibility, schema management and team expertise.

### “Use WebSocket for anything realtime”

Some systems only need server-to-client updates, periodic refreshes or events with weaker realtime requirements.

Persistent bidirectional connections have a cost.

### “A queue guarantees the business operation happens exactly once”

Message delivery semantics and business-side effects are different problems.

Consumers often need idempotency and deduplication even when the messaging infrastructure provides strong delivery guarantees.

### “REST, WebSocket, AMQP and gRPC are interchangeable alternatives”

They solve overlapping but different communication problems.

The useful comparison is based on interaction patterns and system boundaries, not merely protocol names.

## Interview answer

When choosing an API communication mechanism, I start from the interaction pattern and operational requirements rather than selecting a technology first.

For conventional public request/response APIs I would normally start with HTTPS. For persistent bidirectional realtime communication I would consider WebSocket. For asynchronous workflows where producers and consumers should be decoupled in time, I would use messaging. For controlled service-to-service communication that benefits from typed contracts and streaming, gRPC is a strong candidate.

The final decision also depends on compatibility, latency and throughput requirements, delivery semantics, observability, operational complexity and the capabilities of the team.

## Exercises for later study

1. Design the communication boundaries of an ecommerce checkout system and justify where HTTP, messaging and possibly gRPC would fit.
2. Decide how to implement live order-status updates in a browser and explain why polling or WebSocket may be appropriate.
3. A payment request times out after the client sends it. Explain why protocol choice alone does not solve duplicate business operations.
4. Compare synchronous HTTP calls with asynchronous messaging when the downstream inventory service is temporarily unavailable.
5. Explain why an architecture may legitimately use several communication mechanisms at the same time.

## Source review notes

The private SOT provides the initial protocol-selection framework, especially interaction pattern, performance, payload, security, compatibility and developer-experience considerations.

During technical review, several source simplifications were deliberately refined:

- WebSocket is treated as a bidirectional protocol layered over TCP, not merely as “HTTP without polling”.
- AMQP is treated as a messaging protocol; queue-and-broker architecture is an important usage model but not the complete definition of AMQP.
- Protocol Buffers are described as gRPC's default IDL and message format rather than an absolute requirement.
- Protocol choice is framed as a multi-dimensional architectural decision rather than a simple speed ranking.
