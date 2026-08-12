# Unit 11 – Authorization

[English](11-authorization.md) | [Italiano](11-authorization.it.md)

## Learning objective

Understand how systems decide whether an authenticated principal may perform a specific action on a specific resource.

The fundamental authorization question is:

> Given this identity, this action, this resource and this context, should access be allowed?

Authentication establishes identity.

Authorization evaluates permissions and policy.

## Authorization is a decision

An authorization decision normally involves several inputs:

- principal;
- requested action;
- target resource;
- resource attributes;
- principal attributes;
- environment or request context;
- applicable policy.

A useful conceptual model is:

principal + action + resource + context → allow or deny

This is more precise than asking only:

> What role does this user have?

Roles can be one useful input, but they are not the entire authorization problem.

## Authentication and authorization remain separate

Suppose a request contains a valid authenticated identity.

That tells the system who made the request.

It does not automatically determine whether the request may:

- read an invoice;
- edit another user's profile;
- delete a repository;
- approve a payment;
- access confidential records.

Authorization begins after identity has been established.

## Principle of least privilege

A principal should receive only the authority required to perform its intended function.

This applies to:

- users;
- administrators;
- services;
- automation;
- CI systems;
- third-party applications.

Granting broad permissions because they are easier to configure increases the impact of mistakes and credential compromise.

## RBAC

Role-Based Access Control assigns permissions to roles and roles to principals.

Example roles:

- admin;
- editor;
- viewer.

Example permissions:

admin:

- create;
- read;
- update;
- delete;
- manage users.

editor:

- create;
- read;
- update.

viewer:

- read.

A user receives permissions by being assigned one or more roles.

## Why RBAC is useful

RBAC reduces permission-management complexity.

Without roles, permissions may need to be assigned directly to every user.

With roles:

users → roles → permissions

This works well when organizational responsibilities are relatively stable.

Typical examples include:

- administrative panels;
- CMS applications;
- internal business systems;
- repository access;
- team-management tools.

## RBAC trade-offs

RBAC can become difficult when policies depend heavily on context.

Suppose editors may modify documents only when:

- they belong to the same department;
- the document is not classified;
- access occurs from a managed device;
- the request happens during a specific workflow state.

Creating a separate role for every possible combination can produce role explosion.

This is where attribute-based rules may fit better.

## ABAC

Attribute-Based Access Control evaluates attributes of:

- the subject;
- the resource;
- the requested action;
- the environment.

Conceptual policy:

allow when:

- subject.department = resource.department;
- action = read;
- resource.classification <= subject.clearance;
- device.trusted = true.

ABAC can express policies that would require many roles in a pure RBAC model.

## Subject attributes

Examples:

- department;
- employment type;
- security clearance;
- tenant;
- region;
- age or eligibility status.

These properties describe the requesting principal.

## Resource attributes

Examples:

- owner;
- tenant;
- classification;
- status;
- region;
- sensitivity.

These describe the target being accessed.

## Environment attributes

Examples:

- current time;
- network;
- device trust;
- geographic location;
- authentication strength.

These allow contextual policies.

## ABAC strengths

ABAC is useful for:

- fine-grained policies;
- multi-tenant systems;
- context-dependent access;
- large combinations of user and resource properties;
- rules that change independently from organizational roles.

## ABAC trade-offs

More flexibility creates more policy complexity.

Potential problems include:

- conflicting rules;
- difficult debugging;
- hard-to-explain denials;
- expensive policy evaluation;
- stale attributes;
- inconsistent policy enforcement.

Fine-grained authorization needs strong observability and testing.

## ACL

An Access Control List associates permissions directly with a resource.

Conceptually:

document 123:

- Alice → read;
- Bob → read, write;
- Carol → no explicit access.

This is resource-centric authorization.

Common examples include:

- shared documents;
- files;
- repositories;
- cloud objects;
- calendars.

## ACL strengths

ACLs are useful when individual resources need distinct sharing relationships.

They answer questions such as:

> Who can access this exact document?

This can be more natural than inventing global roles for every sharing relationship.

## ACL trade-offs

At large scale, ACLs can create:

- huge numbers of permission entries;
- difficult audits;
- expensive inheritance rules;
- complicated revocation;
- hard-to-understand effective permissions.

Systems often introduce groups or roles to avoid assigning every user independently.

## RBAC, ABAC and ACL can coexist

Real systems frequently combine these models.

Example document platform:

RBAC:

- administrator can manage organization settings.

ABAC:

- employee can create documents only in their own tenant.

ACL:

- document 123 is shared with Alice as editor and Bob as viewer.

Using several models is not inherently bad design.

Each model can solve a different layer of the authorization problem.

