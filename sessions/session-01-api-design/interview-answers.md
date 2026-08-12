# Interview Answers – Session 01: API Design

[English](interview-answers.md) | [Italiano](interview-answers.it.md)

This interview bank consolidates the main design decisions covered by Units 01–12.

The goal is not to memorize scripts word for word.

The goal is to be able to explain the reasoning, trade-offs and failure modes behind each answer.

## 1. What is an API?

An API is a contract between systems.

It defines:

- what operations a client can request;
- what data the client must provide;
- what responses it can expect;
- what errors can occur;
- what behavioral guarantees and constraints apply.

A good API hides implementation details and exposes a stable, coherent and understandable boundary.

The key idea is that an API is not merely an endpoint. It is a contract that allows client and server implementations to evolve independently within agreed semantics.

## 2. How do you choose an API protocol?

I start from the interaction pattern rather than from technology preference.

I ask:

- request/response or asynchronous messaging?
- one-way or bidirectional communication?
- browser-facing or service-to-service?
- low latency or high throughput?
- streaming required?
- temporary disconnection expected?
- strong schema and generated clients useful?
- what operational complexity can the team support?

HTTP is often the default for conventional client/server APIs.

WebSocket fits persistent bidirectional communication.

AMQP-style messaging fits asynchronous and temporally decoupled workflows.

gRPC fits strongly typed service-to-service RPC and streaming when both sides are controlled.

The important part is matching the communication model to the requirements.

## 3. What is the difference between HTTP and HTTPS?

HTTP defines application-level request and response semantics.

HTTPS is HTTP carried through TLS.

TLS provides transport protection such as confidentiality, integrity and peer authentication within the protected channel.

HTTPS does not automatically authenticate the application user and does not fix authorization or application vulnerabilities.

So I treat HTTPS as necessary transport security, not as a complete security model.

## 4. When would you use WebSocket?

I would use WebSocket when the application needs a persistent, bidirectional communication channel with low interaction overhead.

Examples include:

- collaborative editing;
- multiplayer state updates;
- interactive dashboards;
- chat;
- server-driven real-time events where both sides may send messages.

I would not choose WebSocket merely because something is described as “real-time”.

I would also consider reconnect behavior, heartbeat, backpressure, authentication renewal, fan-out and horizontal scaling.

## 5. When would you use asynchronous messaging such as AMQP?

I would use asynchronous messaging when producers and consumers benefit from temporal decoupling.

Examples include:

- background processing;
- order workflows;
- notifications;
- integration events;
- workloads where the producer should not wait for the final business result.

Messaging changes the failure model.

Delivery does not automatically mean business completion, and retries can produce duplicates.

Therefore I design consumers for idempotency, redelivery, poison messages and reconciliation rather than assuming exactly-once business execution.

## 6. When would you use gRPC?

I would consider gRPC mainly for service-to-service communication when I control both sides and benefit from:

- an explicit typed contract;
- generated clients;
- efficient serialization;
- unary and streaming RPC;
- strong tooling around service definitions.

I would not automatically choose it for a browser-first public API, where conventional HTTP APIs are often easier to expose and debug.

## 7. What is the practical difference between TCP and UDP?

TCP provides a reliable, ordered byte stream with connection management, retransmission, flow control and congestion control.

UDP provides independent datagrams without built-in guarantees for delivery, ordering or duplicate suppression.

The important design question is not simply “reliable versus fast”.

It is whether stale or missing data is preferable to waiting for retransmission.

Voice, telemetry or gaming can sometimes prefer freshness over perfect delivery.

I also avoid saying that HTTP always means TCP, because HTTP/3 runs over QUIC, which provides reliable transport semantics above UDP.

## 8. How do you design REST resources?

I model stable domain concepts rather than exposing database tables or remote procedure names.

I prefer resource-oriented identifiers such as:

- `/products`;
- `/products/42`;
- `/orders/913`.

HTTP methods then express the interaction semantics.

Plural nouns are a useful naming convention, not a law of REST.

I also avoid blindly mapping ORM relationships into deeply nested URLs.

