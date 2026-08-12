# Unit 08 – Querying and API Evolution

[English](08-querying-api-evolution.md) | [Italiano](08-querying-api-evolution.it.md)

## Learning objective

Design collection APIs that remain efficient as data grows and evolve public contracts without unexpectedly breaking existing clients.

The two main concerns are:

- controlling what a collection request returns;
- controlling how the API changes over time.

## Collection endpoints need boundaries

A collection can grow from ten records to millions.

An API that simply returns every matching resource may eventually create:

- large payloads;
- high database load;
- high serialization cost;
- slow network transfers;
- memory pressure;
- poor client performance.

Filtering, sorting and pagination are therefore part of API design, not merely frontend conveniences.

## Filtering

Filtering restricts the collection to resources matching selected criteria.

Example:

`GET /products?category=books&in_stock=true`

Typical filter dimensions include:

- status;
- category;
- owner;
- creation date;
- visibility;
- state;
- domain-specific attributes.

Filters should use documented semantics.

A client should not have to guess:

- case sensitivity;
- accepted values;
- whether ranges are inclusive;
- how multiple filters combine;
- how null or missing values behave.

## Filtering is a public contract

Once clients depend on a filter, its meaning becomes part of the API.

Changing:

`status=active`

from meaning:

> resources currently enabled

to:

> resources enabled at any time during the last month

may be a breaking semantic change even though the parameter name remains unchanged.

Compatibility includes behavior, not only syntax.

## Sorting

Sorting allows the server to return a collection in a defined order.

Example:

`GET /products?sort=price`

An API should document:

- available sort fields;
- ascending versus descending syntax;
- default order;
- tie-breaking behavior;
- interaction between sorting and pagination.

A deterministic ordering is especially important for pagination.

## Stable ordering

Suppose products are sorted only by creation timestamp.

Two products can share the same timestamp.

If the API does not define a deterministic secondary ordering, page boundaries can become unstable.

A more robust conceptual order might be:

`created_at DESC, id DESC`

The exact fields depend on the domain.

The important property is deterministic ordering.

## Pagination

Pagination divides a potentially large collection into bounded responses.

A good paginated API normally communicates enough information for the client to request subsequent results.

Common strategies include:

- page number;
- offset and limit;
- cursor or page token.

They have different trade-offs.

## Page-based pagination

Typical shape:

`GET /products?page=3&limit=20`

Advantages:

- intuitive for humans;
- useful for traditional page-number UIs;
- simple to expose.

Trade-offs:

- commonly implemented using offsets;
- large page numbers may become expensive;
- concurrent inserts or deletes can shift page boundaries.

The public page-number abstraction and the internal database implementation do not have to be identical, but they often share similar instability characteristics.

## Offset pagination

Typical shape:

`GET /products?offset=40&limit=20`

Conceptually:

- skip the first 40 matching rows;
- return the next 20.

### Strengths

- easy to understand;
- easy to implement in many databases;
- supports jumping to an arbitrary position.

### Weaknesses

On large or frequently changing datasets:

- high offsets can become expensive;
- new rows can shift later offsets;
- deletions can shift earlier offsets;
- clients can observe duplicates or skipped resources between requests.

Offset pagination is not wrong.

It is simply a trade-off.

## Cursor-based pagination

Cursor pagination returns an opaque continuation value representing where traversal should continue.

Conceptual response:

- items;
- next cursor.

The client then sends that cursor back to retrieve the next set.

### Strengths

- well suited to large collections;
- good fit for continuously changing feeds;
- can avoid expensive large offsets;
- can preserve traversal relative to a stable ordering key.

### Trade-offs

- harder to jump directly to page 847;
- cursor design must preserve ordering semantics;
- cursors should normally be opaque to clients;
- expiration and invalidation behavior must be documented.

The cursor is part of the pagination protocol, not a database implementation detail that clients should parse.

## Cursor does not mean “hash of the page”

A cursor should not be mentally modeled simply as a hash representing a page number.

It may encode or reference information such as:

