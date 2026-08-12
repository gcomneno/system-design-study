# Unit 09 – GraphQL

[English](09-graphql.md) | [Italiano](09-graphql.it.md)

## Learning objective

Understand GraphQL as a typed query language and execution model that lets clients request a specific response shape.

The main design questions are:

- What contract does the schema expose?
- How much query flexibility should clients receive?
- Where does authorization live?
- How are partial failures represented?
- How do we prevent expensive or abusive queries?
- When does GraphQL solve a real client problem better than a resource-oriented API?

## Why GraphQL exists

Traditional resource APIs often expose server-defined response shapes.

A client may receive:

- more fields than it needs;
- fewer related objects than it needs;
- several resources requiring multiple requests.

GraphQL changes the interaction model.

The client describes the fields it wants and the server executes that selection against a schema.

This is especially useful when different clients or screens need substantially different views of related data.

## A schema is the contract

The GraphQL schema defines the public type system.

It describes:

- object types;
- fields;
- arguments;
- scalar types;
- relationships;
- query entry points;
- mutation entry points;
- nullability.

Example conceptually:

User

- id
- name
- posts

Post

- id
- title
- author

The schema is not merely documentation.

It is an executable contract used for validation and execution.

## Strong typing

A GraphQL schema gives clients explicit information about the available fields and their types.

This supports:

- validation before execution;
- introspection tooling;
- generated client types;
- IDE completion;
- discoverability.

Strong typing does not automatically guarantee good domain design.

A badly modeled schema can still be strongly typed.

## Queries

Queries read data.

A client can request only the fields required for a particular view.

Conceptual example:

user(id: 42)

- name
- posts
  - title

The response follows the requested field shape.

This reduces some forms of over-fetching.

It can also reduce under-fetching when related information can be obtained through one operation.

## Mutations

Mutations represent operations that may produce side effects.

Examples:

- createUser;
- createOrder;
- cancelOrder;
- updateProfile.

A mutation can return fields selected by the client just like a query.

This is useful because a client can request the updated information it needs immediately after the operation.

## Query and mutation are semantic categories

GraphQL does not map CRUD operations directly to HTTP verbs.

Typically, when GraphQL is transported over HTTP:

- queries can be sent through HTTP GET or POST depending on the transport contract;
- mutations are normally sent through POST because they may cause side effects.

The GraphQL operation type describes GraphQL execution semantics.

The HTTP method describes transport semantics.

They are related but not identical layers.

## One endpoint does not mean one operation

A GraphQL service is commonly exposed through an endpoint such as:

`/graphql`

That does not mean the service has only one operation.

The schema can expose many query and mutation fields behind that endpoint.

The contract therefore moves from many resource URLs toward one typed graph of operations and fields.

## Over-fetching and under-fetching

### Over-fetching

The server returns fields the client does not need.

GraphQL allows clients to select a smaller field set.

### Under-fetching

The first response does not contain enough related data, forcing additional requests.

GraphQL allows a single operation to traverse related fields.

These are genuine strengths, but they do not imply that GraphQL always produces fewer backend calls.

Resolvers may still perform many internal operations.

The client-facing request count and the backend execution cost are separate concerns.

## The N+1 problem

A GraphQL query can look compact while triggering inefficient backend access.

Suppose a query requests:

- 100 posts;
- author for each post.

A naive resolver may:

1. fetch 100 posts;
2. execute one additional author query per post.

That creates 101 backend queries.

Common mitigations include:

- batching;
- request-scoped loaders;
- joins;
- prefetching;
- caching.

GraphQL solves response-shape flexibility.

It does not automatically solve data-access efficiency.

## Nullability matters

GraphQL distinguishes nullable and non-null fields.

This affects failure propagation.

If a nullable field fails during execution, that field can become `null` while sibling data remains available.

If a non-null field fails, the error can propagate upward until a nullable boundary is reached.

Schema nullability is therefore not merely type decoration.

It influences failure behavior.

## Request errors versus execution errors

This distinction is fundamental.

### Request errors

A request error occurs before normal execution can proceed.

Examples include:

- invalid GraphQL syntax;
- validation failure;
- unknown field;
- invalid variable coercion;
- ambiguous operation selection.

In these cases:

- execution does not proceed normally;
- the response contains `errors`;
- response `data` is absent.

### Execution errors

An execution error occurs while resolving a field.

Examples include:

