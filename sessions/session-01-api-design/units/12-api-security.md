# Unit 12 – API Security

[English](12-api-security.md) | [Italiano](12-api-security.it.md)

## Learning objective

Reason about API security as a layered system rather than a checklist of isolated controls.

A secure API needs to consider:

- transport security;
- authentication;
- authorization;
- input handling;
- resource consumption;
- browser security boundaries;
- secrets and credentials;
- downstream dependencies;
- network exposure;
- monitoring and incident response.

No single mechanism solves all of these problems.

## Security is layered

A useful mental model is defense in depth.

For example:

HTTPS
→ authenticated identity
→ authorization
→ input validation
→ safe data access
→ resource limits
→ monitoring

A failure at one layer should not automatically compromise every other layer.

## Start with the threat model

Security decisions should begin with questions such as:

- Who can call the API?
- Is it public or internal?
- What data does it expose?
- What operations can cause irreversible effects?
- Which credentials are used?
- What happens if a token is stolen?
- Which downstream systems are trusted?
- What resources can a request consume?
- What would an attacker gain from automation?

Security without a threat model easily becomes cargo-cult configuration.

## Transport security

Sensitive API communication should use TLS.

TLS protects data in transit against passive observation and undetected modification within the protected channel.

TLS does not replace:

- authentication;
- authorization;
- secure storage;
- input validation;
- endpoint security.

An application can use HTTPS and still be completely vulnerable at the application layer.

## Authentication

Authentication establishes the identity of the caller.

Security concerns include:

- credential theft;
- weak passwords;
- leaked bearer tokens;
- expired or improperly validated tokens;
- insecure sessions;
- incorrect JWT validation;
- unsafe refresh-token handling.

Authentication design was covered in Unit 10.

## Authorization

Authorization determines what an authenticated principal may do.

Important checks can occur at:

- function level;
- object level;
- property or field level;
- tenant level;
- workflow-state level.

A valid authenticated identity does not imply permission to access every object of a given type.

Authorization design was covered in Unit 11.

## Broken object-level authorization

Consider:

`GET /invoices/100`

A user may legitimately access invoice 100.

Changing the identifier to:

`GET /invoices/101`

must not expose another customer's invoice merely because the identifier exists.

The server must authorize the specific object.

Never rely on:

- identifiers being difficult to guess;
- the frontend hiding foreign objects;
- sequential IDs remaining secret.

Object identifiers identify resources.

They are not authorization credentials.

## Broken property-level authorization

A client may be allowed to access a resource without being allowed to read or modify every property.

Example user object:

- public name;
- email;
- role;
- salary;
- internal flags.

The server should explicitly control which properties can be:

- returned;
- accepted as input;
- modified.

Blindly serializing every ORM property can leak sensitive information.

Blindly applying every client-provided field can permit unauthorized modification.

## Function-level authorization

Different operations can require different authority.

For example:

- viewer → read;
- editor → modify content;
- administrator → delete account;
- finance operator → approve refund.

Hiding an administrative route from the UI does not secure it.

The backend must enforce the permission.

## Input validation

All external input should be treated as untrusted until validated.

Sources include:

- path parameters;
- query parameters;
- headers;
- JSON bodies;
- file uploads;
- message queues;
- webhooks;
- responses from third-party APIs.

Validation should consider:

- type;
- format;
- allowed values;
- length;
- numeric bounds;
- collection size;
- domain invariants.

Validation reduces attack surface and prevents malformed data from reaching deeper layers.

## Validation is not the same as escaping

Validation asks:

> Is this input acceptable for this operation?

Encoding, escaping or parameterization asks:

> How can this value be safely used in a particular interpreter or output context?

Both can be necessary.

One does not replace the other.

## Injection

Injection occurs when untrusted data is interpreted as part of a command or query rather than as data.

Targets can include:

- SQL;
- NoSQL;
- operating-system commands;
- LDAP;
- template engines;
- other interpreters.

A fundamental defense is to keep data separate from executable syntax.

For databases this commonly means parameterized queries or properly designed database APIs rather than string concatenation.

Validation remains useful but should not be the only protection against injection.

## ORM does not automatically prevent injection