## Ownership is an authorization attribute

A common rule is:

> users may modify resources they own.

Ownership should not simply be inferred from an identifier supplied by the client.

The server should evaluate the authenticated identity against trusted resource state.

For example:

authenticated user = 42

request:

`DELETE /documents/913`

server checks:

document 913 owner = 42?

The client cannot authorize itself by sending:

`owner_id = 42`

Authorization uses trusted server-side facts.

## Multi-tenant authorization

Multi-tenant systems need especially careful resource isolation.

A request may be valid for:

- the correct user;
- the correct role;

but still target a resource belonging to another tenant.

Every access path should preserve tenant boundaries.

A common authorization condition is conceptually:

principal.tenant_id == resource.tenant_id

Tenant isolation should not depend only on the UI hiding foreign identifiers.

## Claims

A claim is an assertion about a subject or token context.

Examples may include:

- subject identifier;
- issuer;
- audience;
- role;
- tenant;
- authentication method;
- custom attributes.

Claims can provide useful input to authorization decisions.

But:

> claim ≠ permission decision

The application still needs policy defining what those claims mean for the requested resource and action.

## Trusted claims

Authorization must not trust arbitrary client-provided values.

A claim is useful only when its source and integrity have been validated according to the authentication or token protocol.

For example:

`role = admin`

inside unsigned request JSON should not grant administrative access.

The same textual value inside a validated token from a trusted issuer may be an authorization input.

Trust context matters.

## OAuth scopes

OAuth scopes describe requested or granted access boundaries in an authorization flow.

Conceptual examples:

- `profile:read`;
- `orders:read`;
- `orders:write`.

A scope can communicate what authority a client has been granted.

But a scope still does not necessarily answer every resource-level question.

For example:

`orders:write`

might permit writing orders generally, while application policy still needs to determine:

- which tenant;
- which order;
- which state transition;
- which ownership relationship.

Scopes and application authorization complement each other.

## Scope versus role

A role generally describes a principal's function within a system.

Example:

`billing-admin`

A scope commonly describes authority delegated to a client or token.

Example:

`invoices:read`

They can overlap in implementation, but they model different concepts.

Do not use the words interchangeably without defining the contract.

## Token versus policy

A token can carry information such as:

- subject;
- scope;
- roles;
- claims.

The token is an input artifact.

The authorization policy evaluates whether the request is permitted.

Conceptually:

validated token
→ identity and claims
→ authorization policy
→ allow / deny

A token does not replace policy.

## Policy enforcement point

Authorization needs to be enforced where access actually occurs.

Examples:

- HTTP endpoint;
- GraphQL resolver;
- service method;
- database access layer;
- message consumer.

Checking permission only in the UI is not authorization.

An attacker can bypass the UI and call the backend directly.

## Centralized versus distributed policy

A system may implement authorization:

- directly inside each service;
- through shared libraries;
- through a policy engine;
- through an external authorization service;
- using a hybrid approach.

Centralized policy can improve consistency.

But a centralized authorization dependency can also introduce:

- latency;
- availability concerns;
- cache-consistency problems;
- operational complexity.

The correct architecture depends on scale and policy complexity.

## Default deny

A robust authorization model normally starts from:

> deny unless an explicit policy allows access.

This is safer than assuming access and attempting to enumerate every prohibited condition.

New resources and actions should not accidentally become available simply because nobody wrote a deny rule.

## Authorization must be server-side

Client-side checks improve user experience.

For example, hiding a Delete button from a viewer is useful.

But the server must independently reject the forbidden request.

Client code is controlled by the client.

It cannot be the security boundary.

## Object-level authorization

A user may have permission to access one object but not another of the same type.

Example:

`GET /invoices/10` → allowed

`GET /invoices/11` → forbidden

because invoice 11 belongs to another customer.

Endpoint-level authorization alone is therefore insufficient.

The server must authorize the specific target object.

## Field-level authorization

Some APIs expose resources containing fields with different sensitivity.

Example user resource:

- public name;
- avatar;
- email;
- salary.

A principal might be allowed to retrieve the user object but not every field.

This is especially relevant in GraphQL, where clients choose selected fields dynamically.

## Action-level authorization

Reading a resource and changing it are different permissions.

Typical actions include:

- read;
- create;
- update;
- delete;
- approve;
- publish;
- refund;
- administer.

Model real business actions rather than collapsing every permission into generic CRUD when the domain requires more precision.

## Authorization and resource state

Permissions can depend on current state.

Example:

an editor may modify an article while:

`status = draft`

but not after:

`status = published`.

Authorization can therefore depend on:

principal + action + resource + current state

This is another case where pure role checks may be insufficient.

