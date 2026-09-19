# Maintaining this repository

**If you are a person maintaining Eudaimonia — possibly by directing an agent —
this is where to start.** What this repository is responsible for, the one
command that says whether it is healthy, and the four things an agent may
prepare and may not do. Everything a *user* needs is on
[`../README.md`](../README.md) and none of it is repeated here.

## What this repository is responsible for

The **calculus template**: the Logos arrangement with the calculus taken out,
and the generator that renders it. Bring a Eunoia signature and a semantics, get
a Lake project with a checker, its proofs, its regression suite and its
documentation.

The implementation, defaults, templates and example specifications are in
[`new_checker/`](../new_checker/README.md). The three commands in `scripts/`
launch the corresponding scripts there. Shared documentation stays in `docs/`,
regression checks in `tests/`, and child projects in `tools/`.

**Not the checkers it writes.** A checker you mean to develop belongs in a
repository of its own; `new_checker/checkers/` here is scratch space and git ignores it.

**Not the compiler.** `ethos-eoc` is cvc5's, and what this repository wants from
it is a ranked list in [`eoc-requests.md`](eoc-requests.md) rather than a patch.

## Where to look first

| you want to | read |
| --- | --- |
| know what a run produces, option by option | [`generated-checker.md`](generated-checker.md) |
| know what a generated checker still cannot do | [`limitations.md`](limitations.md) |
| know what is planned, against the Logos file each item corresponds to | [`../TODO.md`](../TODO.md) |
| know what is wanted from the Eunoia compiler | [`eoc-requests.md`](eoc-requests.md) |
| see what the other tools have said to us | [`discussion.md`](discussion.md) |

## The one command

```bash
scripts/run-ci.sh
```

The repository launcher first runs `tests/test_layout.py`, which checks the
standalone tool and launchers without downloading or building dependencies.
Run those checks alone with `python3 -m unittest discover -s tests -p 'test_*.py'`.

It generates a checker for six option configurations, installs each calculus,
and then runs **that project's own CI** — so what is tested is what a user gets
rather than a script written to pass. It is what GitHub runs on every push and
it takes a couple of minutes. Nothing else here substitutes for it.

`scripts/run-ci.sh --list` prints the configurations, `--keep` leaves the
generated checkers behind to look at, and `-q` reduces it to the verdicts.

The policy check is not in that suite, because it runs from a checkout of
somebody else's tree rather than from this one:

```bash
python3 <a-checkout-of-anoieu>/scripts/policy_check.py --policy-version 1 --root .
```

On a push it is [`../.github/workflows/anoieu.yml`](../.github/workflows/anoieu.yml)
that runs it, against the commit that file pins.

## What only a person does

An agent may prepare every one of these and may take none of them.

**Move the `anoieu` pin.** The next section is the whole of it.

**Carry anything to another repository.** A reply, a finding, a topic — the
discussion file is a wire only in the sense that a person reads it and walks it
over. Nothing here sends anything, and [`discussion.md`](discussion.md) carries
the gate that says so.

**Start or end a child project.** `tools/X/` is a claim on attention and a name
in a shared namespace. The shared policy reserves both ends of one to a person;
everything *inside* an existing child may be written by whoever is doing the
work.

**Decide this repository's standing.** Whether it holds a role, whether its work
is worth publishing, whether a child has earned its keep. An agent asked
*should you hold X* will find the case for X, because finding it is what it was
asked to do.

## The `anoieu` pin

[`../.github/workflows/anoieu.yml`](../.github/workflows/anoieu.yml) names
`ANOIEU_REV`, which is this repository on the **pinned** form rather than on
anoieu's versioned contract. Moving it is how this tree takes on whatever the
checker has learned to ask for since, and it is a commit here.

**The pin and the front page's declaration move together.** The checker at the
current pin requires a membership declaration naming `ajreynol/anoieu`; the
checker on anoieu's `main` accepts that *or* `ajreynol/kanon`, which is where
the policy page is. So the declaration is written to satisfy both, and a bump is
what would let it be written to satisfy one. They are coupled the way
`ETHOS_VERSION` and `install/defs/smt.eos` are, and for the same reason.

**The condition for moving it is anoieu's and it is not optional.** Move only to
a commit where anoieu's own CI is green; ask about **that commit** rather than
about their tip, because green-at-a-commit never changes afterwards and
green-at-HEAD does; and refuse when the answer cannot be established, since
*we asked and it is not green* and *we could not ask* are different facts and
neither is a pass. It reads a remote, so it belongs in a person's hands or in a
bump script and **never in this repository's CI**.

**What has been established, which is not the same as the decision.** The
candidate is `154228a`, the first commit in which `scripts/policy_check.py`
takes `--policy-version` at all: its predecessor `87cc0c2` does not. Asked about
that commit on **2026-09-17**: seven check runs, every one `success` — `suites
(3.10)`, `suites (3.12)`, `documentation-up-to-date`, `corpus`, `refresh`,
`oracle`, `policy`. That satisfies anoieu's condition. **It does not make the
decision**, which is 191 commits of policy this tree has never been held to.

**And a bump is no longer the only shape the decision has.** The policy allows a
member to name a **contract** instead of a checker commit, calling anoieu's
shared workflow: the obligations are fixed and the implementation is free to
move, so a build can go red with nothing committed here. Read in the sibling
checkouts on **2026-09-18**, of the nine members other than this one: four —
epikrisis, kanon, koine and logos — are on the contract form; aisthesis and
eschaton pin `154228a`; tachyon pins `442bb67`; dokimasia pins `87ad6825`
through its own lock file; anoieu runs its own checker. So `154228a` is one of
three live pins rather than *where everybody went*, and the real choice here is
**pin or contract** before it is *which commit*. Either is a person's, and the
maintenance note on the front page says which form this repository is on so that
a reader of a red build knows what could have moved.

**What the pin costs while it stays.** The checker at it requires a
`**Status:**` field on every discussion topic, which the shared policy retired —
so this repository's discussion file, written to the policy, draws one minor
finding per topic from a green, correctly pinned checker. Nothing goes red: the
check is minor at that commit and the job exits 0. Where a pinned checker and
the policy disagree the policy wins, and the bump is what clears the finding.