Using an ORM can reduce direct string construction, but unsafe raw queries or dynamic expressions can reintroduce injection vulnerabilities.

Security depends on how the abstraction is used.

Framework choice does not eliminate the need to understand data flow.

## Resource consumption

Every API request consumes resources.

Possible costs include:

- CPU;
- memory;
- network bandwidth;
- database work;
- storage;
- external API calls;
- financial cost.

An attacker does not always need a traditional exploit.

Making an API perform legitimate but expensive work repeatedly may be enough to degrade the service.

## Rate limiting

Rate limiting restricts how frequently a client can perform requests or particular operations.

Possible dimensions include:

- IP address;
- account;
- token;
- tenant;
- endpoint;
- operation;
- global service capacity.

Different operations can require different limits.

For example:

- normal product reads;
- login attempts;
- password recovery;
- OTP verification;
- expensive report generation

should not necessarily share one policy.

## Rate limiting is not complete DDoS protection

Rate limiting is one resource-protection mechanism.

Large distributed attacks can also require controls at:

- CDN;
- edge network;
- load balancer;
- infrastructure provider;
- network firewall;
- specialized DDoS mitigation service.

Application rate limiting remains useful, but it should not be described as a complete DDoS strategy.

## Bound resource usage

APIs should also consider limits on:

- upload size;
- request-body size;
- page size;
- number of records requested;
- GraphQL complexity;
- batch size;
- concurrent operations;
- execution time;
- downstream calls.

A single request can be dangerous even when request frequency is low.

## Timeouts

Calls to downstream services should generally have bounded waiting time.

Without timeouts, slow dependencies can consume:

- threads;
- connections;
- memory;
- worker capacity.

Timeout design should be combined with:

- retry policy;
- backoff;
- circuit breaking where appropriate;
- bounded concurrency.

A timeout protects resources but creates an ambiguous outcome problem for some operations.

## CORS

Cross-Origin Resource Sharing controls how browsers allow scripts from one origin to access resources from another origin.

It is built around the browser's same-origin security model.

Typical CORS policy defines which origins may make browser-mediated cross-origin requests and access responses.

## CORS is not API authentication

CORS should not be used as the primary protection for an API.

A non-browser client can make HTTP requests without being constrained by browser CORS enforcement.

Therefore:

allowed origin ≠ authenticated client

and:

blocked origin ≠ unauthorized attacker blocked from the network.

The API still requires its own authentication and authorization.

## CORS configuration

CORS permissions should normally be as narrow as the application requires.

Important considerations include:

- allowed origins;
- allowed methods;
- allowed headers;
- credentialed requests;
- preflight behavior.

Using broad wildcard configuration without understanding credential behavior can create unnecessary exposure.

## CSRF

Cross-Site Request Forgery exploits a browser's ability to automatically attach credentials to requests.

The classic scenario involves cookie-authenticated web applications.

Conceptually:

1. victim is authenticated to a trusted application;
2. browser holds an authentication cookie;
3. victim visits attacker-controlled content;
4. attacker causes the browser to send a state-changing request;
5. browser automatically attaches the trusted site's credential.

The target may see a valid authenticated request even though the user did not intend the action.

## CSRF depends on the credential model

CSRF risk depends on how authentication credentials are attached to requests.

Cookie-authenticated browser applications require explicit CSRF analysis because browsers can send cookies automatically.

An API where JavaScript explicitly adds a bearer token from application state has a different threat model.

This does not mean such applications are immune to browser attacks.

For example, XSS can expose tokens or cause authenticated requests from the application's own origin.

## CSRF defenses

Depending on the architecture, controls can include:

- framework-provided CSRF protection;
- synchronizer tokens;
- appropriately designed double-submit mechanisms;
- SameSite cookies;
- validation of Origin or related request context;
- custom headers for API-driven browser requests;
- reauthentication for especially sensitive operations.

The correct defense depends on the authentication and client architecture.

## XSS

Cross-Site Scripting allows attacker-controlled content to execute as active content in a web application's browser context.

Possible consequences include:

- account impersonation;
- stealing sensitive information accessible to script;
- modifying page behavior;
- issuing requests as the user;
- bypassing some browser-side defenses.

