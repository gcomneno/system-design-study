# Contributing

[English](CONTRIBUTING.md) | [Italiano](CONTRIBUTING.it.md)

This repository is a personal System Design study laboratory.

Contributions are welcome when they improve the educational material without
adding copyrighted raw content, private material, or heavy binary files.

## Language policy

English is the canonical documentation language.

Italian counterparts use the `.it.md` suffix. Commands, paths, APIs, filenames,
identifiers, technical symbols, inline code, links, and code blocks must remain
structurally equivalent across a bilingual pair.

Every bilingual document must expose reciprocal language navigation near the
top.

## Documentation classification

Every tracked public Markdown document must be classified in
`.github/bilingual-docs.json` as one of:

- a canonical document with an inferred Italian counterpart;
- a `legacy_unpaired_documents` backlog item;
- a motivated `excluded_documents` entry.

No public Markdown document may remain unclassified.

## Repository rules

Do not add:

- video or downloaded media files;
- large binary files;
- raw course dumps;
- complete transcripts or translations without a compatible license;
- generated temporary files;
- credentials, tokens, or private notes.

Prefer adding:

- original summaries;
- lessons learned;
- quizzes and exercises;
- interview questions and answers;
- corrected technical explanations;
- text or Mermaid diagrams when useful;
- small repository hygiene tools.

## Working method

1. create or reference a focused GitHub issue;
2. work on a dedicated branch and isolated worktree;
3. preserve the canonical English meaning;
4. update both members of every affected bilingual pair;
5. keep headings, navigation, code, and technical identifiers aligned;
6. run all repository checks before publishing a pull request.

## Commit messages

Use concise commit messages.

Preferred prefixes:

- `news:` for new visible study material;
- `fix:` for corrections;
- `chore:` for maintenance;
- `refactor:` for structure-only changes;
- `docs:` for general documentation changes.

## Style

Keep explanations practical, concise, and interview-oriented.

Avoid motivational filler. Prefer examples, trade-offs, failure scenarios, and
concrete engineering reasoning.

## Local validation

Run:

```bash
./scripts/check-no-videos.sh
./scripts/check-public-content.sh
python3 -m unittest discover -s tests -p "test_bilingual_docs.py" -v
python3 scripts/check-bilingual-docs.py
```

All commands must succeed before publishing a pull request.

## Pull requests

A pull request should:

- reference its GitHub issue;
- explain scope and architectural decisions;
- list migrated, legacy, and excluded documents;
- report local validation results;
- avoid unrelated study-content changes;
- remain unmerged until explicitly approved.
