# Contributing

This repository is a personal study lab for System Design.

Contributions are welcome only if they improve the educational material without adding copyrighted raw content or heavy binary files.

## Repository rules

Do not add:

- video files;
- downloaded media;
- large binary files;
- raw course dumps;
- generated temporary files;
- credentials or private notes.

Prefer adding:

- original summaries;
- lessons learned;
- quizzes;
- interview questions;
- corrected explanations;
- diagrams written as text or Mermaid only when useful;
- small scripts that improve repository hygiene.

## Commit messages

Use concise commit messages.

Preferred prefixes:

- `news:` for new visible study material;
- `fix:` for corrections;
- `chore:` for maintenance;
- `refactor:` for structure-only changes;
- `docs:` only for generic documentation changes.

Examples:

- `news: add api design quiz`
- `fix: clarify grpc use cases`
- `chore: add repository hygiene checks`

## Before committing

Run:

./scripts/check-no-videos.sh

Then inspect:

git status -sb

## Style

Keep explanations practical, concise and interview-oriented.

Avoid motivational filler.

Prefer examples, trade-offs and concrete engineering reasoning.