XSS is primarily a web-client/application problem, but it directly affects API security when the browser has access to authenticated API capabilities.

## Preventing XSS

Defenses depend on output context.

Important principles include:

- context-appropriate output encoding;
- avoiding dangerous DOM sinks;
- HTML sanitization when HTML input must be supported;
- framework security features;
- Content Security Policy as defense in depth.

CSP should not be treated as a substitute for proper output handling.

## CSRF and XSS are different

CSRF abuses the browser's authenticated relationship with another application.

XSS executes attacker-controlled content inside the application's trusted browser context.

They can interact.

A successful XSS vulnerability can often undermine CSRF protections because malicious script may be able to operate with the application's own privileges.

## SSRF

Server-Side Request Forgery occurs when an attacker influences a server into making requests to unintended locations.

Potential targets include:

- internal services;
- cloud metadata endpoints;
- localhost services;
- private network addresses;
- external attacker-controlled systems.

Features that accept URLs deserve careful review.

Examples include:

- webhook targets;
- image importers;
- URL previews;
- callback URLs;
- remote document import.

## SSRF defenses

Depending on the use case, defenses can include:

- allow-listing destinations;
- validating schemes;
- validating resolved addresses;
- preventing access to private/internal networks;
- controlling redirects;
- network egress policy;
- protecting cloud metadata endpoints.

URL syntax validation alone is not enough for strong SSRF protection.

## Third-party APIs are untrusted input

Data from another API should not automatically receive higher trust than ordinary user input.

A downstream service can:

- be compromised;
- return malformed data;
- change behavior;
- respond slowly;
- return huge payloads;
- redirect unexpectedly.

External API integrations need:

- TLS;
- authentication where required;
- validation;
- size limits;
- timeouts;
- redirect policy;
- failure handling.

Trust boundaries exist between services too.

## WAF

A Web Application Firewall can provide another defensive layer.

It may help:

- block known malicious request patterns;
- enforce coarse traffic policies;
- provide virtual protection while an application fix is deployed;
- add visibility into suspicious traffic.

A WAF cannot prove that an application is secure.

It should complement, not replace:

- correct authorization;
- parameterized queries;
- validation;
- secure coding;
- patching.

## Network controls

Internal APIs may also use network-level restrictions such as:

- private networks;
- firewall rules;
- VPN;
- service mesh policy;
- mutual TLS.

These controls reduce exposure.

They should not normally be the only authorization mechanism.

An attacker or compromised workload already inside the trusted network may still attempt unauthorized calls.

## Never trust the network alone

The idea:

> It is internal, therefore it is trusted.

is fragile.

Modern systems should assume that individual services, credentials or machines can be compromised.

Service identity and authorization remain useful even inside private networks.

## Secrets

Secrets include:

- API keys;
- passwords;
- signing keys;
- encryption keys;
- database credentials;
- third-party tokens.

They should not be:

- committed to source control;
- embedded in public client code;
- written unnecessarily to logs;
- returned in error messages.

Use an appropriate secrets-management mechanism and define rotation procedures.

## Logging

Security-relevant events should be observable.

Useful events include:

- failed authentication;
- authorization denial;
- repeated rate-limit violations;
- suspicious administrative operations;
- credential changes;
- token replay indicators;
- unusual access patterns.

But logs themselves can become sensitive data stores.

Avoid logging:

- passwords;
- bearer tokens;
- refresh tokens;
- private keys;
- unnecessary personal data.

## Error handling

Error responses should reveal enough information for legitimate clients to act while avoiding unnecessary disclosure of internals.

Avoid exposing:

- stack traces;
- SQL queries;
- internal paths;
- credentials;
- secrets;
- infrastructure topology.

Detailed diagnostics belong in protected internal observability systems.

## Security headers and browser controls

Browser-facing applications can also benefit from controls such as:

- secure cookie attributes;
- Content Security Policy;
- frame restrictions;
- MIME-sniffing protections;
- referrer policy.

These complement API security but operate primarily at browser/application boundaries.

## Security cannot be outsourced to one component

None of these alone is sufficient:

- HTTPS;
- API gateway;
- WAF;
- OAuth;
- JWT;
- VPN;
- CORS;
- rate limiting.

Each protects against specific classes of threats.

