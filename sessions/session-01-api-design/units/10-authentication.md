# Unit 10 – Authentication

[English](10-authentication.md) | [Italiano](10-authentication.it.md)

## Learning objective

Understand how a system establishes identity and distinguish authentication mechanisms from authorization protocols, token formats and permission decisions.

The fundamental question is:

> Who or what is making this request, and how much confidence do we have in that identity?

Authentication comes before authorization conceptually, but the mechanisms used by real systems often span several protocol layers.

## Authentication versus authorization

Authentication establishes identity.

Authorization decides what that identity is allowed to do.

Examples:

- Authentication: this request belongs to user 42.
- Authorization: user 42 may read this invoice but may not delete it.

Confusing these concepts produces weak security models and misleading API contracts.

## Credentials are evidence

Authentication relies on evidence presented or established by a principal.

Examples include:

- password;
- session identifier;
- API credential;
- bearer token;
- client certificate;
- cryptographic proof;
- identity-provider assertion.

A credential is valuable because the system associates possession or proof of it with an identity.

Protecting credentials is therefore part of authentication design.

## Basic authentication

HTTP Basic authentication transmits a username/password-style credential encoded for use in an HTTP header.

Base64 is encoding, not encryption.

Therefore Basic authentication must not be considered safe merely because the credential looks unreadable.

When Basic authentication is used, transport security is essential.

Even over HTTPS, repeatedly exposing a long-lived password credential to application traffic can make Basic authentication less desirable than limited-scope tokens.

## Session-based authentication

A traditional web application may authenticate a user once and then maintain a server-side session.

Conceptual flow:

1. user proves identity;
2. server creates session state;
3. browser receives an opaque session identifier;
4. later requests carry that identifier;
5. server resolves it to authenticated session state.

Advantages include:

- straightforward revocation;
- sensitive state can remain server-side;
- mature browser integration.

Trade-offs include:

- shared/distributed session storage when scaling;
- cookie security requirements;
- CSRF considerations when cookies authenticate requests.

Session authentication is not obsolete merely because token-based APIs exist.

## Bearer tokens

A bearer token works according to possession.

The resource server accepts the token as authorization evidence according to its validation rules.

This property is operationally convenient but security-sensitive:

> Anyone who obtains a usable bearer token may be able to exercise its authority.

Bearer tokens therefore need protection:

- in transit;
- at rest;
- in logs;
- in browser or device storage;
- against accidental disclosure.

Bearer is a token usage model, not a guarantee about the token's internal format.

## Access tokens

An access token represents authority granted to a client for access to protected resources.

It may encode or reference properties such as:

- allowed scope;
- audience;
- expiration;
- subject;
- authorization context.

An access token does not have to be a JWT.

It can be:

- opaque;
- structured;
- self-contained;
- reference-based.

The resource server must validate it according to the protocol and deployment contract.

## JWT

JWT stands for JSON Web Token.

It is a compact format for transporting claims.

Typical claims can include:

- issuer;
- subject;
- audience;
- expiration time;
- issued-at time;
- application-specific claims.

JWT describes a token format.

It does not mean:

- OAuth;
- authentication;
- authorization;
- encryption;
- security by itself.

A JWT must be interpreted within a protocol and validation context.

## Signed does not mean encrypted

A signed JWT protects integrity and authenticity according to the signing mechanism.

Its payload is not automatically confidential.

Anyone able to obtain a normally encoded signed JWT may be able to inspect its claims.

Sensitive information should therefore not be placed in a token merely because the token is signed.

Encryption is a separate cryptographic property.

## JWT validation

Accepting a JWT should involve validating the properties required by the application contract.

Typical checks include:

- accepted signing algorithm;
- signature;
- issuer;
- audience;
- expiration;
- not-before constraints where used;
- token purpose;
- expected key and trust relationship.

Parsing a JWT successfully is not authentication.

Authentication results from successful validation under a trusted protocol.

## OAuth 2.0

OAuth 2.0 is an authorization framework.