- downstream service failure;
- resolver exception;
- result coercion failure;
- authorization failure implemented at field resolution.

Execution may continue for other fields.

The response can therefore contain both:

- partial `data`;
- `errors`.

This is one of GraphQL's most important differences from a simple all-or-nothing request model.

## GraphQL does not simply “always return 200”

GraphQL itself defines the structure and semantics of GraphQL responses.

The HTTP transport is a separate concern.

A simplistic rule such as:

> Every GraphQL error returns HTTP 200

is not a sufficiently accurate model.

Transport-level failures and request failures can appropriately use HTTP error status codes.

Execution errors may still produce a valid GraphQL response containing partial data.

The exact HTTP mapping depends on the GraphQL-over-HTTP contract implemented by the service.

The GraphQL-over-HTTP specification is still evolving, so clients and servers should document their chosen transport behavior explicitly.

## Error shape

A GraphQL response can include an `errors` array.

Errors can carry information such as:

- message;
- source location;
- response path;
- implementation-defined extensions.

The path is especially useful for execution errors because it identifies which selected field failed.

Application-specific error metadata should be stable and machine-readable where clients need to react programmatically.

## Partial data is a feature and a responsibility

Partial responses can improve resilience.

Example:

A dashboard requests:

- user profile;
- recommendations;
- notifications.

If the recommendations service fails, the application may still render profile and notifications.

But partial success complicates:

- observability;
- client error handling;
- product semantics;
- caching;
- retries.

Clients must know whether missing data is acceptable for a particular use case.

## Schema design

A good schema should reflect useful domain concepts rather than implementation artifacts.

Avoid blindly exposing:

- database tables;
- ORM relationships;
- internal microservice boundaries.

The schema is a public graph for clients.

It should optimize for a coherent client-facing domain model.

## Avoid excessive nesting

GraphQL lets clients traverse relationships deeply.

That flexibility can become dangerous.

A query might request:

user
→ posts
→ comments
→ authors
→ followers
→ posts
→ comments

Deep traversal can generate:

- high CPU cost;
- large responses;
- database amplification;
- downstream request fan-out.

A production service needs query-cost controls.

## Depth limiting

One mitigation is to limit nesting depth.

For example, a service may reject operations deeper than a configured threshold.

Depth limits are simple and useful, but they are not sufficient alone.

A shallow query can still be expensive.

Example:

requesting 100,000 elements from a first-level collection.

## Complexity analysis

A stronger approach assigns estimated costs to fields or operations.

The system can reject queries whose calculated cost exceeds a threshold.

Cost can account for:

- nested fields;
- collection sizes;
- expensive resolvers;
- fan-out;
- external calls.

Depth and complexity controls complement one another.

## Pagination still matters

GraphQL does not eliminate pagination.

Large collections should still be bounded.

GraphQL APIs commonly expose pagination models based on:

- cursors;
- edges;
- nodes;
- page information.

The same design concerns discussed for REST still apply:

- deterministic ordering;
- bounded page size;
- continuation state;
- dynamic datasets.

Client-selected fields do not justify unbounded collections.

## Authorization is harder than endpoint-level checks

In a REST-style API, authorization may often be reasoned about per endpoint or resource.

GraphQL can request many related fields in one operation.

Authorization may therefore need to account for:

- object-level permissions;
- field-level permissions;
- relationship traversal;
- mutation permissions.

A user allowed to see a `User` object may not necessarily be allowed to see every field on that object.

Schema flexibility increases authorization granularity.

## Authentication remains separate

GraphQL does not define application authentication.

Authentication typically occurs through the surrounding transport or application infrastructure.

Examples include:

- session cookie;
- bearer token;
- OAuth access token.

The GraphQL execution layer then applies authorization using the resulting identity and claims.

## Caching

GraphQL changes caching ergonomics.

HTTP resource APIs often expose naturally addressable GET resources that intermediaries can cache using standard HTTP semantics.

GraphQL commonly sends many different operations to one endpoint.

Caching therefore often moves toward:

- client normalized caches;
- persisted queries;
- application caches;
- resolver-level caching;
- CDN strategies designed specifically for GraphQL.

GraphQL is cacheable, but caching requires a different mental model.

## Persisted operations

A service can register approved operations and allow clients to send an identifier rather than arbitrary query text.

Potential benefits include:

- smaller requests;
- easier allow-listing;
- better control of query complexity;
- predictable caching;
- reduced attack surface.

