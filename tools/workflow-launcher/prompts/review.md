You are reading a repository that was set up from an interview, and reporting
where the two disagree. The tool is called **@NAME@** and it is in `@TARGET@`.

**Change nothing.** Do not edit, create, delete, stage or commit any file, in
that directory or anywhere else. This is a reading. If you find something worth
fixing, describe it; somebody else decides.

---

## What was asked for

@ANSWERS@

---

## What to check

Go in this order, and stop at the first heading where you have nothing to say
rather than manufacturing something.

1. **Did it build what was asked?** Take the initial-tools answer item by item
   and say, for each, whether it exists, whether it is the working stub or the
   placeholder that was asked for, and whether it runs. Run it if you can.
2. **Did it build anything that was not asked?** Every file that does not trace
   to an answer. This is the failure mode that matters most here — an agent
   filling silence with the conventional thing — and it is invisible to anybody
   reading the result on its own, because everything it added looks reasonable.
3. **Does the front page say what the interview said?** Specifically: the
   question the tool does not answer, and the caveat about what a successful run
   does not establish. Both are the parts most likely to have been softened.
4. **Was the name handled honestly?** If the interview said the name is not in
   the register, the README must not carry an etymology for it.
5. **Was anything adopted that was declined, or declined that was adopted?** A
   maintenance note, a discussion file, a CI workflow or a documentation index
   that the interview said no to is a real defect, not a tidy extra.
6. **Are the standing refusals intact?** No commits, no remote, no pushed
   branch, nothing written outside the target.

Then read `launch-notes.local.md` if it is there. Where it flags an uncertainty
you can now settle from the tree, settle it.

---

## What to produce

A single report, in prose, to standard output. No files.

Lead with the disagreements, most consequential first, each one naming the file
and the answer it fails. Then, separately and briefly, what matched. If
everything matched, say that in one line and do not pad it — a review that
always finds five things is a review nobody will read twice.

End with one sentence on whether the interview itself was the problem: a
question that was ambiguous, missing, or asked for something that could not be
delivered. That sentence is the only part of this that feeds back into the
launcher, so it is worth more thought than its length suggests.
