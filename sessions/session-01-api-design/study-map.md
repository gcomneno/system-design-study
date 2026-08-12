# Study Map – Session 01: API Design

[English](study-map.md) | [Italiano](study-map.it.md)


## Purpose

This map tracks the transformation of the private API Design source material into original, public learning artifacts.

The private source material is used only as study input. Public documents must be independently written, concise, technically reviewed, and suitable for reuse without reproducing the source transcript.

## Source coverage

The current private SOT contains eight distinguishable source lessons:

1. What APIs are
2. API protocols
3. TCP vs UDP
4. REST API design
5. GraphQL
6. Authentication
7. Authorization
8. API security

These source boundaries describe the material we received. They do not dictate the structure of the public course.

## Learning architecture

The public study material is organized into twelve learning units.

| Unit | Topic | Core concepts | Status |
|---|---|---|---|
| 01 | API fundamentals | contracts, abstraction, service boundaries, design principles, lifecycle | Prepared |
| 02 | Protocol selection | interaction patterns, latency, throughput, compatibility, trade-offs | Prepared |
| 03 | HTTP and HTTPS | request/response, methods, headers, TLS, transport security | Prepared |
| 04 | WebSocket, AMQP and gRPC | real-time communication, async messaging, RPC, streaming | Prepared |
| 05 | TCP vs UDP | reliability, ordering, connection semantics, latency trade-offs | Prepared |
| 06 | REST resource design | resources, nouns, collections, identifiers, nested resources | Prepared |
| 07 | HTTP semantics and errors | safe/idempotent methods, status codes, error contracts | Prepared |
| 08 | Querying and API evolution | filtering, sorting, pagination, cursor vs offset, versioning | Prepared |
| 09 | GraphQL | schema, types, queries, mutations, errors, query depth | Prepared |
| 10 | Authentication | Basic, Bearer, OAuth 2, JWT, access/refresh tokens, SSO | Prepared |
| 11 | Authorization | RBAC, ABAC, ACL, claims, scopes, policy enforcement | Prepared |
| 12 | API security | rate limiting, CORS, injection, WAF, VPN, CSRF, XSS | Prepared |

## Artifact model

Each learning unit should eventually provide, when useful:

- concise study notes;
- lessons learned;
- engineering trade-offs;
- failure modes and common mistakes;
- practical examples;
- interview questions and model answers;
- exercises;
- an auto-test quiz;
- a separate answer and correction file.

Not every unit needs a separate file for every artifact. Closely related material may be combined when that makes the study path clearer.

## Existing material

Prepared material now includes:

- introductory API Design lessons learned;
- twelve-unit learning track;
- complete bilingual interview bank covering Units 01–12;
- exercises embedded in the learning units;
- Quiz 01 with reviewed answers — API fundamentals and paradigm selection;
- Quiz 02 with answer key — HTTP API Design;
- Quiz 03 with answer key — Protocols, Transport & REST Design;
- Quiz 04 with answer key — GraphQL, Identity & API Security.

Together these artifacts cover the complete Session 01 study track.

## Technical review policy

The private SOT is an input, not an authority.

Before a source claim becomes canonical public material, check whether it is:

- technically accurate;
- current enough for the topic;
- expressed at the right level of precision;
- missing an important trade-off or exception;
- simplified in a way that could create a wrong mental model.

Source wording should not be copied into public artifacts.

## Completion criteria

Session 01 is considered prepared when:

- all twelve learning units are covered by original study material;
- important source claims have been technically reviewed;
- interview material covers the complete track;
- exercises exist for the major design decisions;
- quizzes and answer keys cover the complete track;
- repository hygiene and bilingual validation pass;
- no private SOT material is tracked by Git.

## Status

**Prepared.**

All Session 01 preparation criteria are satisfied.

The next phase is active study: work through the prepared units, exercises, interview material and quizzes. Additional supporting material should be created only when concrete gaps or questions emerge during study.
