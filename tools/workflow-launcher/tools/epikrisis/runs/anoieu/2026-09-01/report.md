# anoieu — history report

**Run date** 2026-09-01. **Tool version** 0.1.0-demo. Stage 5 output: this file is prose and is not re-derivable. `corpus.json`, `events.jsonl`, `claims.jsonl`, `delta.json` and `ratio.json` are, and are the only source of fact used here except where a paragraph says otherwise in its first sentence.

**This is a self-assessment.** `corpus.json` carries `"self": true` — the subject is a tree of the family that carries this tool. Under `docs/judgement.md` its conclusions are never cited outward: not as evidence that these practices work, not in a vision document, not in a README.

**Source and commit count** (committer date, `--date=short`, as git reports it): anoieu 132 commits, 2026-08-29 → 2026-09-01, pinned at `56bfb042`. Excluded paths: `deps/`.

**Declared thresholds**, absolute, with `thresholds_changed_after_events` = `false` (no threshold was tuned after these events existed): `prefix_depth` 2, `min_commits_prefix` 3, `rewrite_churn_ratio` 1.0, `rewrite_window_days` 7, `quiet_median_multiple` 6.0, `quiet_min_days` 3, `governance_lines` 40, `transplant_min_files` 3, `hands_window_days` 14, `delta_lag_days` 7. **`prefix_depth` is 2 here and was 1 in the prior run.** It was set before any event for this subject existed, to correct a recall miss this tool published about itself — at depth 1 child projects collapse into `tools`. The change is recorded in the subject file and it is the reason `tools/apodeixis` and `tools/martyria` are visible below at all.

**Detectors not implemented:** `dependency` — "needs per-manifest parsing; the demo would only be able to say that a manifest changed, which `governance` already says". Fourteen others ran; five fired.

**Not in the corpus** — stated here and expanded in Q6: (1) the other trees of the ecosystem, so an event whose other half is elsewhere appears here as a documentation edit and nothing more; (2) **two event classes the subject told us its own tree cannot show, before this run existed** — a stretch boundary and a role changing hands (C0005); (3) issue trackers, pull requests and discussion threads, by design; (4) anything unpublished, absolutely.

**Questions** are `questions.md`, pre-registered, digest `39075bf5…` recorded in the manifest and unchanged from the prior run. Q1–Q6 are answered. Q7 and Q8 were written for the ecosystem subject; Q7 is not applicable to a single tree and is not answered, Q8 is.

---

## Q1. What were the major events?

**2026-08-29 — the tree begins with its apparatus already present.** Seven prefixes appear on the first day: root (anoieu-birth-0005), `anoieu` (anoieu-birth-0007), `anoieu/checks` (anoieu-birth-0008), `docs` (anoieu-birth-0010), `tests` (anoieu-birth-0012), `tests/witnesses` (anoieu-birth-0016) and `tools` (anoieu-birth-0017). On the same day: an ignore file, a manifest, a test runner and a generator script (anoieu-apparatus-0023, anoieu-apparatus-0024, anoieu-apparatus-0025, anoieu-apparatus-0026).

**2026-08-30 — CI, and the first governing document.** The `.github/workflows` prefix and the CI configuration in it both arrive one day after the first commit (anoieu-birth-0006, anoieu-apparatus-0027). `anoieu_fuzz` (anoieu-birth-0009), `scripts` (anoieu-birth-0011) and three test corpora (anoieu-birth-0013, anoieu-birth-0014, anoieu-birth-0015) appear. A reporting policy is added (anoieu-governance-0028) and revised six times the same day — 663, 91, 45, 210, 56 and 275 lines (anoieu-governance-0034, anoieu-governance-0035, anoieu-governance-0036, anoieu-governance-0037, anoieu-governance-0038, anoieu-governance-0039).

**2026-08-31 — the governance cluster and a restructuring.** Four documents are added: a policy (anoieu-governance-0029), a vision (anoieu-governance-0030), a register of names (anoieu-governance-0031) and a proposals file (anoieu-governance-0032). The vision is revised by 740 lines on the day it is added (anoieu-governance-0043), then twice by 42 (anoieu-governance-0044, anoieu-governance-0045); the policy by 155 and 176 (anoieu-governance-0041, anoieu-governance-0042); the reporting policy by 142 and then 1,245 (anoieu-governance-0040, anoieu-governance-0046); the register by 60 (anoieu-governance-0047) and the proposals file by 106, 245 and 144 (anoieu-governance-0048, anoieu-governance-0049, anoieu-governance-0050). Two child projects appear, `tools/sapheneia` (anoieu-birth-0020) and `tools/ynoia` (anoieu-birth-0021). Files move four times: `anoieu_fuzz` into `tools` and back out the same day (anoieu-transplant-0001, anoieu-transplant-0002), `docs` into `docs/reports` (anoieu-transplant-0003) and `scripts` into `scripts/prompts` (anoieu-transplant-0004).

