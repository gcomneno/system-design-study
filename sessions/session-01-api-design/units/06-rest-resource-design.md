# Unit 06 – REST Resource Design

[English](06-rest-resource-design.md) | [Italiano](06-rest-resource-design.it.md)

## Learning objective

Model an application domain as stable, understandable resources instead of designing endpoints as a collection of remote procedure names.

The key questions are:

- What concepts deserve their own identity?
- Which identifiers should remain stable?
- Which relationships belong in the public API?
- What representation should clients exchange?
- Which details should remain hidden behind the interface?

## REST starts from resources

The central abstraction in REST is the resource.

A resource is a conceptual target that can be identified.

Examples include:

- a user;
- a product;
- an order;
- a collection of orders;
- today's weather for a location;
- the current status of a deployment.

A resource should not be confused with:

- a database row;
- an ORM model;
- a file;
- one particular JSON object.

Those may be implementation details or representations of a resource.

## Resource versus representation

A resource is the concept being addressed.

A representation is data transferred to describe a current or intended state of that resource.

For example:

`/products/42`

may identify the product resource.

The server might represent it as JSON today and another media type in a different interaction without changing the conceptual resource.

This separation lets implementation and representation evolve independently from resource identity.

## Resource identifiers

Resources need identifiers that clients can use consistently.

Good identifiers should normally reflect stable domain concepts rather than internal implementation details.

For example:

- `/products`
- `/products/42`
- `/orders/913`
- `/users/17/orders`

These are common API conventions because they are readable and predictable.

The exact spelling or use of plural nouns is not what makes an architecture RESTful.

The more important property is that identifiers consistently refer to resources with stable semantics.

## Collections and members

Many APIs expose both collections and individual resources.

Typical convention:

| Identifier | Meaning |
|---|---|
| `/products` | product collection |
| `/products/42` | one product |
| `/orders` | order collection |
| `/orders/913` | one order |

HTTP methods then express the requested semantics against those resources.

This is usually clearer than encoding generic CRUD verbs into identifiers.

Prefer:

`GET /products`

over a convention such as:

`GET /getProducts`

when the operation is naturally represented as retrieving the products resource.

## Why nouns are usually useful

Identifiers such as:

- `/products`;
- `/orders`;
- `/users`;

focus the public interface on domain concepts.

Identifiers such as:

- `/getProducts`;
- `/createOrder`;
- `/deleteUser`;

often duplicate information already expressed by HTTP methods and make the interface resemble RPC.

This does not mean that every verb in a URI is forbidden.

Some domain concepts are naturally actions, processes or commands and may deserve explicit modeling.

The important question is whether the API exposes a coherent resource model rather than mechanically banning verbs.

## Do not map the database directly

A common mistake is to expose every table as an API resource.

Database schema and public API serve different purposes.

The database may contain:

- join tables;
- internal audit records;
- denormalized structures;
- persistence-specific identifiers;
- implementation-only entities.

The public API should model the concepts that clients need.

A resource boundary is an API design decision, not an automatic ORM export.

## Relationships

Resources often relate to one another.

For example:

- a product has reviews;
- a customer has orders;
- an order has line items.

A readable nested identifier might be:

`/products/42/reviews`

when the relationship to product 42 is central to the meaning of that collection.

Nested resources can make ownership and context obvious.

## Avoid excessive nesting

Deep hierarchies can become fragile.

For example, an identifier shaped conceptually like:

`/customers/17/orders/913/items/6/adjustments/2`

may expose too much structural coupling.

Questions to ask:

- Does the child resource have an identity of its own?
- Can it be addressed independently?
- Can it move between parents?
- Is the parent relationship necessary to understand the resource?
- Are authorization rules actually scoped by the parent?

If a resource has an independent identity, a flatter identifier may be clearer.

## Identity and ownership are different

Suppose review 834 belongs to product 42.

Both of these may be meaningful:

- `/products/42/reviews`
- `/reviews/834`

The first identifies a collection in the context of a product.

The second identifies one review independently.

Nested collections and globally addressable members can coexist.

## Stable semantics matter

An identifier should keep referring to the same conceptual kind of resource over time.

Clients become coupled to public identifiers.

Changing an implementation is generally easier than changing public resource semantics.

This is one reason REST encourages separation between:

- public identifiers;
- representations;
- implementation details.

## Resource granularity

Resources can be too coarse or too fine.

### Too coarse

One giant endpoint returning an entire business domain may create:

- huge payloads;
- expensive computation;
- difficult caching;
- broad authorization boundaries;
- high coupling between clients.

