# The detector catalogue

**Goal 2.** What counts as a candidate event, how each one is found, and — the
column that does the work — how each one is known to be wrong.

None of these is written. The catalogue exists first because a detector added
without its failure mode written down will be trusted precisely where it fails,
and because the set below is a claim about what a history *is* that somebody
should be able to argue with before any code exists to defend.

## What a detector is, and what it is not

A detector reads a pinned corpus and emits **candidates**: things that might be
major, each with the evidence that would let a reader check it.

**Detectors are built for recall and are expected to be imprecise.** Deciding
that a candidate is *major* is judgement, it happens at stage 5, and it is
recorded per candidate with a reason. This split is the single most important
thing in the catalogue: a detector that tried to decide importance would bury the
decision in a threshold, where nobody could see it, and the threshold would then
get tuned until the output looked reasonable — which is the failure this whole
design is arranged around.

So: a detector that fires often is not broken. A detector whose candidates are
*always* dropped is, and the rule for it is below.

## The threshold problem

Every detector has a parameter, and a parameter adjusted until the events look
right has been fitted to the answer.

Three rules, in order of how much they help:

1. **Thresholds are relative to the subject wherever possible** — a multiple of
   the subject's own median commit gap, a fraction of the prefix's own size —
   rather than absolute. The same catalogue then runs against a twenty-year-old
   compiler and a two-month-old documentation-heavy tree without being retuned,
   and *needing* to retune is itself a finding about the detector.
2. **Absolutes are declared in the subject and printed in the report header**, so
   a reader sees the numbers the events depend on without opening the code.
3. **Editing a threshold after that subject's events have been computed sets a
   flag on the run**, and the flag is reproduced in the report. It is cleared by
   starting over, never by editing.

## The catalogue

| detector | fires on | emits | known failure mode |
| --- | --- | --- | --- |
| `transplant` | a body of content appearing at a new path, closely matching content that disappeared | old and new prefixes, similarity, size | a genuine rewrite that keeps the structure scores as a move. The similarity threshold is the most fittable number in the set |
| `birth` | the first commit under a path prefix that goes on to sustained activity | prefix, first commit, activity after | an import or a fork gives everything one birthday; generated directories; template scaffolding present from the first commit |
| `death` | a prefix with sustained activity having no files left | prefix, last commit, size at death | vendored code being dropped; a subsystem moving to another repository, which is a transplant across sources and only visible in ecosystem mode |
| `rewrite` | churn within a surviving prefix over a window exceeding a fraction of its own size | prefix, window, churn, size before and after | formatting sweeps, licence-header changes, regenerated files. Partly mitigated by exclusions and by ignoring commits whose diff is uniform across very many files |
| `release` | a tag matching the subject's version pattern | tag, commit, date | projects that do not tag; tags moved after the fact; pre-release noise swamping real ones |
| `governance` | a governing document added or substantially revised — policy, charter, contribution guide, vision, roles, a register | path, commit, size delta | platform-provided templates count as governance and are not; the *fact* of the document is the event, and this detector cannot see whether anybody followed it |
| `apparatus` | the first of each kind of self-checking: CI configuration, a test directory, a dependency manifest, a formatter or linter, a release script | which kind, commit, date | apparatus added and never used looks identical to apparatus adopted; apparatus inherited at creation from a template is not an event at all |
| `dependency` | a manifest gaining, losing or repinning a dependency | manifest, name, from, to | lockfile churn drowns the manifest; transitive changes are invisible; vendored dependencies are invisible by construction |
| `quiet` | a gap between commits exceeding a multiple of the subject's own trailing median | gap length, bounding commits | development in branches; a single-maintainer project, whose median is close to meaningless; ordinary absence |
| `hands` | a change in the *number* of distinct contributors over a window | counts only, before and after | one person with several addresses inflates the count; bots; the effect of a `.mailmap` arriving is itself detected as a change in hands, which it is not |
| `repo-added`, `repo-removed` | a source entering or leaving an ecosystem's declared set | source id, date, where declared | the set's history is configuration, so this is only as good as what somebody wrote down |
| `relation` | a pin to another source, a CI step running another source's tool, a cross-repository reference in a governing document | from, to, kind, commit | pins in CI are reliable and rare; references in prose are neither, and are emitted as claims rather than as facts |

`transplant` runs before `birth` and `death` and suppresses the pair it explains.
That ordering is the only dependency between detectors, and it exists because a
reorganisation otherwise reads as a subsystem dying and an unrelated one being
born on the same day — which is the most common way a history summary produced
this way says something confidently false.

## `quiet`, and why it is in the catalogue

It looks like the weakest detector here and it is deliberate. This family's own
repository policy holds that a directory which has not moved is a claim nobody is
standing behind, and that the honest form of that is a written retirement rather
than silence.

That is a rule about going quiet, applied by hand, to child projects, by whoever
happens to notice. A detector makes it checkable — over any subject, including
the trees that wrote the rule. It will be noisy. It is worth carrying anyway,
because a rule the family enforces on others and cannot see in itself is exactly
the kind of thing this project exists to find.

## What is deliberately not a detector

Each of these was considered and refused, and the refusals are as much the design
as the table above.

- **Quality and complexity metrics.** Lines of code, cyclomatic complexity,
  coverage deltas. They answer a question about the state of an artifact, this
  tool asks about events in a history, and a number that looks like a grade will
  be read as one no matter what surrounds it.
- **Reading commit messages to classify what happened.** A model summarising the
  log is precisely the unauditable step this pipeline is built to avoid. Commit
  messages may be *quoted* as evidence for an event found some other way; they
  are never the measure.
- **Anything per person.** Rates, ownership, review latency. Out by the schema
  rather than by discipline: names do not survive stage 2.
- **Issue trackers, pull requests, discussions.** Excluded for three separate
  reasons, any one of which would be enough: they are not reproducible from a
  pin, they are moderated and edited after the fact, and their availability
  differs so much between subjects that comparing two histories through them
  compares their platforms. Named here so that the omission is visibly a decision
  rather than an oversight — this is the largest thing the tool cannot see, and
  for many projects the most important events happened there.

That last exclusion is the one most likely to be wrong, and the honest
formulation is: **this tool reads what a tree records, and a project whose real
history is in its discussions will be badly described by it.** Whether cvc5 is
such a project is one of the things the first run would find out.

## Adding a detector

Three requirements, and the third is the one that keeps the catalogue small:

1. **Its failure mode is written before it is merged.** A detector without a
   known failure mode is a detector whose failures will be attributed to the
   subject.
2. **It is run against both subjects and the candidate counts recorded.** A
   detector that fires four thousand times on the large subject and never on the
   small one is measuring size, not history, and belongs to whichever subject it
   was really written for.
3. **A detector whose candidates are always dropped is deleted, not tuned.** The
   selection record makes this visible: if every candidate a detector has ever
   produced was rejected with a reason, the detector is not near-miss, it is
   answering a question nobody is asking. Tuning it would fit it to the
   selections already made, which is the same error as tuning a threshold to the
   events.