## Time-of-check versus time-of-use

Authorization can become stale between checking permission and performing the operation.

Conceptually:

1. permission is checked;
2. resource state changes;
3. operation executes based on the old decision.

Critical systems may need authorization and state-transition checks inside the same transactional or consistency boundary.

Authorization is not always a one-time middleware check.

## Authorization caching

Caching permission decisions can improve performance.

But cached authorization creates invalidation problems.

Suppose:

1. Alice has admin permission;
2. decision is cached for ten minutes;
3. Alice's admin role is revoked;
4. cached decision still allows access.

The acceptable cache lifetime depends on security requirements.

Performance and revocation speed are trade-offs.

## Auditability

Sensitive authorization decisions should often be auditable.

Useful information can include:

- principal;
- action;
- resource;
- decision;
- policy or reason;
- timestamp;
- correlation identifier.

Audit logs should avoid exposing unnecessary secrets while still supporting investigation.

## Explainable denial

Complex authorization benefits from understandable denial reasons.

Internal diagnostics may distinguish:

- wrong tenant;
- insufficient role;
- missing scope;
- resource state incompatible;
- policy condition failed.

External API responses may intentionally expose less information for security.

Internal observability and external disclosure are different concerns.

## 401 versus 403

Authentication failure and authorization denial should remain distinct.

Typical model:

401:

> authentication is missing or invalid.

403:

> the request was understood, but policy refuses it.

A security-sensitive service may return 404 instead of 403 to conceal the existence of a resource.

## Common mistakes

### “The user has an admin role, so no more checks are needed”

Too simplistic.

Tenant, resource ownership, action and context can still matter.

### “Claims are permissions”

Not necessarily.

Claims provide assertions that policy may use.

### “Scopes are roles”

Not necessarily.

They commonly represent delegated authority associated with a token or client.

### “Authorization happens in the frontend”

Incorrect.

Frontend checks are presentation logic, not the security boundary.

### “If the endpoint is protected, every object returned by it is authorized”

Incorrect.

Object-level authorization is still required.

### “RBAC and ABAC are competitors and I must choose exactly one”

No.

Hybrid models are common.

### “ACLs do not scale”

Too absolute.

They can scale with careful data modeling, grouping, inheritance and indexing, but they introduce management complexity.

### “Authorization is one middleware check”

Not always.

Resource state and business transitions may require deeper enforcement.

## Interview answer

Authorization decides whether an authenticated principal may perform a specific action on a specific resource under the current context.

I distinguish authorization models from token mechanisms. RBAC assigns permissions through roles and works well for stable organizational responsibilities. ABAC evaluates subject, resource and environment attributes and is useful for fine-grained contextual policy. ACLs attach permissions to individual resources and are natural for sharing models such as documents.

Real systems often combine these approaches.

Claims, roles and OAuth scopes are inputs to authorization; they are not the authorization decision themselves. I validate the identity and token first, then evaluate trusted claims against server-side resource state and policy.

I also enforce authorization server-side at object and action level, default to deny, preserve tenant boundaries and consider revocation, caching and auditability as part of the design.

## Exercises for later study

1. Model a CMS using admin, editor and viewer roles.
2. Identify where pure RBAC produces role explosion and replace part of it with ABAC.
3. Design an ACL model for document sharing with users and groups.
4. Design authorization for a multi-tenant invoice API.
5. Explain why `orders:write` scope may still be insufficient to authorize one specific order.
6. Decide which JWT claims are useful authorization inputs and which facts must be read from server-side resource state.
7. Design object-level and field-level authorization for a GraphQL User type.
8. Explain how authorization caching affects permission revocation.
9. Model an article workflow where permissions change between draft and published states.
10. Design audit information for a sensitive administrative action.

## Source review notes

The private SOT correctly introduces:

- authorization as the step determining what an authenticated user may do;
- RBAC;
- ABAC;
- ACL;
- roles and permissions;
- attributes of users, resources and environment;
- resource-specific permission lists;
- OAuth and token information as authorization mechanisms.

The public material refines and extends that model:

- authorization is expressed explicitly as principal + action + resource + context;
- least privilege and default deny are introduced;
- RBAC, ABAC and ACL are treated as complementary models rather than mutually exclusive choices;
- ownership and tenant boundaries are treated as trusted server-side authorization facts;
- claims are separated from policy decisions;
- OAuth scopes are separated from roles and resource-level permissions;
- validated tokens are treated as policy inputs rather than authorization engines;
- object-level, field-level and action-level authorization are added;
- policy enforcement is required server-side;
- resource state, time-of-check/time-of-use, caching and revocation are included;
- auditability and explainable denial are treated as operational authorization concerns.