### Too fine

An API exposing every tiny internal object independently may create:

- excessive round trips;
- chatty clients;
- complex orchestration;
- leakage of internal design.

The right granularity depends on client workflows and consistency boundaries.

## Resource modeling before endpoint creation

A useful design process is:

1. identify important domain concepts;
2. identify which concepts need stable public identity;
3. identify collections and relationships;
4. decide what clients need to retrieve or modify;
5. define representations;
6. apply HTTP semantics;
7. review naming and consistency.

Starting from endpoint names too early often produces an RPC-shaped interface accidentally.

## CRUD is not the domain model

CRUD operations are useful mechanics, but a domain often contains richer concepts.

Consider an order.

Its lifecycle may include:

- creation;
- payment;
- cancellation;
- shipment;
- refund.

Treating every business transition as an arbitrary field update can hide important invariants.

For example, changing:

`status = "refunded"`

may not be equivalent to performing a refund operation.

The latter could require:

- payment-provider interaction;
- authorization;
- audit records;
- inventory effects;
- notifications.

Resource-oriented design still needs to represent real business semantics.

## Commands and action-like operations

Not every operation maps elegantly to simple CRUD.

For a domain transition, options can include:

- modifying the state of a resource;
- creating a subordinate resource representing the action;
- exposing an explicit domain operation.

For example, instead of pretending that refunding is just an arbitrary update, an API might model a refund as its own resource.

The correct model depends on the domain.

REST resource design is not a competition to eliminate every verb from every URI.

## Consistency

Whatever conventions are chosen should remain predictable.

If collections are plural, use plural collections consistently.

If identifiers are UUIDs, do not unexpectedly expose database sequence IDs elsewhere without reason.

If relationships are nested according to ownership, apply the same principle across similar resources.

Consistency reduces cognitive load for API consumers.

## Implementation hiding

A client should not need to know:

- database table names;
- ORM class names;
- which microservice owns the data;
- how many internal calls happen;
- how the resource is stored.

That freedom allows the server implementation to evolve while maintaining the public contract.

## Common mistakes

### “A resource is a database row”

Too narrow.

A resource is a conceptual target with identity.

Its representation may be assembled from several systems.

### “REST requires plural nouns”

No.

Plural collection names are a useful convention, not a defining REST constraint.

### “Every endpoint containing a verb is non-RESTful”

Too simplistic.

The important issue is whether the API has coherent resource semantics and respects the architectural constraints.

### “Nested URLs should mirror object relationships”

Not automatically.

Deep nesting can leak implementation structure and create unnecessary coupling.

### “Expose the ORM and the API is finished”

Dangerous.

Persistence models and public contracts evolve for different reasons.

### “PATCHing a status field models every workflow”

Not necessarily.

Business transitions can carry invariants and side effects that deserve explicit domain modeling.

## Interview answer

When designing a REST API, I begin by identifying stable domain resources rather than writing endpoint verbs.

A resource is a conceptual entity or collection with an identifier; it is not necessarily a database row. Clients exchange representations of those resources while implementation details stay hidden.

I normally use predictable URI conventions such as plural collection names because they improve consistency, but I do not treat those conventions as the definition of REST.

I also avoid blindly mirroring database relationships into deeply nested URLs. I choose resource boundaries and granularity based on client workflows, identity, ownership, authorization and the domain's business semantics.

## Exercises for later study

1. Model the main resources of an ecommerce domain containing products, customers, carts, orders, payments and refunds.
2. Decide whether a review should be addressable only through a product or also through its own identifier.
3. Refactor an RPC-style API containing `/getUsers`, `/createUser` and `/deleteUser` into a resource-oriented interface.
4. Decide whether an order refund should be a field update, an action or its own resource.
5. Find a case where deep resource nesting creates unnecessary coupling.
6. Explain why a public API should not automatically mirror the database schema.
7. Design identifiers for “current cart” and a historical cart and explain the semantic difference.

## Source review notes

The private SOT provides useful practical conventions:

- model domain entities as resources;
- prefer resource-oriented identifiers over CRUD verbs;
- distinguish collections from individual members;
- use nested resources to express meaningful relationships.

The public material refines those ideas:

- a REST resource is a conceptual mapping with identity, not simply a database entity;
- representations are separate from resources;
- plural nouns are treated as a convention rather than a REST requirement;
- nested identifiers are evaluated according to identity and ownership rather than generated mechanically;
- public resource design is deliberately separated from persistence schema;
- domain transitions may require richer modeling than generic CRUD.