Its core purpose is to allow a client to obtain limited access to protected resources.

Typical roles include:

- resource owner;
- client;
- authorization server;
- resource server.

OAuth separates the user's credential from the delegated authority given to the client.

A third-party application therefore does not need to receive the user's password in order to obtain limited access.

## OAuth is not login by itself

A common mistake is to say:

> OAuth authenticates the user with Google or GitHub.

OAuth 2.0 by itself standardizes delegated authorization.

It does not define a standard identity result for the end user.

If an application needs interoperable user authentication on top of OAuth 2.0, OpenID Connect provides the identity layer.

This distinction is important because an access token is intended for a resource server, not as arbitrary proof of identity to a client application.

## OpenID Connect

OpenID Connect adds an authentication layer on top of OAuth 2.0.

It allows a relying party to verify the identity of the authenticated end user.

A central artifact is the ID Token.

The ID Token communicates claims about the authentication event and subject to the relying party.

Therefore:

- OAuth access token → authority to access a resource;
- OpenID Connect ID Token → identity/authentication information for the client.

Their purposes are different even when both happen to use JWT representations.

## Access token versus ID Token

Do not treat these as interchangeable.

### Access token

Audience:

- resource server.

Purpose:

- authorize access to protected resources.

### ID Token

Audience:

- OpenID Connect client / relying party.

Purpose:

- communicate authenticated identity information.

Using an access token as if it were an ID Token can create security and interoperability problems.

## Access and refresh tokens

Access tokens are commonly short-lived.

Short lifetimes reduce the useful lifetime of a leaked token.

A refresh token can allow the client to obtain new access tokens without repeating the full user authorization interaction.

Refresh tokens are therefore especially sensitive credentials.

Compromise of a long-lived refresh token can give an attacker repeated access-token renewal capability.

## Refresh-token security

Refresh-token design depends on client type and threat model.

Important controls can include:

- secure storage;
- client binding;
- sender-constrained tokens;
- refresh-token rotation;
- expiration after inactivity;
- revocation after security events;
- replay detection.

There is no universal rule that every refresh token must physically live on an application server.

Different client architectures have different capabilities.

The security property matters more than a memorized storage slogan.

## Refresh-token rotation

With rotation:

1. client presents refresh token A;
2. authorization server issues a new access token and refresh token B;
3. A becomes invalid;
4. later reuse of A can signal token replay.

The authorization server can then invalidate the associated token family or grant.

Rotation therefore provides a mechanism to detect certain refresh-token theft scenarios.

## Token lifetime trade-offs

Very long-lived access tokens:

- reduce refresh traffic;
- increase damage if stolen.

Very short-lived access tokens:

- reduce exposure time;
- increase renewal activity;
- depend more heavily on refresh mechanisms.

There is no universally correct lifetime.

It depends on:

- application sensitivity;
- client type;
- revocation requirements;
- user experience;
- threat model.

## Stateless does not mean no security state

JWT-based authentication is often described as stateless because a resource server may validate a self-contained token without looking up a session on every request.

But the overall system may still require state for:

- signing keys;
- revoked credentials;
- refresh-token families;
- user disablement;
- consent;
- authorization grants;
- key rotation;
- security events.

“JWT makes authentication stateless” is therefore an architectural simplification, not a universal property of the entire identity system.

## Revocation trade-off

Server-side sessions make immediate revocation straightforward:

- invalidate session record;
- future requests fail.

A long-lived self-contained access token is harder to revoke immediately if resource servers validate it without consulting central state.

Common responses include:

- short token lifetimes;
- revocation lists;
- introspection;
- key rotation in exceptional cases;
- security-event propagation.

Stateless verification and immediate revocation pull architecture in different directions.

## Single Sign-On

Single Sign-On allows one authentication relationship to support access to multiple applications.

SSO is an experience and architecture pattern, not one protocol.

Technologies used in SSO ecosystems include:

- OpenID Connect;
- SAML;
- organization-specific identity systems.

