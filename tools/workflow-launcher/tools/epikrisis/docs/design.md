# The pipeline, and the boundary in the middle of it

**Goal 1.** How a history becomes evidence, where the program stops and
judgement starts, and what each stage is obliged to produce.

Nothing here has been built. This is the design, and the reason it exists before
the code is that the boundary below is the only thing that makes the output worth
reading — a tool of this kind that mixes computation and judgement in one file
produces a document nobody can check, quickly, and at scale.

## The shape

Six stages. The first four are programs, the fifth is writing, the sixth is a
program again — and the sixth is the one that makes the fifth accountable.

| # | stage | what it does | kind |
| --- | --- | --- | --- |
| 1 | **pin** | stage the subject's trees at named commits; write the manifest | deterministic |
| 2 | **events** | run the detectors; emit candidate events with evidence | deterministic |
| 3 | **record** | extract what the subject *says* about its own history | extraction |
| 4 | **delta** | join 2 against 3; classify the disagreements | deterministic |
| 5 | **report** | the narrative and the assessment, written from 2–4 | **judgement** |
| 6 | **check** | verify the report against the evidence, mechanically | deterministic |

**The boundary is between 4 and 5, and it is a boundary between files, not
between paragraphs.** Stages 1–4 write machine-readable artifacts that are
re-derivable from a pin; stage 5 writes prose that is not; nothing is ever
written that contains both. A reader who distrusts the report can rerun stages
1–4 and get the same evidence, byte for byte, and then disagree with the writing
having established that the writing is the only thing in dispute.

## What each stage produces

Schemas are given as the record shapes rather than as a specification. Two things
about them are load-bearing and are called out where they occur.

### 1. `corpus.json` — the pin

```json
{
  "subject": "cvc5",
  "kind": "tool",
  "pinned": "2026-09-01",
  "tool_version": "<epikrisis revision>",
  "sources": [
    { "id": "cvc5", "origin": "<url>", "commit": "<sha>",
      "first_commit": "<date>", "last_commit": "<date>", "commits": 0 }
  ],
  "thresholds": { "...": 0 },
  "questions_digest": "<sha256 of questions.md>",
  "thresholds_changed_after_events": false
}
```

Two fields exist to catch this tool cheating on itself:

- **`questions_digest`** pins the pre-registered questions to the run. Questions
  added after the evidence was seen change the digest, so the report carries
  visible proof of when its questions were written.
- **`thresholds_changed_after_events`** is set the moment a detector parameter is
  edited after that subject's events have been computed once. A threshold tuned
  until the output looks right has been fitted to the answer, and the resulting
  report says so in its header for as long as the flag is set. It is never
  cleared by editing; it is cleared by starting a run over.

### 2. `events.jsonl` — candidates, one per line

```json
{ "id": "E0044", "detector": "rewrite", "detector_version": 1,
  "at": { "commit": "<sha>", "date": "<date>" },
  "span": { "from": "<sha>", "to": "<sha>" },
  "paths": ["<path prefix>"],
  "measure": { "churn": 0.0, "lines_before": 0, "lines_after": 0 },
  "evidence": ["<sha>"],
  "selected": null, "reason": null }
```

**There is no author field, and that is the point.** Names are read in stage 1
and do not enter stage 2's output; what may travel is a count or a stable
anonymous id. The rule that the unit of analysis is the artifact is therefore
enforced by what the schema can express rather than by anybody remembering it —
a report cannot name a person, because nothing downstream of stage 2 knows one.

**`selected` is null when a detector writes the record.** Detectors are built for
recall, not precision: the decision that a candidate is a *major* event is
judgement and belongs to stage 5.

### 3. `claims.jsonl` — the declared record

What the subject says happened, extracted verbatim with its source location.

```json
{ "id": "C0007",
  "source": { "path": "<path>", "line": 0, "commit": "<sha>" },
  "kind": "release-note | dated-topic | checkbox | register-entry | retirement",
  "asserted": "<date>", "text": "<verbatim>", "about": ["<path or source id>"] }
```

This stage is **extraction, not computation**, and the distinction is honest
rather than pedantic: which sentences in a tree are claims about its own history
is a judgement with a program's face on it. The mitigation is that `text` is
verbatim and `source` is exact, so every claim can be read in place by somebody
who thinks the extractor chose wrong.

The two subjects exercise it very differently. A conventional project's declared
record is release notes. This family's is unusually dense — dated correspondence
with allocated ids, proposals carrying decisions, a register saying which names
were taken and when, roadmap items that flip to `[x]`, retirement notes — and
most of it is already structured enough to extract without heuristics.

### 4. `delta.json` — where the record and the tree disagree

```json
{ "matched":      [ { "event": "E0012", "claim": "C0007", "lag_days": 3 } ],
  "declared_only": ["C0031"],
  "derived_only":  ["E0044"],
  "disagreeing":   [ { "event": "E0009", "claim": "C0002", "lag_days": 214 } ] }
```

Three classes, and they are the analysis rather than an input to it:

- **declared, not derived** — the record says something happened and the tree
  does not show it. Sometimes a claim about intent recorded as fact; sometimes
  work that happened somewhere the corpus cannot see.
