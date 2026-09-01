# Supplements

Extra questions for one *kind* of tool, merged into a copy of the interview when
you ask for them.

```bash
bin/launch supplements                            # what exists, and when each applies
bin/launch new <name> --with measurement          # core + that supplement
bin/launch new <name> --with measurement,other    # more than one
```

## Why these are not in the core

[`../interview.md`](../interview.md) is agnostic and stays that way. It asks
what every new repository has to settle regardless of what it is, and a question
most launches would skip does not belong in it — a form that asks eleven
irrelevant questions gets skimmed, and a skimmed form is answered perfunctorily,
which is the failure the whole arrangement exists to prevent.

The counterpart downstairs is the **calculus profile**: high-level facts about
the calculus that decide what a generated checker needs, what it has to prove
and what it can inherit, set per run and recorded in the generated project. Same
idea one level up — facts about the *kind* of tool that decide which questions
it owes an answer to.

## What a supplement is

One Markdown file here. It holds `### <id> — <question>` headings and answer
markers exactly as the core does, with two rules:

- **The id is prefixed, not numbered from one.** The measurement supplement uses
  `M1`, `M2`; its markers are `<!-- AM1 required -->` and `<!-- /AM1 -->`. Core
  questions are `A1`…`An` and display as `Q1`…`Qn`. A supplement that reuses a
  core id would silently overwrite it.
- **The merge happens at `new`, not at `prompt`.** The supplement's text is
  copied into the answer file, so that file remains the whole record of what was
  asked. Nothing has to be re-resolved later to read it.

## When to write one

When the same questions have been written into the free-text answers of two
launches. Not before — a supplement written for a kind of tool nobody has built
is a guess about somebody else's needs, and it is more expensive to withdraw
than it was to write.

Adding one is a file here and a line in the catalogue in
[`../bin/launch`](../bin/launch).

## What exists

| supplement | for | questions |
| --- | --- | --- |
| [`measurement.md`](measurement.md) | any tool whose output is numbers — benchmarks, timings, counts, sizes, coverage | 7, five of them required |
