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

## For an ecosystem, status transitions are the primary events

The catalogue below was written for a **tool**: things that happen to code and
to the files around it. Applied to an *ecosystem* it produces a great many
candidates and very little history, because it is answering the wrong question —
a directory appearing inside one member is not an event in the life of an
ecosystem, and the events that are do not appear in any single tree's log.

**An ecosystem's events are memberships.** A tool joins; a tool changes what it
is to the others; a tool leaves; a project inside somebody's tree is recognised
as one; a name is taken; a role moves from one holder to another. Each of those
changes what the arrangement *is*, and none of them is a change to any file that
a path-based detector watches.

This is derivable only where somebody keeps the status as data. Where a footing
is written into a table in prose, the tree records that a paragraph changed and
nothing that a program can call a transition — so the reach of this detector
family is set by the subject's own record-keeping rather than by the detector.
That is a fact worth reporting about a subject rather than a limitation to
apologise for: **an ecosystem whose status changes leave no dated trace is one
whose history cannot be read**, including by the people in it.

The demo subject keeps one footing per tool in a single file, so its transitions
are readable, and the first run of this family found: three tools joining within
zero to two days of their first commit; a footing vocabulary being renamed
under an existing entry; a tool reclassified from a repository into somebody's
child project; and two tools moved from one footing to another and then moved
back, with the intention recorded in a separate field. Not one of those is
visible to any other detector in this catalogue.

### Repository creation is not joining

`repo-added` fires on a source's first commit. That is the birth of a
repository, and it is **not** the same event as a tool becoming part of an
ecosystem — a tree can exist for a year before anybody proposes it, and can be
recorded as a member on the day it is created.

Both are real and the pair is worth more than either: **the gap between them is
a measurement.** A long gap says the ecosystem admitted something that had grown
up elsewhere; a gap of zero says the repository was created already intending to
join, which is a fact about how the arrangement grows and is not otherwise
written down anywhere. `joined` therefore carries the distance from the source's
first commit as a measure rather than reporting a bare date.

### What is not derivable, and why that is a decision rather than a limit

The demo subject records **one** of its status vocabularies as data. It has at
least four:

| what changes status | where it is recorded | dated? | machine-readable? |
| --- | --- | --- | --- |
| a tool's footing in the arrangement | one field per tool in an inventory file | by its commit | **yes** |
| a name moving from reserved to taken, or to started-in-somebody's-tree | a prose table in a register | no | no |
| a role moving from one holder to another | a `Held by` line in a prose inventory | no | no |
| a project inside a tree graduating, being folded, or being retired | a sentence in that project's own README | no | no |

The first row is the one this family reads, and it is the only one that
produces events. The other three are transitions the ecosystem cares about
enough to have written rules about — a name's entry is supposed to change when a
project graduates, a project that has gone quiet is supposed to be retired
rather than parked — and none of them leaves a trace a program can date.

**That is not a gap in this catalogue.** No detector can recover a transition
that was never recorded as one, and inferring status changes from prose diffs is
exactly the model-reads-the-text step this design refuses. It is a fact about the
subject, it is reportable as one, and the observation has been carried upward as
a proposal to the tree that keeps those records — through the parent, by a
person, as topic `D3`. Whether anything changes is theirs to decide, and this
catalogue describes what is derivable today either way.

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

**Status transitions**, read out of a declared inventory file's own history.
The subject names the file; the detectors are generic over "a record whose
revisions are the status history".

| detector | fires on | emits | known failure mode |
| --- | --- | --- | --- |
| `listed` | a tool appearing in the inventory | tool, the status it appeared as | the inventory's first revision is a state, not a transition: everybody present at the start is reported at once, dated to the file's birthday rather than to theirs |
| `joined` | a tool's status becoming full membership | tool, from, to, **days after its own first commit** | it dates the *recording* of a join, not the join. Where the two differ the inventory is late and this cannot tell |
| `status-change` | any tracked field of an entry changing | tool, field, from, to | it sees a field change and never a reason — a footing corrected, a vocabulary renamed and a decision reversed all have one shape |
| `delisted` | a tool disappearing from the inventory | tool, the status it held | removal and rename are indistinguishable without a stable key |

**Everything else in the catalogue is a tool's events**, and is reported per
source:

