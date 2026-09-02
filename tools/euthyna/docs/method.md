# Method

How Euthyna measures, and what the resulting numbers are evidence of.

## What is being measured

A proof is not one object with one size. The Logos development is a *layered*
artifact: definitions that say what satisfiability means, a checker that
decides it, and a proof that the checker decides it correctly, where the last
of these is itself several layers deep and 591 rules wide. Asking "how big is
the proof" without saying which layer produces a number that means nothing.

So every measure here answers a narrower question, and the narrowness is the
point:

- **status** — of the rules the calculus declares, how many are proven, by a
  recursive scan for proof gaps rather than by a claim in a document.
- **extent** — how many lines each layer holds, under an attribution that
  makes the layers disjoint so they sum to the whole.
- **reach** — for one rule, how much of the development its correctness proof
  transitively depends on. Reach is *not* a partition: two rules that share a
  support file each count it.
- **share** — for one rule, how much of the rule-proof layer it *claims*, under
  an order that gives shared files to the most core rule that reaches them.
  This one is a partition: the shares are disjoint and sum to the layer, and
  the run fails if they do not. See [partition.md](partition.md).
- **structure** — invariants of the checker layer that are supposed to hold
  and have each drifted at least once, checked textually.

A "line of code" throughout is a non-blank, non-comment line, with Lean `--`
line comments and nested `/- -/` block comments stripped. That definition
comes from the vendored scripts, not from Euthyna, and it is the definition
every number here uses.

## The vendoring discipline

Logos measures itself. `classify-rule-status.py` knows what a proof gap looks
like in a Lean file that a template generated; `cpc-loc-summary.py` encodes,
in its attribution order, which layer of the proof depends on which. That
knowledge is the accumulated result of the development it belongs to, and
rewriting it from outside would produce a worse instrument that also disagreed
with the numbers Logos itself reports.

So the scripts are copied, not reimplemented, and copied *unedited*:

- `analysis/upstream/` holds the whole of Logos's `scripts/` directory byte for
  byte, with `MANIFEST` recording the origin commit and a SHA-256 of each file.
  All of it, not the subset that runs: which scripts measure a proof is a
  judgement that will change, and which existed at a commit is a fact.
- `bin/euthyna verify` re-checks those digests. A vendored script that has
  been touched is a script whose output is evidence about Euthyna's edit
  rather than about Logos.
- `bin/euthyna sync` re-copies from a Logos checkout and rewrites the
  manifest, reporting which files changed. Upstream drift is a thing to
  notice deliberately, on a date, not a thing to absorb silently.

Anything Euthyna wants that upstream does not provide goes in `analysis/`,
alongside rather than inside. `derive.py` and `plot-rules.py` keep the seam
strictly: they read the vendored scripts' *output* and never their internals.

### The discipline has been broken once, and the check caught it

On 2026-08-31 a commit here added three comment lines to the vendored
`check-proof-modularity.sh`, and left `MANIFEST` alone. The lines were a claim
about Logos — that `and` is no longer on the path a proof takes, because
assumptions now arrive as a `CArgList` — written into a file whose header says
every byte of it is Logos's.