**2026-09-01 — a roles inventory, and a child project that lived one day.** A roles inventory is added (anoieu-governance-0033) and revised seven times the same day — 184, 485, 251, 99, 45, 70 and 75 lines (anoieu-governance-0051, anoieu-governance-0052, anoieu-governance-0053, anoieu-governance-0054, anoieu-governance-0056, anoieu-governance-0057, anoieu-governance-0058). The proposals file is revised once more (anoieu-governance-0055). **`tools/apodeixis` appears and stops on the same day** (anoieu-birth-0018, anoieu-death-0022), and `tools/martyria` appears (anoieu-birth-0019).

## Q2. Does the tree show events no document mentions?

`delta.json` puts 57 of 58 events in `derived_only`, and **that number is not a finding.** Weak matching is disabled for this source — the 7-day lag window is not small against a four-day span — and 9 of 30 claims carry no date at all and cannot be matched regardless.

What survives the caveat is narrower and holds. **The four transplants are declared nowhere.** `anoieu_fuzz` moving into `tools` and back within one day (anoieu-transplant-0001, anoieu-transplant-0002) is described in the declared record as a child project being folded into its parent (C0001, C0021, C0024), which is an account of the destination and not of the round trip. The two structural moves, `docs` → `docs/reports` (anoieu-transplant-0003) and `scripts` → `scripts/prompts` (anoieu-transplant-0004), correspond to no claim in the corpus at all.

## Q3. Does the declared record claim events the tree does not show?

29 of 30 claims are in `declared_only`, and almost all of that is the matcher rather than the record. Three groups separate out and none of them is a false claim.

- **Correspondence, which nothing in a tree corresponds to by construction.** 17 dated topics (C0002 through C0018) record positions, answers and disagreements with other repositories. There is no commit that is the event they describe.
- **Claims about trees this corpus cannot see.** C0013, C0014, C0015 and C0016 are about `ethos` and `koine`, which are not read here.
- **Undated claims.** 9 of 30, including six of the seven retirement clauses (C0001, C0019, C0020, C0021, C0023, C0024) and three of the four decisions (C0027, C0028) and both register entries (C0025, C0026). A claim with no date cannot be placed on a timeline and falls to `declared_only` whatever it says.

**One dating oddity, and it is small.** C0002 is asserted 2026-09-02, one day after the newest commit in the pin (2026-09-01). A document dated after any commit that could carry it is either a timezone artifact in the committer date or a document written ahead of its commit; this run cannot tell which and does not treat it as either.

## Q4. What has the evolution done well?

**Apparatus preceded the thing it was apparatus for, and did so on day zero.** An ignore file, a manifest, a test runner and a generator script are all present on 2026-08-29 (anoieu-apparatus-0023, anoieu-apparatus-0024, anoieu-apparatus-0025, anoieu-apparatus-0026), which is the same day the tree's first seven prefixes appear (anoieu-birth-0005, anoieu-birth-0007, anoieu-birth-0010, anoieu-birth-0017). CI follows one day later (anoieu-apparatus-0027). There is no window in this history in which the tree existed without a test runner.

**Endings are executed in the tree rather than only written about.** `tools/apodeixis` stops after appearing (anoieu-birth-0018, anoieu-death-0022) and its replacement `tools/martyria` appears the same day (anoieu-birth-0019); `anoieu_fuzz` was moved into `tools` and moved back out rather than left in place (anoieu-transplant-0001, anoieu-transplant-0002). Both are visible as file movement, not as an assertion.

## Q5. What has it done badly?

**A child project was created and retired inside a single day, and the declared record says why.** `tools/apodeixis` appears and stops on 2026-09-01 (anoieu-birth-0018, anoieu-death-0022). The register entry that replaced it (C0026) names `martyria` for the same work. This is the one place in this run where derived and declared agree without the matcher's help, and the agreement is about a mistake rather than an achievement.

