# eunoia-ecosystem — history report

**Run date** 2026-09-01. **Tool version** 0.1.0-demo. Stage 5 output: this file is prose and is not re-derivable. `corpus.json`, `events.jsonl`, `claims.jsonl` and `delta.json` are, and are the only source of fact used here.

**This is a self-assessment.** `corpus.json` carries `"self": true` — the subject is a tree family that contains this tool. Under `docs/judgement.md` its conclusions are never cited outward: not as evidence that these practices work, not in a vision document, not in a README.

**Sources and commit counts** (committer date, `--date=short`, as git reports it): logos 707 (2026-03-03 → 2026-08-31); anoieu 96 (2026-08-29 → 2026-09-01); eudaimonia 45 (2026-08-29 → 2026-09-01); dokimasia 31 (2026-08-30 → 2026-09-01); koine 10 (2026-08-31 → 2026-09-01). 889 commits, of which 707 are one source. Excluded paths: `deps/`, `checkers/`, `.lake/`.

**Declared thresholds**, absolute, with `thresholds_changed_after_events` = `false` (no threshold was tuned after these events existed): `prefix_depth` 1, `min_commits_prefix` 3, `rewrite_churn_ratio` 1.0, `rewrite_window_days` 7, `quiet_median_multiple` 6.0, `quiet_min_days` 3, `governance_lines` 40, `transplant_min_files` 3, `hands_window_days` 14, `delta_lag_days` 7.

**Detectors not implemented:** `dependency` — "needs per-manifest parsing; the demo would only be able to say that a manifest changed, which `governance` already says". Eleven others ran.

**Not in the corpus** — stated here and repeated in Q6: (1) **ethos**, which by role is a member of this ecosystem and holds the proof checker and the compiler, is not ours and is left out, so the history as this run can see it is missing one of the two trees that hold its executable artifacts; (2) **issue trackers, pull requests and discussion threads, for every source, by design**; (3) anything unpublished, absolutely.

**Questions** are `questions.md`, pre-registered, digest `39075bf5…` recorded in the manifest. This report answers Q1–Q8 and nothing else.

---

## Q1. What were the major events?

**2026-03-03 — logos begins.** The first source enters at logos-repo-added-0033; the root and the `Cpc` prefix appear the same day (logos-birth-0002, logos-birth-0004, 9,643 later commits touching `Cpc`), with an `examples` prefix (logos-birth-0009) and a build manifest (logos-apparatus-0025). All of these sit on the tree's own first commit, which the design's hazard list says cannot be told from an imported history; the run neither suppresses nor resolves that. An ignore file follows on 03-04 (logos-apparatus-0026).

**2026-03-16 — logos acquires its apparatus,** thirteen days in: a `.github` prefix, a `scripts` prefix, a CI workflow and a CI script on one day (logos-birth-0003, logos-birth-0011, logos-apparatus-0028, logos-apparatus-0027).

**2026-03-21 and 04-06 — two derived calculi:** `CpcMini` (logos-birth-0006, 809 later commits) and `CpcMicro` (logos-birth-0005, 208).

**2026-03-27 and 04-14 — the core is rewritten twice:** `Cpc` churns 63,400 lines at 3.43× its size (logos-rewrite-0015), then 61,847 at 1.46× (logos-rewrite-0016). No other prefix in any source churns on this scale.

**2026-05-30 → 08-11 — documentation becomes a subsystem:** a `docs` prefix (logos-birth-0008), itself rewritten twice (logos-rewrite-0022 at 1.95×, logos-rewrite-0023 at 1.56×).

**2026-07-19 and 08-24 — two prefixes stop:** `CpcMicro` after 208 commits (logos-death-0013), `examples` after 64 (logos-death-0014).

**2026-08-17 → 08-27 — logos is restructured.** `Logos` and `test` prefixes appear (logos-birth-0007, logos-birth-0012) with a parser test (logos-apparatus-0029); the root churns at 4.03× (logos-rewrite-0017); 19 files move between `examples` and `test` (logos-transplant-0001); `test` churns at 13.65×, the highest ratio in the run (logos-rewrite-0024); an `install` prefix appears (logos-birth-0010).