**That is the failure this rule is for, in its worst form.** The edit was
comment-only, so no measurement moved and nothing in the baseline is wrong. But
a reader of `analysis/upstream/` attributes what they find there to Logos's
authors, and this was Euthyna talking. An observation about somebody else's
proof is worth having; it is worth having *here*, signed, where a reader knows
who is making it. It is [in `measures.md`](measures.md#gaps) now, and it turned
out to be more interesting than the comment claimed.

The file was restored to its upstream bytes on 2026-09-02. `bin/euthyna verify`
reported it as `CHANGED` on the next run after the edit and on every run until
the repair, which is the whole of what the digests are for: **the discipline is
not that nobody edits these files, it is that an edit cannot go unnoticed.**

`euthyna_lean.py` is the one exception, and it is worth naming as one. The
partition has to agree with `cpc-loc-summary.py` about two things — what counts
as a line, and which files belong to the rule-proof layer — and it cannot get
either by reading a report. So it restates them, which means it can drift.
What keeps it honest is arithmetic rather than discipline: the partition must
sum to the layer total that `cpc-loc-summary.py` independently computes, and
`rule-partition.py` exits non-zero if it does not. A restatement that has
drifted stops reconciling, loudly, in the same run.

## The staging copy

Every vendored script locates the tree it measures the same way: the repository
root is the parent of the directory the script sits in. `cpc-rule-loc.py`
computes `REPO_ROOT` from `__file__`; the shell scripts compute `repo_root`
from `BASH_SOURCE`. Two of them resolve symlinks while doing it.

That contract cannot be met from `tools/euthyna/analysis/upstream/`, and it
must not be met by writing a scripts directory into somebody's Logos checkout.
So a run stages instead: it copies the Logos tree — everything but `.git` and
`.lake`, about 50 MB — into a temporary directory, drops the vendored scripts
into `<stage>/scripts/`, runs them there, and deletes the stage afterward.

The copy takes well under a second on any filesystem with copy-on-write, and
the whole run takes about fifteen. It buys three things worth more than that:

1. **The checkout is only ever read.** Euthyna is measuring somebody else's
   working tree, possibly mid-edit. It must not leave a file in it.
2. **The scripts see exactly the layout they were written for.** No wrapper
   argument, no environment override, no patch — which is what keeps the
   vendored copies honest.
3. **The measurement is of one state.** The stage is a point-in-time copy, so
   an edit made in the checkout halfway through a run cannot produce a
   snapshot whose measures disagree with each other.

Symlinking the tree instead was tried and does not work: the scripts call
`Path.resolve()`, which follows the link back out of the stage, and the
resulting paths are then rejected as being outside the repository root.

## Snapshots

A run writes one directory under `data/snapshots/`, named
`<date>-<logos-commit>[-dirty][-tag]`. It holds every measure's raw output
verbatim, plus:

| file | what it is |
| ---- | ---------- |
| `meta.json` | what was measured: Logos commit and date, whether the tree was dirty, which manifest commit the scripts came from, when the run started and ended |
| `measures.tsv` | which measures ran, which were skipped, and their exit status |
| `summary.json` | the derived analysis, machine-readable |
| `rules.html` | the rule scatter — the one file not kept in git, since `euthyna plot` regenerates it exactly from `rule-partition.csv` |
| `<measure>.err` | present only if that measure wrote to stderr |

Snapshots are kept in git — about 150 KB each. That is the point: a single
measurement says what the proof is like, and a series of them says what it is
*doing*, which is the more useful thing and cannot be recovered later.

A `-dirty` suffix means the Logos checkout had uncommitted changes. Such a
snapshot is still worth keeping and is not reproducible; the name says so.

## What these numbers are not

Worth stating plainly, because each of these is an easy misreading:

- **Reach is not cost.** That a rule's proof transitively reaches 15,400 lines
  does not mean 15,400 lines were written for it. Most of that is shared, and
  the same lines are counted again for the next rule. The `rule-partition`
  measure exists to replace reach with a disjoint share; where a number is
  reach-based it is named `reach` and should be read as a dependency cone.
- **A partitioned share is not authorship either.** It is what a rule adds
  *given every rule more core than it*, so the first rule to touch a shared
  file carries the whole of it. It is much closer to cost than reach was, and
  it is still an attribution rather than a measurement of who wrote what. See
  [partition.md](partition.md#reading-a-point).
- **Lines are not difficulty.** A 300-line proof that took a week and a
  3,000-line one that a tactic generated look the same here. Nothing in this
  directory measures effort, and no conclusion should be drawn about it.
- **"Proven" means no proof gap was found by a source scan.** It is a real
  and checkable property. It is not a claim that the statement proven is the
  statement one wanted, and `classify-rule-status.py` does not and cannot
  check that.
- **A structural check passing means it passed today.** These invariants are
  checked rather than documented because each has drifted before.
- **The soundness measure is skipped by default.** It needs a built Logos.
  A snapshot without it has not established that the soundness proof
  elaborates; `measures.tsv` records the skip.