Persisted operations trade flexibility for operational control.

## Schema evolution

GraphQL schemas are designed to evolve compatibly.

Common compatible changes include:

- adding new fields;
- adding new types;
- adding optional arguments.

Potentially breaking changes include:

- removing fields;
- changing field types incompatibly;
- making nullable fields non-null without safe migration;
- removing enum values used by clients;
- changing field semantics.

Deprecation metadata allows old fields to remain available while clients migrate.

## When GraphQL is a strong candidate

GraphQL is attractive when:

- clients need substantially different response shapes;
- data is highly connected;
- frontend teams need rapid independent iteration;
- a typed discoverable schema is valuable;
- over-fetching and under-fetching are genuine product problems.

## When GraphQL may be unnecessary

GraphQL can be excessive when:

- the domain exposes simple stable resources;
- response shapes rarely vary;
- conventional HTTP caching is highly valuable;
- operational simplicity is a priority;
- the team does not need client-controlled traversal.

Choosing GraphQL because it is fashionable adds complexity without necessarily adding value.

## REST versus GraphQL is not a quality ranking

REST and GraphQL optimize different interaction models.

A resource-oriented HTTP API emphasizes:

- server-defined resources;
- HTTP semantics;
- individually addressable URLs.

GraphQL emphasizes:

- client-defined field selection;
- typed graph traversal;
- schema-driven execution.

A system can also legitimately expose both for different consumers.

## Common mistakes

### “GraphQL always returns HTTP 200”

Too simplistic.

GraphQL response semantics and HTTP transport semantics must be distinguished.

### “One GraphQL request means one database query”

Incorrect.

Resolvers may fan out into many backend operations.

### “GraphQL eliminates pagination”

Incorrect.

Large collections still require bounds.

### “Clients can request anything, so authorization becomes unnecessary”

Exactly backwards.

Flexible traversal often requires more granular authorization.

### “Depth limiting solves expensive queries”

Not alone.

Broad shallow queries can still be expensive.

### “GraphQL is REST with one endpoint”

Incorrect mental model.

Its type system, execution semantics and client-defined selections fundamentally change the contract.

### “GraphQL is always better for frontend development”

Only when its flexibility solves problems that justify the additional operational and schema complexity.

## Interview answer

GraphQL is a typed query language and execution model where the schema defines the contract and clients select the fields they need.

Its main advantage is flexibility for clients with different or deeply related data requirements, reducing some forms of over-fetching and under-fetching.

The trade-off is increased server complexity. I need to design schema boundaries, prevent N+1 data access, paginate collections, control depth and query complexity, handle field-level authorization and design caching differently.

I also distinguish GraphQL errors from HTTP errors. A request error can prevent execution completely, while an execution error can produce partial data together with an `errors` array. Therefore “GraphQL always returns HTTP 200” is not a sufficiently accurate design rule.

## Exercises for later study

1. Model a small ecommerce GraphQL schema containing Product, Review, User and Order.
2. Design a query that intentionally demonstrates over-fetching avoidance.
3. Build a conceptual N+1 example and propose batching.
4. Explain how nullability affects propagation of execution errors.
5. Classify examples as request errors or execution errors.
6. Design authorization rules where a User's public name is visible but email is restricted.
7. Create one deep-query attack and one shallow-but-expensive query.
8. Compare REST and GraphQL caching strategies for a product catalog.
9. Decide whether a CRUD admin panel genuinely benefits from GraphQL.
10. Design a compatible deprecation of an old GraphQL field.

## Source review notes

The private SOT correctly introduces:

- GraphQL as a solution for client-controlled response shape;
- schema and type system;
- queries for reading data;
- mutations for changing data;
- nested field selection;
- partial data and an `errors` response field;
- modular schema design;
- depth limits for nested queries.

The public material refines and extends that model:

- GraphQL request errors and execution errors are explicitly separated;
- the statement that GraphQL “always returns HTTP 200” is rejected as overly broad;
- GraphQL semantics are separated from GraphQL-over-HTTP transport semantics;
- nullability and error propagation are included;
- N+1 access patterns and batching are introduced;
- query depth is supplemented by complexity analysis;
- pagination remains mandatory for large collections;
- authorization is treated at object and field granularity;
- caching and persisted operations are included;
- schema evolution and deprecation are treated as contract-management concerns.