Architecture determines how those controls fit together.

## A practical security review

For every API operation ask:

1. Who can reach it?
2. How is identity established?
3. Which action is being authorized?
4. Which exact object and properties are accessible?
5. Which input is untrusted?
6. Which interpreter sees that input?
7. How much work can the request trigger?
8. Which downstream systems are contacted?
9. Which credentials are exposed?
10. What gets logged?
11. How will abuse be detected?
12. What happens when dependencies fail?

This turns security from a list of products into a design process.

## Common mistakes

### “CORS protects my API from attackers”

Incorrect.

CORS primarily constrains browser behavior.

The API still needs authentication and authorization.

### “Rate limiting prevents DDoS”

Too strong.

Rate limiting is one resource-control mechanism, not a complete distributed denial-of-service defense.

### “HTTPS makes the API secure”

Incorrect.

It protects the transport channel, not application logic.

### “We use an ORM, so SQL injection is impossible”

Incorrect.

Unsafe dynamic or raw queries can still introduce injection.

### “CSRF matters to every API in exactly the same way”

Incorrect.

Risk depends strongly on browser behavior and credential attachment.

### “Bearer tokens mean CSRF is impossible”

Too absolute.

The threat changes, but browser compromise such as XSS can still abuse authenticated capabilities.

### “A WAF fixes vulnerable application code”

No.

A WAF is an additional layer, not a substitute for correcting the vulnerability.

### “Internal APIs do not need authorization”

Dangerous.

Network location alone is not a strong trust boundary.

### “Third-party API responses are trusted data”

Incorrect.

External dependencies are another input boundary.

## Interview answer

I treat API security as defense in depth.

I start with TLS for transport security, then authenticate the caller and authorize the specific action on the specific resource. I validate untrusted input, keep data separate from interpreter syntax, bound resource consumption, protect credentials and make downstream calls with explicit timeouts and validation.

I also distinguish browser controls from API access control. CORS is enforced by browsers and does not replace authentication. CSRF is particularly relevant when browsers automatically attach credentials such as cookies, while XSS can execute inside the trusted browser context and abuse authenticated API capabilities.

Rate limiting is useful for abuse prevention and resource control, but it is not a complete DDoS solution. Likewise a WAF, VPN or API gateway is only one security layer.

The central principle is to identify trust boundaries and failure modes rather than assuming that one security product makes the API safe.

## Exercises for later study

1. Threat-model a public ecommerce checkout API.
2. Explain why changing an invoice ID can reveal broken object-level authorization.
3. Design rate limits for login, product search and report generation separately.
4. Explain why CORS cannot protect an API from a command-line client.
5. Compare CSRF risk for cookie authentication and explicitly attached bearer-token authentication.
6. Explain how XSS can compromise an otherwise correctly authenticated API session.
7. Design defenses for an endpoint that downloads an image from a user-supplied URL.
8. Identify an injection risk even when an ORM is present.
9. Design safe handling of data returned from a third-party shipping API.
10. Explain what a WAF can and cannot fix.
11. Design a logging policy that supports security investigation without recording credentials.
12. Review an internal service and explain why VPN access alone is insufficient authorization.

## Source review notes

The private SOT correctly introduces:

- rate limiting;
- CORS;
- SQL and NoSQL injection;
- firewall and WAF controls;
- VPN;
- CSRF;
- XSS;
- multiple defensive layers.

The public material deliberately refines and extends that model:

- CORS is treated as a browser-enforced cross-origin mechanism rather than API authentication;
- rate limiting is treated as one resource-consumption control rather than complete DDoS protection;
- request frequency and per-request resource limits are separated;
- CSRF is tied to browser credential behavior rather than applied indiscriminately to every API;
- XSS is treated as a browser/application vulnerability that can compromise authenticated API capabilities;
- object-level, property-level and function-level authorization failures are included explicitly;
- injection defenses distinguish validation from safe interpreter usage;
- SSRF is added as an important API threat;
- third-party API responses are treated as untrusted input;
- WAF, firewall, VPN and network controls are treated as defense-in-depth rather than substitutes for application security;
- secrets, logging, error disclosure and downstream timeouts are included;
- security is organized around threat modeling and trust boundaries.