The public resource model should reflect how clients understand the domain, not how persistence happens internally.

## 9. What does statelessness mean in REST?

Statelessness means that each request contains the information needed for the server to understand that interaction.

The server should not require hidden conversational state from previous requests in order to interpret the current request.

This improves scalability and intermediary behavior because requests can be handled independently.

Statelessness does not mean the application stores no state.

Resources, databases, authentication systems and caches obviously still contain state.

## 10. What is the difference between safe and idempotent HTTP methods?

A safe method is defined as read-only in its requested semantics.

GET and HEAD are typical examples.

An idempotent method can be repeated with the same intended effect as performing it once.

GET, HEAD, PUT and DELETE are idempotent by HTTP semantics.

POST is not idempotent by default.

PATCH is not guaranteed to be idempotent; it depends on the concrete patch operation.

The distinction matters especially when retries occur after ambiguous network failures.

## 11. How would you handle a timeout after creating a payment?

I would treat the outcome as unknown.

A timeout proves that the client did not receive a response.

It does not prove that the server failed to process the payment.

Blindly retrying a non-idempotent payment operation could charge twice.

I would therefore design application-level protection such as:

- an idempotency key;
- a stable operation identifier;
- deduplication;
- status lookup;
- reconciliation.

This is a distributed-systems uncertainty problem, not merely an HTTP error.

## 12. How do you design API errors?

I use HTTP status codes for broad protocol semantics and stable application error codes for domain-specific conditions.

Examples include:

- 400 for malformed requests;
- 401 when authentication is missing or invalid;
- 403 when policy refuses an understood request;
- 404 when the resource is absent or intentionally concealed;
- 409 for conflict with current state;
- 422 for semantically unprocessable content;
- 429 for rate limiting;
- 500 for unexpected server failures.

The error body should provide enough information for a legitimate client without exposing stack traces, credentials or internal implementation details.

## 13. Offset pagination or cursor pagination?

Offset pagination is simple and useful when users need arbitrary page navigation.

Its weaknesses appear on large or frequently changing datasets:

- high offsets can be expensive;
- inserts and deletes can shift page boundaries;
- clients may observe duplicates or skipped rows.

Cursor pagination is often better for large dynamic feeds because traversal continues from a stable ordering position.

The trade-off is that arbitrary jumps such as “go directly to page 847” become harder.

Neither strategy is universally better.

## 14. How do you evolve an API without breaking clients?

I treat compatibility as behavioral as well as structural.

Obvious breaking changes include:

- removing fields;
- renaming fields;
- changing types incompatibly;
- making optional input mandatory.

But changing the meaning of a field or silently turning a complete collection into a paginated partial collection can also break clients.

I prefer backwards-compatible evolution when possible.

When an incompatible contract is necessary, I introduce an explicit version and provide migration, deprecation and coexistence periods.

## 15. When would you choose GraphQL?

I would consider GraphQL when clients need substantially different or deeply connected response shapes.

It can reduce some over-fetching and under-fetching because clients select the fields they need.

The trade-offs include:

- schema design complexity;
- N+1 access patterns;
- query complexity control;
- pagination;
- field-level authorization;
- different caching ergonomics.

GraphQL is valuable when that flexibility solves a real product problem, not simply because it is fashionable.

## 16. How do GraphQL errors differ from normal HTTP errors?

I separate GraphQL execution semantics from HTTP transport semantics.

A GraphQL request error can prevent execution entirely, for example because the document is syntactically invalid or fails validation.

An execution error happens while resolving fields.

In that case the response may contain both partial `data` and an `errors` array.

Therefore the slogan “GraphQL always returns HTTP 200” is too simplistic.

The GraphQL response model and the chosen GraphQL-over-HTTP transport contract need to be reasoned about separately.

## 17. What is the N+1 problem in GraphQL?

A compact client query can trigger many backend queries.

For example:

1. fetch 100 posts;
2. resolve each author separately;
3. produce 100 additional database queries.

The client made one GraphQL request, but the server performed 101 data accesses.

Typical mitigations include batching, request-scoped loaders, joins, prefetching and caching.

