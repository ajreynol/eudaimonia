# The ledger

Everything the load showed, one entry at a time. **Goal 1**, and the only
output of this project that is meant to outlive it.

**It is empty. Nothing has been run.**

## Why a ledger and not a report

A stress test's findings are about the repository that carries it, one directory
up, which makes them unusually easy to act on and therefore unusually easy to act
on too early. The discipline the repository policy asks of a child project holds
here without modification and matters more than usual: entries accumulate, and a
**person** decides whether any of them becomes a line in `TODO.md` or in
`docs/limitations.md`. Nothing leaves by machine, and this directory never edits
its parent.

The failure mode being guarded against is specific. A stress test that fixes what
it finds stops being a measurement and becomes a development branch — and the
policy is blunt that a development branch is served better by an actual branch.
The value of these entries is that they were produced by something that could not
also make them go away.

## The form of an entry

One file per entry, `A<n>-<slug>.md`, with a header carrying:

| field | |
| --- | --- |
| **id** | `A1`, `A2`, … Assigned when written, never reused, never renumbered |
| **date** | when it was observed |
| **run** | the run it came from: the fragment, the parent's commit, the compiler pin, the exact command |
| **stage** | render, contract, generate, or build |
| **grade** | refused, mis-shaped, silently wrong, disproportionate — or *the calculus's*, with the argument |
| **hypothesis** | which of `H1`–`H7` it bears on, or *unpredicted*, which is the interesting value |
| **status** | open, confirmed, carried, withdrawn |

Then the body: what was being attempted, what happened, the smallest input that
shows it, what it would take to fix, and whose problem the entry claims it is.

**Confirmed** means somebody other than the run reproduced it. **Carried** means
a person took it to `TODO.md` or `docs/limitations.md`, and names where it
landed. **Withdrawn** means the entry was wrong — those stay, with the reason,
because a ledger that deletes its errors cannot be used to judge its own hit
rate.

## What does not go here

- **Anything about Alethe.** A rendering that is wrong about the target is a
  defect in the probe. It gets an entry graded against this project, and it is
  not a finding against anybody's specification and is not published as one.
- **Ideas for the framework.** A break is an observation. What to do about it is
  the parent's decision and belongs in the parent's own roadmap, put there by a
  person.
- **Anything about a third party's tree.** If a run turns up something wrong in
  the compiler or in ethos, that is an ordinary finding and leaves through this
  repository's normal reporting discipline with an id and a state — not through
  here, and not with a stress test's standard of evidence.

## Unpredicted entries

The count of entries marked *unpredicted* against the count marked `H1`–`H7` is
the one number this project can report about itself honestly, and it is worth
more than the total. Seven predictions were written down before any run
precisely so that this ratio exists.
