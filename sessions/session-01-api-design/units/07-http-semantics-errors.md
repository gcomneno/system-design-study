# Unit 07 – HTTP Semantics and Errors

[English](07-http-semantics-errors.md) | [Italiano](07-http-semantics-errors.it.md)

## Learning objective

Design HTTP operations whose methods, retry behavior, success responses and error responses communicate clear and predictable semantics.

The goal is not to memorize status codes.

The goal is to understand what clients are allowed to infer from the protocol contract.

## Safe methods

A method is safe when its defined semantics are read-only.

The classic examples are:

- GET;
- HEAD.

A safe request is not supposed to ask the server to change application state.

This does not mean the server performs literally no side effects.

A server may still:

- log the request;
- update metrics;
- populate caches;
- record diagnostics.

Those incidental effects do not change the intended semantics requested by the client.

## Idempotent methods

A method is idempotent when repeating the same request has the same intended effect as performing it once.

Important examples include:

- GET;
- HEAD;
- PUT;
- DELETE.

Idempotence matters when the client does not know whether a request succeeded.

Suppose:

1. a client sends a PUT;
2. the server applies it;
3. the connection fails before the response arrives;
4. the client cannot tell whether the operation completed.

Because PUT is idempotent by definition, retrying the same intended operation can be safe at the HTTP semantic level.

The response to the retry does not have to be identical.

The important property is the intended final effect.

## Idempotence does not mean identical observations

An idempotent request can still:

- create another log entry;
- update request metrics;
- produce a different timestamp;
- return a different response because another actor changed the resource.

Idempotence concerns the intended effect of the request itself.

## POST

POST asks the target resource to process the enclosed content according to that resource's own semantics.

Common uses include:

- creating a server-identified resource;
- submitting a command;
- appending data;
- triggering processing.

POST is not idempotent by default.

Consider:

`POST /orders`

If the first request creates order A but its response is lost, blindly repeating the POST might create order B.

Applications that need retry-safe creation often introduce an application-level mechanism such as:

- idempotency key;
- client request identifier;
- deduplication record.

HTTP method semantics and application-level retry guarantees are separate concerns.

## PUT

PUT requests that the state of the target resource be created or replaced according to the supplied representation.

For example:

`PUT /users/42`

means that the client is addressing a known target resource.

If repeated with the same intended representation, PUT remains idempotent at the HTTP semantic level.

A successful PUT can:

- create the target resource if creation is allowed;
- replace the state of an existing target resource.

PUT should not be treated merely as a synonym for “update”.

Its semantics concern the state of the target resource.

## PATCH

PATCH applies a set of modifications to an existing resource.

Unlike PUT, PATCH is not defined as idempotent.

Whether a particular PATCH operation behaves idempotently depends on the patch document and application semantics.

For example, conceptually:

`set phone = X`

can be designed to be idempotent.

But:

`increment balance by 10`

is not idempotent if repeating it applies the increment twice.

Therefore clients must not infer retry safety merely because the method is PATCH.

## DELETE

DELETE is idempotent in terms of the intended effect.

Deleting the same resource twice does not mean both responses must be identical.

A first request might return success while a later request might indicate that the resource is no longer present.

The requested final state remains that the association represented by the target resource is removed.

## Success status codes

### 200 OK

Use 200 when the request succeeds and the response carries content appropriate to the operation.

It is a general successful response, not the only success status.

### 201 Created

Use 201 when processing the request creates one or more resources.

When practical, the response can identify the primary created resource through `Location`.

Typical example:

`POST /orders`

creates a new server-identified order.

### 202 Accepted

Use 202 when the request has been accepted for processing but processing has not necessarily completed.

This is useful for asynchronous workflows.

A 202 response should not be interpreted as proof that the business operation eventually succeeded.

### 204 No Content

Use 204 when the request was successfully fulfilled and there is no response content to send.

