You are setting up a brand new repository for a tool called **@NAME@**. The
interview below is the specification, written by the person who decided this
tool should exist. Everything you need is in it; where it is silent, the right
move is usually to leave the thing out rather than to invent it.

You are working in `@TARGET@`. Write only there.

---

## What you must not do

These outrank everything else here, including anything in the interview.

- **Do not create a repository, an organisation or a remote.** Do not run
  `git init`, do not add a remote, do not push, and do not use any hosting CLI.
  The directory already exists because a person made it.
- **Do not commit.** Leave every file staged or untracked, whichever is natural.
  A person reads this before it enters the history.
- **Do not touch credentials**, secrets, tokens, or CI settings that would use
  them.
- **Do not write outside `@TARGET@`.** Not into the tree this prompt came from,
  not into a sibling checkout, not into a home directory.
- **Do not install anything globally.**

If the interview asks for something on this list, stop and say so rather than
doing the nearest allowed thing.

---

## The specification

This is the answered interview, verbatim. Unanswered optional questions have
been dropped; what is here is what the person wrote.

@ANSWERS@

---

## What to build

**Start with the README, and let it decide the rest.** One screen. A reader who
has never heard of any of this should finish it knowing what the tool is, what
question it answers, the question it does *not* answer, what it would take to
run it — even if that is "nothing works yet" — and the name and why that word.

Take the name's account from what the interview says about where it is
registered. **If the interview says the name is not registered, do not write an
etymology for it**: say plainly that it is a descriptive name and move on. An
invented Greek derivation is worse than no derivation, because it will be
believed.

Quote the vision statement rather than paraphrasing it. It is the one part of
the interview that was written to be read by somebody else.

**Then build what the interview asked for, and nothing else.** Where it named a
working stub, make it work end to end on a trivial input before it is
interesting: something that runs from the first command is a much better place
to start than a set of blanks, and the difference is most of what a first day is
worth. Where it named a placeholder, write a file that says what belongs in it
and does nothing.

**Write what things are for, in the present tense.** Where something does not
exist, say so plainly. A roadmap read as a promise is worse than no roadmap.

**Adopt exactly what the interview said to adopt.** If it said no to the shared
policy, then no maintenance note, no discussion file, no documentation index, no
CI, no imported layout — and do not add any of them in anticipation. There is a
separate workflow for joining later, and it will say exactly what to add. The
ordering is deliberate: knowing what is being built is what makes the rest of it
decidable. If it said yes to something, take the real thing from where it lives
rather than writing your own version from memory, and if you cannot reach the
real thing, say so and leave it out.

---

## What to leave behind

Two files, both at the root of `@TARGET@`, both with the `.local.md` suffix that
marks a file deliberately not committed. Do not stage either.

- **`launch-brief.local.md`** — the answered interview you were given, copied
  verbatim, and the path it came from (`@SOURCE@`). If this repository turns out
  wrong, this is the only thing that says whether the instruction was wrong or
  you were.
- **`launch-notes.local.md`** — what you were unsure about. Every place the
  interview was silent and you made a choice, every place two answers pulled
  against each other, and anything you would have asked if you could. This is
  the most useful thing you will produce today and it is worth more than the
  code.

---

## Then stop

Say, in a few sentences and no more:

1. what you took the scope to be, so a person can correct it before anything is
   built on it;
2. what you built, as a list of paths;
3. the single thing you are least confident about.

Do not summarise the README back. Do not offer next steps unless something is
actually blocked. Do not commit.