- last seen sort key;
- unique identifier;
- query state;
- snapshot information;
- server-side continuation state.

The important property is continuation, not page numbering.

## Pagination should be designed early

Adding pagination after clients have already been promised an unbounded collection can break them behaviorally.

Example:

1. old API returns all 75 resources;
2. existing client assumes it receives the full collection;
3. server later introduces a default page size of 50;
4. old client silently processes only 50.

No field was removed.

The client still broke.

This is a semantic breaking change.

For collections that can grow, pagination should therefore generally be part of the original contract.

## Response metadata

A paginated response may expose useful metadata such as:

- next-page token;
- previous-page token where appropriate;
- page size;
- total count where feasible.

Total counts are not always cheap.

On large or distributed datasets, computing an exact total can require substantial work.

Do not promise an exact count unless the product truly needs it and the system can support it.

## API evolution

An API is a contract used by software outside the implementation.

Once clients are deployed, changing that contract has consequences.

Compatibility must be considered across several dimensions:

- wire format;
- source/client-library compatibility;
- behavior;
- semantics.

A structurally valid response can still be incompatible if its meaning changes.

## Common non-breaking changes

Depending on the contract and serialization model, changes often considered compatible include:

- adding a new optional endpoint;
- adding a new optional request parameter;
- adding an optional response field that clients are expected to ignore safely;
- relaxing an input restriction;
- adding new functionality without changing existing behavior.

These are not universally safe.

Client implementations can make undocumented assumptions.

Compatibility must be evaluated against the actual contract.

## Common breaking changes

Examples include:

- removing a field;
- renaming a field;
- changing a field type incompatibly;
- making an optional input required;
- removing an accepted enum value;
- changing the format of an existing value;
- changing the meaning of a field;
- changing resource identifiers;
- changing ordering guarantees relied on by clients;
- changing a formerly complete collection into an implicitly truncated paginated response.

A breaking change can therefore be syntactic, structural or semantic.

## Semantic compatibility

Semantic changes are easy to underestimate.

Suppose:

`GET /orders/{id}`

has always returned:

`status = shipped`

only after the carrier accepted the package.

If the server silently changes that meaning to:

`status = shipped`

as soon as the warehouse prints a label, existing clients may behave incorrectly.

The field name and type did not change.

The contract still broke.

## Versioning

Versioning is a tool for managing incompatible evolution.

A common REST convention is path versioning:

`/api/v1/products`

followed by:

`/api/v2/products`

when a new incompatible contract is introduced.

This is easy to understand and operate.

It is not the only possible strategy.

Other systems can negotiate representation or API versions through headers or media-type conventions.

The important issue is not where the version number is written.

The important issue is:

- what exactly is versioned;
- what counts as compatible;
- how long versions coexist;
- how clients migrate;
- how deprecation is communicated.

## Do not version every change

A new major version should not be the reflex for every feature.

If a change preserves the existing contract, maintaining the same version is normally simpler.

Examples that often do not require a major version:

- adding an optional endpoint;
- adding an optional response property;
- adding optional functionality;
- fixing implementation details without changing observable semantics.

Creating excessive versions increases:

- maintenance burden;
- testing matrix;
- documentation complexity;
- deployment complexity;
- migration cost.

## Versioning does not replace compatibility discipline

Even when versioning exists, careless breaking changes are expensive.

Supporting:

- v1;
- v2;
- v3;
- v4;

simultaneously can create substantial engineering cost.

Prefer compatible evolution whenever reasonable.

Use a new major contract when incompatibility is genuinely necessary.

## Deprecation

Removing an old API version should be a managed lifecycle event.

A useful deprecation process includes:

1. publish the replacement;
2. document migration;
3. announce deprecation;
4. provide a reasonable coexistence period;
5. observe remaining usage;
6. contact important consumers where possible;
7. retire the old version only after the migration window.

Versioning without a retirement policy creates permanent legacy surfaces.

## Client independence matters

Compatibility becomes more important as consumers become more independent.

A private API used by one tightly coordinated application can sometimes tolerate synchronized change.