| detector | fires on | emits | known failure mode |
| --- | --- | --- | --- |
| `transplant` | a body of content appearing at a new path, closely matching content that disappeared | old and new prefixes, similarity, size | a genuine rewrite that keeps the structure scores as a move. The similarity threshold is the most fittable number in the set |
| `birth` | the first commit under a path prefix that goes on to sustained activity | prefix, first commit, activity after | an import or a fork gives everything one birthday; generated directories; template scaffolding present from the first commit |
| `death` | a prefix with sustained activity having no files left | prefix, last commit, size at death | vendored code being dropped; a subsystem moving to another repository, which is a transplant across sources and only visible in ecosystem mode |
| `rewrite` | churn within a surviving prefix over a window exceeding a fraction of its own size | prefix, window, churn, size before and after | formatting sweeps, licence-header changes, regenerated files. Partly mitigated by exclusions and by ignoring commits whose diff is uniform across very many files |
| `release` | a tag matching the subject's version pattern | tag, commit, date | projects that do not tag; tags moved after the fact; pre-release noise swamping real ones |
| `governance` | a governing document added or substantially revised — policy, charter, contribution guide, vision, roles, a register | path, commit, size delta | platform-provided templates count as governance and are not; the *fact* of the document is the event, and this detector cannot see whether anybody followed it |
| `apparatus` | the first of each kind of self-checking: CI configuration, a test directory, a dependency manifest, a formatter or linter, a release script | which kind, commit, date | apparatus added and never used looks identical to apparatus adopted; apparatus inherited at creation from a template is not an event at all |
| `message-join` | each month whose share of subjects naming nothing their own commit touched crosses `join_none_threshold` | month, commits, count naming nothing, share, direction | a subject can be excellent and join nothing — *correct the off-by-one boundary* names no path — and can join everything and say nothing, as *update docs* over `docs/` does. **A subject naming nothing is not thereby a bad one** |
| `ai-attribution` | the first commit carrying a disclosed assistant co-author, and each month whose disclosed share crosses `ai_share_threshold` | month, commits, attributed count, share, model families — **never a name** | it measures **disclosure and never contribution**: the trailer is opt-in, so the floor is zero and there is no ceiling, and a tree with none is indistinguishable from a tree where none was recorded |
| `dependency` | a manifest gaining, losing or repinning a dependency | manifest, name, from, to | lockfile churn drowns the manifest; transitive changes are invisible; vendored dependencies are invisible by construction |
| `quiet` | a gap between commits exceeding a multiple of the subject's own trailing median | gap length, bounding commits | development in branches; a single-maintainer project, whose median is close to meaningless; ordinary absence |
| `hands` | a change in the *number* of distinct contributors over a window | counts only, before and after | one person with several addresses inflates the count; bots; the effect of a `.mailmap` arriving is itself detected as a change in hands, which it is not |
| `repo-added` | a source's first commit — the birth of a repository, **not** a join | source id, date, distance from the first source | the set of sources is hand-written configuration, so this is only as good as what somebody wrote down. It was wrong on the first run: the subject listed a tool the ecosystem's own inventory records as a candidate rather than a member |
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

## `message-join`, and the two words it is careful not to use

The question it came from is *how descriptive are the commit messages*, and
**neither "descriptive" nor a score for it appears in the output**, because both
would break a refusal below.

**What it measures instead is a join.** Do any tokens of a commit's subject
appear in the vocabulary of the paths that commit changed? That is mechanical,
re-derivable, and settles nothing about quality. The stop list is **declared in
the source rather than learned from a corpus**, because a stop list fitted to
the trees it is run on is a judgement that has moved into data.

**It is not a quality metric**, which is refused below. *Names nothing it
touched* is a fact about a join and is **not** a synonym for a poor message; the
failure mode in the catalogue is that excellent subjects routinely score as
naming nothing, and empty ones routinely score as naming something.

**It does not read messages to classify what happened**, also refused below. The
subject is the **object** of the measurement, never evidence for an event. No
model is asked what a commit did, nothing is summarised, and no event elsewhere
in the catalogue changes because of anything a message says.

**Where it is weakest: across subjects rather than within one.** A repository
whose work sits in one directory will score worse by construction. The one
obvious confound was tested before this shipped — that repositories with deeper
paths have more vocabulary to match against — and it did not hold: median
vocabulary per commit was 8, 7 and 8 across three subjects whose *named nothing*
shares were 58%, 35% and 22%. **That is one check on one triple and is not
enough to license cross-subject comparison.** Within one tree over time is the
safe reading.

## `ai-attribution`, and why it is not the two refusals below

It looks like it breaks both of them and it breaks neither, which is worth
writing down because the next reader will have the same objection.

**It does not read commit messages to classify what happened.** It reads one
structured trailer — the name field of `Co-authored-by:` — which is a declared
fact in the commit object, not prose to be interpreted. Nothing is summarised
and no model is asked what a commit did.

**It is not per person.** The measure carries counts and model families. No
human name is emitted at any stage, so nothing downstream can become a fact
about anybody, and the schema is what enforces that rather than this paragraph.

**The one number it produces is a floor.** *Disclosed* assistant contribution is
not assistant contribution: a repository at 0% may have been written entirely by
an assistant whose user never configured a trailer. So the honest reading of a
low share is *this project does not record it*, and the honest reading of a
change in the share is a change in **practice**, which may or may not be a change
in **conduct**. A report that states the second from the first is wrong.

**Its first hand-written version filed six human maintainers as assistants**,
because it matched `ai` anywhere in the trailer line and `gmail.com` contains
it. That is why the pattern anchors on the name field before the angle bracket,
and it is the cheapest available illustration of why a detector's failure mode
is written before its results are trusted.

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
