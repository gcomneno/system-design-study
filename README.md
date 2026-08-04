# System Design Study

[English](README.md) | [Italiano](README.it.md)

A public learning repository for studying System Design through original notes,
summaries, quizzes, interview answers, exercises, and small supporting tools.

Raw transcripts and privately sourced material may be used locally as input, but
the public repository contains only reviewed and reworked learning artifacts.

## Goal

Turn raw notes and study inputs into reusable material:

1. reorganized source notes;
2. concise synthesis;
3. key concepts;
4. architectural trade-offs;
5. quizzes;
6. interview questions;
7. reasoned answers and corrections.

## Study method

The workflow is text-first.

Each topic should produce practical and reviewable artifacts rather than a copy
of the original source material. Public content should emphasize engineering
reasoning, concrete examples, failure modes, and interview-ready explanations.

## Repository structure

```text
system-design-study/
├── .github/
│   ├── bilingual-docs.json
│   └── workflows/
│       └── bilingual-docs.yml
├── archive/
├── docs/
├── scripts/
│   ├── check-bilingual-docs.py
│   ├── check-no-videos.sh
│   └── check-public-content.sh
├── sessions/
├── tests/
│   └── test_bilingual_docs.py
├── CONTRIBUTING.md
├── CONTRIBUTING.it.md
├── README.md
└── README.it.md
```

- `archive/`: notes about private or local source material.
- `sessions/`: processed learning material organized by study session.
- `docs/`: repository policies and maintenance conventions.
- `scripts/`: validation and repository hygiene tools.

## Documentation languages

English is the canonical documentation language.

Italian counterparts use the `.it.md` suffix. Bilingual pairs and the measurable
legacy backlog are registered in `.github/bilingual-docs.json`.

Contributions must follow [CONTRIBUTING.md](CONTRIBUTING.md).

## Current study track

The current track is API Design.

Available material covers:

- APIs as contracts, abstractions, and service boundaries;
- REST, GraphQL, and gRPC;
- consistency, simplicity, security, and performance;
- quizzes and reasoned corrections;
- interview questions and answers.

See [Study Sessions](sessions/README.md).

## Publication and copyright policy

Video files are deliberately excluded.

Do not publish complete transcripts, complete translations, downloaded course
material, private notes, or source-derived corpora without explicit permission
or a compatible license.

The preferred public artifacts are original summaries, lessons learned, quizzes,
exercises, diagrams, and interview answers.

## Local validation

Run the repository hygiene and bilingual documentation checks before publishing
changes:

```bash
./scripts/check-no-videos.sh
./scripts/check-public-content.sh
python3 -m unittest discover -s tests -p "test_bilingual_docs.py" -v
python3 scripts/check-bilingual-docs.py
```

The bilingual foundation is tracked by
[issue #1](https://github.com/gcomneno/system-design-study/issues/1).