A public API used by unknown third parties cannot assume synchronized deployment.

Even internal APIs benefit from treating consumers as independently evolving clients.

This reduces organizational coupling.

## Filtering, sorting and pagination interact

These concerns cannot be designed independently.

A cursor created for:

`status=active&sort=-created_at`

should not normally be reused against:

`status=archived&sort=name`

The continuation token belongs to a particular traversal definition.

Likewise, changing sort rules between requests can invalidate pagination assumptions.

The API contract should make these interactions clear.

## Security and query complexity

Flexible querying can become an attack or resource-exhaustion surface.

Potential problems include:

- unbounded page size;
- expensive arbitrary sorting;
- filters that bypass indexes;
- enormous result sets;
- combinations producing expensive database plans.

APIs should generally define:

- maximum page sizes;
- allowed sort fields;
- allowed filters;
- validation rules;
- rate limits.

Flexibility needs operational boundaries.

## Common mistakes

### “Pagination is a frontend concern”

No.

It protects server, network and client resources and is part of the public API contract.

### “Offset pagination is bad”

Too absolute.

It can be perfectly appropriate for small or stable datasets and page-number interfaces.

### “Cursor pagination is always better”

No.

It trades arbitrary navigation simplicity for traversal stability and scalability characteristics.

### “A cursor is just an encoded page number”

Incorrect mental model.

It represents continuation state.

### “Adding pagination later is non-breaking because no fields were removed”

Incorrect.

Changing an endpoint from complete collection to partial collection can break client behavior.

### “Adding a field can never break a client”

Too absolute.

Well-designed clients should tolerate compatible additions when the contract promises them, but actual compatibility depends on serialization rules and documented expectations.

### “If the JSON schema still validates, the change is compatible”

No.

Semantic behavior can break consumers without changing structure.

### “Version every deployment”

No.

Version the public contract when incompatible evolution requires it, not the implementation release.

## Interview answer

For collection APIs I design filtering, sorting and pagination as part of the contract from the beginning.

Offset pagination is simple and useful when arbitrary page access matters, but it can become expensive and unstable on highly dynamic datasets. Cursor pagination is often a better fit for large feeds because it continues from a stable ordering position rather than repeatedly skipping rows.

For API evolution I distinguish structural compatibility from semantic compatibility. Removing or renaming fields is obviously breaking, but changing the meaning of an existing field or silently changing an unpaginated collection into a paginated one can also break clients.

I prefer backwards-compatible evolution where possible. When an incompatible contract is necessary, I introduce an explicit version and provide a migration and deprecation path rather than forcing all clients to update simultaneously.

## Exercises for later study

1. Compare offset and cursor pagination for a social feed with frequent inserts.
2. Design pagination for an administrative table where users must jump directly to page 100.
3. Define deterministic sorting for a collection where many rows share the same timestamp.
4. Classify ten proposed API modifications as likely compatible or breaking.
5. Find three examples of semantic breaking changes that do not modify JSON field names.
6. Design the migration from `/api/v1/orders` to an incompatible v2.
7. Decide whether returning an exact total count is worth its operational cost for a billion-row dataset.
8. Design maximum page-size and sorting rules that prevent abusive queries.
9. Explain why an opaque cursor should not be parsed by clients.

## Source review notes

The private SOT correctly introduces:

- filtering through query parameters;
- sorting on the server;
- page/limit pagination;
- offset/limit pagination;
- cursor-based pagination;
- version prefixes such as `/api/v1`;
- the need to preserve older clients during breaking API evolution.

The public material refines that model:

- pagination is treated as part of the original public contract;
- cursor pagination is modeled as continuation state rather than a hash of a page;
- deterministic ordering is made explicit;
- total counts are treated as potentially expensive;
- filtering, sorting and pagination are considered together;
- backwards compatibility includes semantic behavior, not only response shape;
- versioning is treated as one tool for incompatible evolution rather than a mandatory prefix for every API;
- deprecation and coexistence are included as part of the API lifecycle.