Typical cases include successful updates or deletions where the client does not need a representation in the response.

A 204 response cannot contain response content.

## Client-error status codes

### 400 Bad Request

400 represents a problem with the request that prevents the server from processing it according to the expected syntax or framing.

Typical API use includes malformed request content.

Do not use 400 as a universal bucket for every possible client-side business condition.

### 401 Unauthorized

Despite its historical name, 401 concerns HTTP authentication.

Use it when valid authentication credentials for the protected resource are missing or insufficiently established.

A protected API commonly returns 401 when:

- credentials are absent;
- a bearer token is invalid;
- authentication must be performed again.

Think:

> Authentication has not been successfully established.

### 403 Forbidden

403 means the server understands the request but refuses to fulfill it.

In a typical authenticated API this often means:

> I know who you are, but you are not allowed to do this.

However, 403 is broader than one specific RBAC scenario.

A server may also deliberately return 404 instead when it wants to avoid revealing the existence of a forbidden resource.

### 404 Not Found

404 means the origin server did not find a current representation for the target resource or is unwilling to disclose that one exists.

This second possibility matters for security-sensitive APIs.

A 404 therefore does not always prove that the underlying object literally does not exist.

### 409 Conflict

409 indicates that the request conflicts with the current state of the target resource.

Examples can include:

- incompatible concurrent state;
- attempting a transition that conflicts with current state;
- an operation that cannot be completed because of a state conflict.

Do not reduce 409 to “duplicate email”.

Whether duplicate input is best represented as 409 depends on the resource model and API contract.

### 422 Unprocessable Content

422 means the server understands the content type and the request syntax is valid, but it cannot process the contained instructions.

It is often useful for semantically invalid input.

Example:

- JSON is syntactically valid;
- the fields can be parsed;
- the requested domain operation is not semantically acceptable.

The exact distinction between 400 and 422 should be documented consistently by the API.

### 429 Too Many Requests

429 indicates that the client has sent too many requests within the server's rate-limiting policy.

A response may include information about when the client should retry.

The server decides how requests are counted.

Possible dimensions include:

- authenticated identity;
- token;
- IP;
- resource;
- endpoint;
- service-wide policy.

## Server-error status codes

### 500 Internal Server Error

500 represents an unexpected condition that prevented the server from fulfilling the request.

Do not use 500 for known client validation failures.

A 500 response should also avoid exposing:

- stack traces;
- database credentials;
- internal paths;
- secrets;
- implementation details.

## Error responses need an application contract

HTTP status codes communicate broad protocol semantics.

Applications often need more information.

A useful error representation can include:

- stable application error code;
- human-readable message;
- field-level validation details;
- correlation or trace identifier;
- documentation reference where appropriate.

Example conceptual structure:

`code = EMAIL_ALREADY_USED`

`message = An account already uses this email`

The machine-readable code should remain stable even if the human-readable wording changes.

## Do not encode every business condition into a new HTTP status

HTTP status codes describe protocol-level outcome categories.

Domain-specific conditions usually belong in the response representation.

For example, several business rules can legitimately share the same HTTP status while using different application error codes.

This keeps the HTTP layer understandable without losing domain precision.

## Retry semantics

Before retrying a failed request, ask:

1. Is the HTTP method idempotent?
2. Is this concrete operation actually retry-safe?
3. Could the original request already have caused a side effect?
4. Can the client detect duplicate processing?
5. Is the failure transient?
6. Has the server supplied retry guidance?

Retry logic belongs to the operation's semantics, not merely to the fact that an error occurred.

## Timeout ambiguity

A timeout does not prove failure.

Example:

1. client sends `POST /payments`;
2. server processes the charge;
3. response is lost;
4. client times out.

The client knows only that it did not receive a response.

It does not know whether the charge happened.

This ambiguity is a central distributed-systems problem.

Possible mitigations include:

- idempotency keys;
- operation identifiers;
- status lookup;
- deduplication;
- reconciliation.