**Every governing document in this tree was rewritten hardest on the day it was created.** The reporting policy: added and revised six times within the same day (anoieu-governance-0028, then anoieu-governance-0034 at 663 lines, anoieu-governance-0035, anoieu-governance-0036, anoieu-governance-0037, anoieu-governance-0038, anoieu-governance-0039), and revised by 1,245 lines the next (anoieu-governance-0046). The vision: added and revised by 740 lines the same day (anoieu-governance-0030, anoieu-governance-0043). The roles inventory: added and revised seven times the same day, 1,209 lines in total (anoieu-governance-0033, anoieu-governance-0051, anoieu-governance-0052, anoieu-governance-0053, anoieu-governance-0054, anoieu-governance-0056, anoieu-governance-0057, anoieu-governance-0058). **The pattern is not one document's teething; it is all three, and the most recent instance is the most extreme.**

**Work about the work outgrew work on the tool, and the gap widened.** `ratio.json`: for 2026-08, 20,682 prose lines against 17,823 tool lines, a ratio of 1.16. For 2026-09, 9,000 against 1,394 — **6.46**. The subject declares prose to be its product, so the absolute ratio is not comparable with other subjects; the *movement* between two windows of the same tree is not affected by that declaration.

**This answers the question the subject asked, and it is not a pre-registered question.** C0002 asks what happened to the balance between work on the tool and work about the work, and in what order apparatus arrived. The answer is the two paragraphs above: apparatus arrived first and on day zero, and the balance moved from 1.16 to 6.46. **It is recorded here as a question that arrived after the evidence existed.** The digest is unchanged and the question is not in `questions.md`; it is answered under Q5 because it is within Q5's scope, and it is flagged because a question the subject supplies after a corpus is pinned is exactly the shape pre-registration exists to make visible.

## Q6. What can this tool not see, and does that make Q1–Q5 unsafe?

**The delta is void and this is the second subject on which it has been.** One match: C0010 to anoieu-birth-0017, graded "strong". C0010 is a topic titled *we are going to stop proving our report by re-running our tools*; anoieu-birth-0017 is the `tools` prefix. **It is a word collision, the same failure mode the prior run reported, now reproduced on a second subject.** Q2 and Q3 rest on the delta's classes and hold only in the reduced forms given there.

**Two event classes are known-absent because the subject said so first.** A stretch boundary and a role changing hands (C0005) leave a documentation edit and nothing else. The roles inventory's seven same-day revisions (anoieu-governance-0051 through anoieu-governance-0058) are exactly where a role change would hide, and this run cannot tell an inventory being drafted from a role moving. **The subject states the second is one of the largest things that can happen here, so the tool is blind in the place the subject says matters most.**

**One source, four days, no baseline.** `quiet` needs a median gap, `rewrite` a window and `hands` fourteen days; none fired, and that is a statement about what could be measured. The `2026-09` row of `ratio.json` is **one day**, so 1.16 → 6.46 is two points of which one is a single day — the subject's own criticism of a one-row counter (C0002) applies to this run's evidence too, with one row added.

**A finding in this run was not derived by this tool, and is marked.** The paragraph below is hand-read from `git log` and is *not* re-derivable from the pin by running epikrisis; it is reproducible by `git log --format='%s'` over the pinned commit. Of 132 commit messages, 61 (46.2%) are uninformative by a crude test — five characters or fewer, or opening with a word like *More*, *Misc*, *Docs*, *Fix* — and the single most common message is `More`, 27 times. **The rate falls monotonically across the four days: 66.7%, 58.5%, 50.0%, 30.4%.** That is the opposite of what this reader expected to find and is reported because it is what the artifact says — with the caveat that the first day is 2 of 3 commits, so the decline rests on three points, not four. **No detector in the catalogue measures this**, which is the finding about the tool: the run was asked what went wrong recently and the most legible answer available in the tree is one the pipeline cannot produce.

**Effect on Q1–Q5.** Q1 rests on commit dates and prefix appearances and is the safest thing here. Q2 and Q3 are unsafe as delta classes and hold only in the reduced forms stated. Q4 rests on file dates and stands. Q5's first three findings rest on dates, line counts and `ratio.json` and stand; the fourth is flagged as a post-hoc question and the commit-message paragraph is flagged as hand-read.

## Q7. Is this one process or several?

Not answered. The question was pre-registered for the ecosystem subject, where it asks whether a long single-tree history and a recent multi-tree burst are one story. A single tree spanning four days does not pose it.

## Q8. Does the density of the declared record correspond to anything?

It corresponds to correspondence. 17 of 30 claims are dated topics addressed to other repositories (C0002 through C0018), and none of them has a counterpart in this tree by construction. Of the remainder, 9 carry no date. **The declared record of this tree is mostly a record of what it said to others, not of what it did**, which is why the delta cannot use it and why 57 of 58 events are unmatched.