**2026-08-29 → 08-31 — four repositories in three days.** anoieu and eudaimonia enter 179 days after logos (anoieu-repo-added-0044, eudaimonia-repo-added-0011), dokimasia at 180 (dokimasia-repo-added-0011), koine at 181 (koine-repo-added-0009). Each brought its working prefixes on its first day: anoieu-birth-0003, anoieu-birth-0005, anoieu-birth-0007, anoieu-birth-0009, anoieu-birth-0010; eudaimonia-birth-0001, eudaimonia-birth-0006 (`templates`, 254 later commits), then eudaimonia-birth-0007 (`tools`, 118); dokimasia-birth-0001, dokimasia-birth-0003; koine-birth-0001, koine-birth-0004.

**Apparatus arrived with them, faster than it had in logos:** manifest, ignore, tests and generator scripts on day one in anoieu (anoieu-apparatus-0011, anoieu-apparatus-0012, anoieu-apparatus-0013, anoieu-apparatus-0014) and eudaimonia (eudaimonia-apparatus-0009); CI a day later in both (anoieu-birth-0004, anoieu-apparatus-0015, eudaimonia-birth-0002, eudaimonia-apparatus-0010); tests on day one in dokimasia (dokimasia-apparatus-0008); CI on day zero in koine (koine-birth-0002).

**2026-08-30 → 09-01 — the governance cluster, all of it in one tree.** A reporting policy is added (anoieu-governance-0016) and revised six times the same day, one revision touching 663 lines (anoieu-governance-0022) and one the next day 1,245 (anoieu-governance-0034). A policy, a vision, a name register and a proposals file are added on 08-31 (anoieu-governance-0017, anoieu-governance-0018, anoieu-governance-0019, anoieu-governance-0020), the vision revised by 740 lines the same day (anoieu-governance-0031). A roles inventory is added on 09-01 (anoieu-governance-0021) and revised, once by 485 lines (anoieu-governance-0040). All 28 governance candidates are in anoieu.

**2026-08-31 — the two newest trees' first act of self-checking is another tree's check:** dokimasia's first CI file is `policy.yml` (dokimasia-apparatus-0010), koine's is `anoieu.yml` (koine-apparatus-0006).

**2026-08-30 → 08-31 — a child project is started and folded back.** An `anoieu_fuzz` prefix appears (anoieu-birth-0006); nine files move between it and `tools` twice the next day (anoieu-transplant-0001, anoieu-transplant-0002). The declared record calls this being folded into the parent (C0001, C0016, C0019).

**2026-08-29 → 09-01 — the reference graph forms.** Fifteen first mentions of one source inside another, all within four days: logos→eudaimonia (eco-relation-0001), anoieu→logos (eco-relation-0002), eudaimonia→logos (eco-relation-0006), eudaimonia→anoieu (eco-relation-0007), koine→anoieu (eco-relation-0013), koine→logos (eco-relation-0012).

## Q2. Does the tree show events no document mentions?

`delta.json` puts 119 of 123 events in `derived_only`, and that number is not a finding. The file says why: weak matching is **disabled for four of five sources** because the 7-day lag window is not small against a three-to-four-day source span, and undated claims cannot be matched at all and fall to `declared_only` regardless.

What survives the caveat is one hard fact: **logos contributes 0 of the 105 claims.** Every claim comes from anoieu (C0002), eudaimonia (C0026), dokimasia (C0080) or koine (C0097). So the whole 707-commit history above — both core rewrites (logos-rewrite-0015, logos-rewrite-0016), the end of a calculus (logos-death-0013), the August restructuring (logos-transplant-0001, logos-rewrite-0024) and both quiet stretches (logos-quiet-0030, logos-quiet-0031) — is derived and not declared, not because a matcher failed but because the corpus holds no claim from that tree at all.

## Q3. Does the declared record claim events the tree does not show?