OAuth 2.0 can participate in modern identity architectures, but OAuth itself should not be used as a synonym for SSO.

## Service authentication

Authentication is not limited to humans.

Services also need identities.

Possible mechanisms include:

- client credentials;
- workload identity;
- mutual TLS;
- signed assertions;
- cloud-native identity tokens.

A service identity should receive only the authority required for its role.

Human identity and workload identity often need different lifecycle and security policies.

## Authentication failure

A protected HTTP API commonly returns `401 Unauthorized` when authentication has not been successfully established.

Examples:

- missing credential;
- invalid bearer token;
- expired credential requiring reauthentication.

Authorization denial after successful authentication is normally a different concern and often maps to `403 Forbidden`.

## Common mistakes

### “OAuth is login”

Incorrect.

OAuth 2.0 is primarily delegated authorization.

Use an identity protocol such as OpenID Connect when standardized end-user authentication is required.

### “JWT means authentication”

Incorrect.

JWT is a token format.

### “JWT is encrypted”

Not necessarily.

A signed JWT can be integrity-protected while its claims remain readable.

### “Bearer tokens are safe because the server verifies them”

Incomplete.

Anyone who steals a valid bearer token may be able to use it.

### “A JWT access token is always better than an opaque token”

No.

Opaque and self-contained tokens have different operational and security trade-offs.

### “JWT eliminates server state”

Too simplistic.

The broader authentication system frequently maintains substantial security state.

### “Refresh tokens always belong only on the server”

Too absolute.

Storage and protection depend on client type and architecture.

### “Access token and ID Token are interchangeable”

Dangerous.

They have different intended audiences and purposes.

## Interview answer

Authentication establishes who or what is making a request; authorization decides what that identity may do.

I distinguish session authentication, bearer-token usage, token formats and identity protocols rather than treating them as synonyms.

OAuth 2.0 is an authorization framework, while OpenID Connect adds standardized end-user authentication. An OAuth access token is intended to authorize access to a resource server, whereas an OpenID Connect ID Token communicates authenticated identity to the relying party.

JWT is only a token format. A JWT can carry claims and can be signed or encrypted according to its construction, but simply parsing a JWT does not authenticate anyone. The consumer must validate signature, issuer, audience, lifetime and token purpose.

For token-based systems I also design expiration, refresh, rotation, revocation and secure storage explicitly. Short-lived access tokens reduce exposure, while refresh tokens require stronger protection because they can extend access over time.

## Exercises for later study

1. Explain the difference between OAuth 2.0 and OpenID Connect.
2. Explain why an access token should not automatically be used as proof of login.
3. Compare a server-side session with a self-contained access token.
4. Explain why a signed JWT can still expose confidential claims.
5. Design the validation steps for a JWT received by an API.
6. Describe what happens if a bearer token appears in application logs.
7. Design access-token and refresh-token lifetimes for a banking app and justify the trade-offs.
8. Explain refresh-token rotation and replay detection.
9. Compare immediate revocation in a session system with revocation of self-contained tokens.
10. Design authentication separately for human users and internal services.

## Source review notes

The private SOT correctly introduces:

- authentication as establishing identity;
- Basic authentication;
- bearer tokens;
- OAuth 2.0;
- JWT;
- access and refresh tokens;
- Single Sign-On;
- distinction between authentication and later authorization.

The public material deliberately refines that model:

- OAuth 2.0 is treated as an authorization framework rather than a login protocol;
- OpenID Connect is introduced as the standard authentication layer built on OAuth 2.0;
- access tokens and ID Tokens are separated by purpose and audience;
- bearer-token security is explained through possession semantics;
- JWT is treated as a token format rather than a synonym for authentication or OAuth;
- signed and encrypted tokens are distinguished;
- JWT validation requirements are made explicit;
- refresh-token security is based on client type and threat model rather than a universal server-storage rule;
- refresh-token rotation and replay detection are included;
- stateless token validation is separated from state in the overall identity system;
- service/workload authentication is included alongside human authentication.