- **derived, not declared** — something large happened and no document mentions
  it. Usually the most interesting class, and the one a person reading the log
  would take longest to find.
- **disagreeing on when** — both records have it and the dates are far apart.
  The lag itself is the finding.

### 5. `report.md` and `assessments.jsonl` — the judgement

The narrative cites event and claim ids inline. Beside it, one record per
assessment:

```json
{ "id": "A3", "direction": "well | badly",
  "claim": "<one sentence>", "rests_on": ["E0012", "C0007"],
  "falsified_by": "<what would show this is wrong>",
  "confidence": "low | medium | high", "scope": "<what it does not cover>" }
```

The obligations on this file, and the reasons they are obligations rather than
advice, are [judgement.md](judgement.md).

### 6. `check` — what a program can still say about prose

Stage 6 is why the schemas above are shaped as they are. It verifies, without
reading for sense:

- every id cited in the narrative exists in `events.jsonl` or `claims.jsonl`;
- every assessment cites at least one id, and every id it cites exists;
- every assessment has a non-empty `falsified_by`;
- **both directions are present** — a report with no `badly` is a failed run;
- every candidate event is either cited or has a `reason` for being dropped;
- the manifest's flags — fitted thresholds, late questions, self-assessment —
  are reproduced in the report header.

None of that checks whether an assessment is *right*, which no program can do.
It checks that the report is answerable to its evidence, which is the property
that fails first and silently when this kind of document is written quickly.

## What is kept, and what is not

**Committed:** the manifest, the events, the claims, the delta, the selection
record, the questions and the report. All of it is small, and it is what any
later reader needs to argue with a conclusion.

**Not committed:** the staged trees. They are large and re-fetchable from the
pins, and a tool that vendors somebody's repository to prove it read it has
misunderstood what the pin is for. They live in `work/`, which is ignored.

This is the split the sibling one level up already uses — snapshots in git, the
checkout they were taken from not — and it is worth copying for the same reason:
what a run *derived* is the evidence; what it *read* is reproducible.

## The command surface

```
epikrisis subjects              # what is defined, and what each reads
epikrisis pin      <subject>    # stage the trees; write corpus.json
epikrisis events   <subject>    # run the detectors
epikrisis record   <subject>    # extract the declared record
epikrisis delta    <subject>    # join; classify
epikrisis prompt   <subject>    # the assembled evidence and questions; sends nothing
epikrisis run      <subject>    # hand that prompt to an agent
epikrisis check    <run>        # stage 6, over what came back
epikrisis detectors             # the catalogue, each with its failure mode
```

**There is no `report` command, and the omission is the design.** The host one
level up splits `prompt` from `run` for a stated reason — see exactly what would
be sent, decide, then send — and refuses to let a generator be the thing that
also publishes. The same split is right here for a sharper reason: the evidence
is computable and the judgement is not, and a single command that emitted a
finished report would let a reader believe the second was as reproducible as the
first.

`run` is the only command that spends anything, and like its counterpart it
should refuse more than it accepts: no pin, a stale pin, events not computed,
questions whose digest does not match the manifest, a subject marked `self`
without the stricter checks enabled.

## Where the two subject kinds diverge

A **tool** is one source and one log. An **ecosystem** is several sources plus a
statement of the relations between them — who pins whom, who reports to whom,
who keeps a shared document — and its history contains events that appear in no
repository's log at all: a repository entering the set, a name being taken, a
role moving, a child project retired.

Three things follow, and all three are places this design expects to be wrong
first:

1. **One timeline out of many logs.** Cross-repository ordering needs a single
   clock, and commit dates are the only one available. They are also
   unreliable — see the hazards.
2. **Relations are declared, not derived.** Who pins whom is *sometimes*
   readable from a CI file, and mostly it is written in prose. So ecosystem
   relations enter as configuration and are treated as claims, not as facts.
3. **The set itself has a history.** Membership is not constant over the window
   being analysed, and a naive run treats today's members as always having been
   there, which silently backdates the ecosystem's own beginning.

## Hazards this pipeline cannot fix

Written down because every one of them produces a *plausible* wrong answer
rather than an error, which is the kind that survives review.

| hazard | effect | what is done about it |
| --- | --- | --- |
| rebases, squashes, imported history | dates and spans lie; a project's "birth" may be an import | the manifest records the first commit date; a birth within days of it is flagged as possibly an artifact, never suppressed |
| committer date vs author date | ordering changes depending on which is used | one is chosen, named in the manifest, and used everywhere |
| shallow or partial clones | every detector silently under-reports | `pin` refuses a shallow clone |
| vendored trees, generated files, lockfiles | churn detectors fire on work nobody did | per-subject exclusion paths, declared in the subject and printed in the report header |
| monorepos and subdirectory histories | path prefixes stop meaning subsystems | subjects may name a path scope; scoping is recorded, not inferred |
| a project that develops in branches | the quiet detector fires on active work | stated as a known false positive; no fix |
| force-pushed history | a pin stops resolving | pins are recorded by sha and a run that cannot resolve one fails rather than substituting |

The last row is the general rule this design takes from the family it sits in: a
run that cannot reproduce its evidence **fails**, and does not fall back to
something that looks like an answer.