101 of 105 claims are in `declared_only`, and most of that is the matcher rather than the record. Three groups separate out, none of them false claims.

- **Work in a tree this corpus cannot see.** C0009, C0052 and C0061 are about the compiler and checker in ethos, which is excluded. There is nowhere in this corpus for them to be true.
- **Work below the depth the detectors reach.** 59 of 105 claims are checkboxes naming individual files (C0036, C0040, C0042, C0044, C0063); `prefix_depth` is 1, so all collapse into a prefix such as eudaimonia-birth-0007. Non-correspondence here is guaranteed by the threshold.
- **Correspondence, not work.** 27 dated topics record positions and disagreements (C0002, C0093, C0097, C0105). Nothing in a tree corresponds to them by construction.

The four claims that did match are the weakest part of the delta; see Q6.

## Q4. What has the evolution done well?

**Apparatus arrived earlier in each later tree.** logos took thirteen days from first commit to CI (logos-repo-added-0033 → logos-apparatus-0028); anoieu and eudaimonia took one (anoieu-apparatus-0015, eudaimonia-apparatus-0010); koine took zero (koine-repo-added-0009, koine-apparatus-0006). Tests and manifests likewise appear on day one in the later trees (anoieu-apparatus-0013, dokimasia-apparatus-0008), where logos's test apparatus dates from 2026-08-17 (logos-apparatus-0029), five months in.

**Retirement is executed in the tree, not only written about.** Two logos prefixes stopped rather than lingering (logos-death-0013 after 208 commits, logos-death-0014 after 64), and the child project the record says was folded into its parent (C0001, C0016, C0019) shows as file movement (anoieu-transplant-0001, anoieu-transplant-0002) and not as an assertion alone.

**The declared record carries its own negative findings.** C0050 records a question declared rather than verified and calls that a finding; C0051 records a check corrected after being found vacuous; C0089, C0090 and C0101 record checks that pass when they should not. A record that only accumulated completions would look identical in the checkbox count and different here.

## Q5. What has it done badly?

**The tree holding four-fifths of the history holds none of the record.** logos is 707 of 889 commits and contributes zero claims; the practice of writing down what happened is visible only in trees three days old (C0026, C0080, C0097, C0002). Whatever Q8's density measures, it does not measure a long-running habit.

**Governance text was written and revised faster than anything could have been practised under it.** The reporting policy was added and revised six times inside one day (anoieu-governance-0016, anoieu-governance-0022 at 663 lines, then anoieu-governance-0034 at 1,245); the vision was revised by 740 lines on the day it was added (anoieu-governance-0018, anoieu-governance-0031); the roles inventory by 485 on the day it was added (anoieu-governance-0021, anoieu-governance-0040). The trees these documents govern were between zero and three days old (dokimasia-repo-added-0011, koine-repo-added-0009).

**Governance is written in exactly one place and read in the others.** All 28 governance candidates are in anoieu, and the two newest trees' first CI file runs that tree's check rather than one of their own (dokimasia-apparatus-0010, koine-apparatus-0006). The evidence shows adoption and carries no counterpart governance file in the adopting trees; it cannot show whether anything was negotiated.

**The instrument is inside the subject, and its delta stage is unreliable.** This tool lives under the `tools` prefix of eudaimonia (eudaimonia-birth-0007), and the extractor pulled a retirement clause out of this tool's own README as a claim about the subject (C0079). The delta then classified 119 of 123 events and 101 of 105 claims as unmatched with the matcher switched off for four of five sources: a stage that could not join produced an answer shaped like a join.

## Q6. What can this tool not see, and does that make Q1–Q5 unsafe?

**Not in the corpus, restated:** ethos, a member by role holding the compiler and the proof checker, so the executable history is missing one of its two trees; **issue trackers, pull requests and discussion threads, for every source, by design**; anything unpublished.