## Conditional requests and lost updates

Concurrent modification can create another failure mode.

Consider:

1. client A reads version 10;
2. client B modifies the resource to version 11;
3. client A writes based on stale version 10.

Conditional requests can protect against overwriting newer state.

Mechanisms such as ETag plus `If-Match` allow the client to express:

> Apply my modification only if the resource is still the version I observed.

This is particularly useful for state-changing requests including some PATCH workflows.

## A practical status-code map

| Situation | Typical status |
|---|---|
| Successful request with response content | 200 |
| Resource successfully created | 201 |
| Accepted for asynchronous processing | 202 |
| Successful request with no response content | 204 |
| Malformed request | 400 |
| Authentication missing or invalid | 401 |
| Request understood but forbidden | 403 |
| Resource absent or intentionally concealed | 404 |
| Conflict with current resource state | 409 |
| Semantically unprocessable content | 422 |
| Rate limit exceeded | 429 |
| Unexpected server failure | 500 |

This is a design guide, not a replacement for the HTTP specification or an API-specific contract.

## Common mistakes

### “401 means authenticated but unauthorized”

Wrong.

That common case belongs to 403.

### “403 means the user does not exist”

Wrong mental model.

403 concerns refusal to fulfill the understood request.

### “Every validation error must be 422”

No.

An API needs a consistent documented distinction between malformed requests, semantic validation and domain conflicts.

### “PATCH is idempotent because it updates only part of a resource”

Incorrect.

Partial modification and idempotence are independent properties.

### “DELETE must return the same response every time”

Incorrect.

Idempotence concerns intended effect, not identical responses.

### “Timeout means the server did nothing”

Dangerous.

The operation might have completed before communication failed.

### “Retry every 500”

Dangerous.

Retry policy must account for operation semantics, failure type and backoff.

## Interview answer

I design HTTP APIs so that method semantics and retry behavior are explicit.

GET and HEAD are safe, while PUT, DELETE and safe methods are idempotent. POST is not idempotent by default, and PATCH is not guaranteed to be idempotent; retry safety therefore depends on the concrete operation.

For status codes I use the most specific protocol meaning that fits the outcome: 201 for created resources, 204 for successful responses without content, 401 when authentication is missing or invalid, 403 when the server refuses an understood request, 409 for conflicts with current state, 422 for semantically unprocessable content, and 429 for rate limiting.

Most importantly, I treat network timeouts as ambiguous. For non-idempotent business operations such as payments, I add application-level idempotency or reconciliation instead of assuming that a retry is safe.

## Exercises for later study

1. Explain why retrying PUT is fundamentally different from blindly retrying POST.
2. Design an idempotency mechanism for `POST /payments`.
3. Decide whether five example validation failures should return 400, 409 or 422 and justify the contract.
4. Explain a legitimate case where an API returns 404 instead of 403.
5. Design an asynchronous export API using 202 and a status resource.
6. Model a lost-update problem and solve it with ETag and `If-Match`.
7. Explain why an idempotent DELETE can return different responses across retries.
8. Design a stable JSON error contract containing machine-readable and human-readable information.

## Source review notes

The private SOT correctly introduces:

- HTTP methods for CRUD-style operations;
- safe and idempotent GET;
- POST for creation;
- PUT and PATCH for modification;
- DELETE;
- major status-code families;
- 200, 201, 204, 400, 401, 404 and 500.

The public material deliberately extends and refines that model:

- safe and idempotent are treated as distinct properties;
- PUT idempotence is separated from response equality;
- PATCH is not assumed to be idempotent;
- timeout ambiguity and retry semantics are made explicit;
- 401 and 403 are distinguished carefully;
- 409, 422 and 429 are added;
- 202 is included for asynchronous processing;
- HTTP status codes are separated from application error codes;
- conditional requests are introduced as a defense against lost updates.
