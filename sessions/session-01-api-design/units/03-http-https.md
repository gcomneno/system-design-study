# Unit 03 – HTTP and HTTPS

[English](03-http-https.md) | [Italiano](03-http-https.it.md)

## Learning objective

Understand HTTP as an application-level protocol and HTTPS as HTTP communication protected by a secure transport channel.

The goal is to separate three concerns that are often mixed together:

- HTTP semantics;
- the transport used to carry HTTP;
- application authentication and authorization.

## HTTP as an application protocol

HTTP defines a request/response interaction model between clients and servers.

A request communicates an intention toward a resource. A response communicates the outcome.

Important parts of HTTP communication include:

- request method;
- target URI;
- header fields;
- optional content;
- response status code;
- response fields;
- optional response content.

HTTP semantics are not defined by the internal implementation of the server.

A client interacts with a public interface while the server remains free to change databases, frameworks, internal services or storage strategies without changing that contract.

## Resources and methods

HTTP separates the identity of a resource from the action requested on that resource.

For example, the URI may identify a product while the HTTP method communicates the operation to perform.

Common methods include:

- GET;
- POST;
- PUT;
- PATCH;
- DELETE.

The detailed semantics of safe and idempotent methods are covered in Unit 07.

## Headers

HTTP fields carry metadata and control information.

Common examples include:

- `Content-Type`;
- `Accept`;
- `Authorization`;
- `Cache-Control`;
- conditional request fields;
- tracing or correlation metadata.

Headers are part of the protocol contract and should not be treated as an arbitrary dumping ground for application data.

## Status codes

Responses contain status codes that describe the outcome of the request.

The main classes are:

- 1xx — informational;
- 2xx — successful;
- 3xx — redirection;
- 4xx — client-side request or authorization conditions;
- 5xx — server-side failures.

Specific status codes and API error design are covered in Unit 07.

## HTTP is stateless at the protocol level

HTTP is a stateless request/response protocol.

This does not mean that applications cannot maintain state.

Applications routinely maintain:

- database state;
- authenticated sessions;
- shopping carts;
- workflow state;
- caches.

The important distinction is that HTTP itself does not require a server to remember previous requests in order to interpret the semantics of the next request.

Application state and protocol state are different concepts.

## HTTPS

HTTPS uses HTTP semantics over a secured connection.

TLS provides the secure channel.

Its main security properties include:

- confidentiality;
- integrity;
- peer authentication.

In the ordinary web model, the server is authenticated to the client. TLS can also authenticate the client, but client authentication is optional.

## HTTPS does not authenticate the application user

This distinction is essential.

A valid HTTPS connection proves that the client has established a protected channel with the authenticated server endpoint.

It does not automatically prove that the application knows which human user is making the request.

Application-level identity can still require mechanisms such as:

- sessions;
- bearer tokens;
- OAuth;
- client credentials;
- other authentication schemes.

These are covered later in the authentication unit.

## What TLS protects

TLS is designed to protect data while it travels between communicating peers.

It helps prevent:

- passive eavesdropping;
- undetected modification of protected traffic;
- message forgery within the protected channel.

TLS does not by itself protect data after it has reached an endpoint.

If an attacker compromises the application server, database or client device, HTTPS is not a substitute for endpoint security.

## HTTP versions and transport

Do not equate HTTP with TCP.

The HTTP semantics remain broadly shared across modern HTTP versions, but their transport mechanisms differ.

A useful high-level model is:

| Version | Typical transport model |
|---|---|
| HTTP/1.1 | TCP, optionally protected by TLS for HTTPS |
| HTTP/2 | commonly TLS over TCP |
| HTTP/3 | QUIC, which runs over UDP and integrates TLS security |

HTTP/3 demonstrates why application protocol and transport protocol should be reasoned about separately.

## Why HTTP/3 matters to the mental model

Older introductory explanations often present a fixed stack:

HTTP → TCP → IP

That remains useful for understanding HTTP/1.1 and HTTP/2 deployments, but it is not universal.

HTTP/3 maps HTTP semantics onto QUIC.

QUIC provides features such as:

- multiplexed streams;
- transport-level reliability per stream;
- flow control;
- low-latency connection establishment;
- integrated cryptographic handshake.

Therefore “UDP is unreliable, so anything over UDP is unreliable” is also an incomplete model.

A higher-level transport such as QUIC can implement reliability and ordering semantics while itself using UDP datagrams underneath.

## Design consequences

### Use HTTPS by default

For production APIs communicating across untrusted networks, plaintext HTTP should normally not carry credentials, tokens, personal data or other sensitive information.

### Do not confuse transport security with authorization

HTTPS protects the channel.

Authorization determines whether the authenticated identity is allowed to perform an operation.

Those are independent security layers.

### Treat HTTP semantics as a contract

Methods, status codes, headers, caching and representation semantics are not decoration.

Clients and intermediaries rely on them.

Misusing them makes APIs harder to retry, cache, debug, monitor and evolve.

## Common mistakes

### “HTTPS means the user is authenticated”

Incorrect.

TLS normally authenticates the server endpoint. Application-user authentication is a separate concern.

### “HTTP always runs on TCP”

Incomplete.

HTTP/3 runs over QUIC, which uses UDP.

### “UDP means unreliable applications”

Too simplistic.

UDP itself does not provide TCP-style reliability, but protocols built above UDP can implement their own reliable delivery semantics.

### “Stateless HTTP means the server cannot store state”

Incorrect.

Statelessness of HTTP does not prohibit application or persistent state.

### “200 means every successful API operation”

Too coarse.

HTTP defines multiple successful status codes with different semantics.

## Interview answer

HTTP is an application-level request/response protocol that defines semantics around resources, methods, fields and response status codes.

HTTPS is not a separate API design style: it is HTTP communication protected by a secure transport channel using TLS.

TLS provides confidentiality, integrity and peer authentication, but it does not replace application authentication or authorization.

I also separate HTTP semantics from the underlying transport. HTTP/1.1 and HTTP/2 commonly use TCP, while HTTP/3 maps the same HTTP semantics onto QUIC over UDP. That distinction matters when reasoning about latency, multiplexing, reliability and deployment constraints.

## Exercises for later study

1. Explain the difference between HTTP statelessness and application state.
2. Explain why HTTPS does not eliminate the need for bearer-token authentication.
3. A service uses HTTPS but logs every access token in plaintext. Identify which security problem HTTPS does and does not solve.
4. Compare the mental model of HTTP/2 over TCP with HTTP/3 over QUIC.
5. Explain why saying “UDP is unreliable, therefore HTTP/3 is unreliable” is incorrect.

## Source review notes

The private SOT correctly introduces HTTP as the foundation of many APIs and HTTPS as encrypted communication.

During technical review, several points were refined:

- HTTP semantics are separated from the underlying transport.
- HTTPS is not described as application-user authentication.
- TLS security is described in terms of confidentiality, integrity and peer authentication.
- HTTP/3 and QUIC are included to avoid the outdated assumption that HTTP necessarily runs over TCP.