**The delta's four matches appear to be name collisions.** C0005 is matched to anoieu-birth-0010, anoieu-transplant-0001 and anoieu-transplant-0002 — a claim whose text contains the word "tools", against events whose path is `tools`. C0098, C0102 and C0103 are each matched to koine-birth-0004 — claims whose text contains "koine", against the `koine` prefix. All six matched pairs are graded "strong". Q2 and Q3 rest on `delta.json`'s classes, and those classes are close to void here.

**Four of five sources have no baseline.** anoieu, eudaimonia, dokimasia and koine span three to four days at 96, 45, 31 and 10 commits. `quiet` needs a median gap, `rewrite` a window, `hands` 14 days. Both quiet candidates are logos (logos-quiet-0030, logos-quiet-0031); that is a statement about what could be measured, not about whether the other trees had gaps.

**A detector fired whose output the questions decline to use.** logos-hands-0032 reports a change in a committer count. `questions.md` asks nothing about people or rates of work, so this run does not use it; the candidate is a report on the detector catalogue, not on the subject.

**`prefix_depth` 1 hides the child projects.** The calibration prior named child projects as a major event and `birth` reported none: they collapse into `tools` (eudaimonia-birth-0007, anoieu-birth-0010). Calibration scored recall 5 of 6 with this as the miss, and the calibrator states they had read the trees the same day, so 5 of 6 is optimistic and is not this tool's performance.

**A birth on a tree's first commit cannot be told from an import:** logos-birth-0002, logos-birth-0004 and logos-birth-0009 all sit on 2026-03-03.

**Effect on Q1–Q5.** Q1's ordering rests on commit dates and prefix appearances and is the safest thing here, with the 2026-03-03 caveat attached. Q2 and Q3 are unsafe as delta classes and hold only in the reduced form given: logos has no claims, and 59 checkbox claims sit below the prefix depth. Q4's first finding is a comparison of dates and stands; its second and third rest partly on claim text this tool did not verify. Q5's first two findings rest on manifest counts and on line counts in the governance candidates and stand; its third is an observation about an absence and is the weakest sentence in this report.

## Q7. Is this one process or several?

Several, and the boundary is sharp. logos ran 707 commits from 2026-03-03 to 2026-08-31 before a second source existed (logos-repo-added-0033; anoieu-repo-added-0044 at 179 days after). The other four ran 182 commits in four days (eudaimonia-repo-added-0011, dokimasia-repo-added-0011, koine-repo-added-0009).

Three regimes are visible. **One artifact, March to mid-August:** births, rewrites and deaths inside a single tree (logos-birth-0006, logos-rewrite-0015, logos-death-0013). **A restructuring of that artifact, 2026-08-17 → 08-27,** immediately before the burst (logos-birth-0007, logos-rewrite-0017, logos-transplant-0001, logos-birth-0010) — the corpus shows the sequence and cannot show whether it was preparation. **An ecosystem, 2026-08-29 → 09-01:** four repositories, one governance cluster (anoieu-governance-0016, anoieu-governance-0019), and all fifteen cross-references (eco-relation-0001, eco-relation-0002, eco-relation-0012). The set of trees that cite each other is four days old.

## Q8. Does the density of the declared record correspond to anything?

It corresponds, inversely, to how much history a tree has. eudaimonia has 45 commits and 54 claims, more than one per commit (C0026, C0042, C0071); koine has 10 commits and 9 claims (C0097, C0105); dokimasia 31 and 17 (C0080, C0092); anoieu 96 and 25 (C0002, C0025); logos has 707 and none.

The record is 59 checkboxes, 27 dated topics, 13 retirements, 4 decisions, 2 register entries. The decisions and register entries do point at tree events — a name approved on 2026-08-31 (C0025) against a repository appearing that day (koine-repo-added-0009); a child project's retirement clause (C0016) against the files that moved (anoieu-transplant-0002). The 59 checkboxes name individual files and cannot be joined at `prefix_depth` 1 at all.

So the answer this run supports is narrow: the record is dense where the trees are new, absent where they are old, and its most numerous kind is written at a depth this configuration cannot reach. Whether it tracks what happened is not settled by this evidence, and the reason is as much the matcher (Q6) as the record.