GraphQL controls response shape; it does not automatically optimize backend access.

## 18. What is the difference between authentication and authorization?

Authentication establishes who or what is making the request.

Authorization determines what that authenticated principal may do.

For example:

- authentication: this is user 42;
- authorization: user 42 may read invoice 100 but not invoice 101.

A valid credential does not imply universal permission.

The server must still authorize the concrete action and resource.

## 19. Is OAuth 2.0 an authentication protocol?

OAuth 2.0 is primarily an authorization framework for delegated access.

It should not be treated as a generic login protocol.

OpenID Connect adds standardized end-user authentication on top of OAuth 2.0.

I also distinguish:

- access token: authority for a resource server;
- ID Token: authenticated identity information for the OpenID Connect relying party.

Using them interchangeably creates security and interoperability problems.

## 20. What is a JWT, and what does it not guarantee?

JWT is a token format for transporting claims.

It does not automatically mean:

- OAuth;
- authentication;
- authorization;
- confidentiality;
- security.

A signed JWT protects integrity according to its signing mechanism, but the payload can still be readable.

The consumer must validate the properties required by the protocol, such as:

- signature;
- issuer;
- audience;
- lifetime;
- token purpose.

Successfully decoding a JWT is not authentication.

## 21. RBAC, ABAC or ACL?

I choose based on the policy structure.

RBAC works well for stable organizational roles such as admin, editor and viewer.

ABAC works well when decisions depend on attributes of the principal, resource or environment.

ACLs fit resource-specific sharing such as:

- Alice can edit document 10;
- Bob can only read it.

Real systems often combine all three.

For example:

- RBAC for organization-wide capabilities;
- ABAC for tenant or clearance conditions;
- ACLs for individual document sharing.

## 22. Are roles, claims and OAuth scopes permissions?

They can be inputs to authorization, but I do not treat them as the final authorization decision.

A validated token might contain:

- subject;
- role;
- scope;
- tenant claim.

The application still evaluates policy against trusted server-side facts such as:

- the target resource;
- ownership;
- tenant;
- current workflow state.

Conceptually:

validated identity and claims
→ policy evaluation
→ allow or deny

The token does not replace authorization policy.

## 23. What are the most important API security principles?

I use defense in depth.

A typical security path is:

TLS
→ authentication
→ authorization
→ input validation
→ safe interpreter use
→ resource limits
→ monitoring

I also consider:

- object-level authorization;
- property-level authorization;
- injection;
- SSRF;
- secrets;
- downstream timeouts;
- rate limiting;
- browser threats;
- logging;
- network exposure.

No single mechanism such as HTTPS, OAuth, a WAF or an API gateway makes the API secure by itself.

## 24. Why are CORS, CSRF and XSS different problems?

CORS is primarily a browser cross-origin access-control mechanism.

It does not authenticate API clients and does not stop command-line or server-side clients from making requests.

CSRF abuses the browser's ability to automatically attach credentials, classically cookies, to unintended requests.

XSS allows attacker-controlled content to execute inside the application's browser context.

They can interact: successful XSS can often undermine browser-side protections and abuse authenticated API capabilities.

I therefore treat them as distinct threats tied to different trust boundaries.

## Compact interview summary

A well-designed API is a stable contract and system boundary.

I choose protocols from the interaction requirements rather than from popularity: HTTP for conventional request/response APIs, WebSocket for persistent bidirectional communication, asynchronous messaging for temporal decoupling and gRPC for typed internal RPC when appropriate.

For HTTP APIs I model resources around the domain, use method and status semantics deliberately, design retries around idempotency and treat timeouts as ambiguous outcomes.

For large collections I define deterministic ordering and pagination early, and I evolve public contracts backwards-compatibly whenever possible.

GraphQL is useful when client-controlled response shape justifies its additional schema, resolver, authorization and complexity-management costs.

For security I separate authentication from authorization, OAuth from OpenID Connect, JWT format from token semantics, and claims from actual policy decisions.

Finally, I treat API security as defense in depth across transport, identity, authorization, input boundaries, resource limits, browser security, dependencies and observability.
