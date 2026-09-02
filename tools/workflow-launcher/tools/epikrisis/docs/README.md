# Documentation

Every document in this child project, and what each one is for. The charter,
[`../README.md`](../README.md), is the entry point and assumes it has been read.

| document | what it is for |
| --- | --- |
| [`design.md`](design.md) | The pipeline: six stages, the boundary between the four that are programs and the one that is judgement, what each stage produces, what is committed, the command surface, and the hazards that produce plausible wrong answers rather than errors. Goal 1. |
| [`events.md`](events.md) | The detector catalogue: what counts as a candidate event, how each is found, how each is known to be wrong, what was deliberately refused as a detector, and the rule for adding one. Goal 2. |
| [`judgement.md`](judgement.md) | Everything standing in for the fact that the second half cannot be checked by a program: pre-registration, the shape of an assessment, required negative findings, the dropped-candidate record, the stricter rules when the subject is ours, and what calibration can and cannot establish. Goal 3. |

The standard each had to meet is the host's, one level up: a document displaces a
question or an hour of somebody's reading, because writing another page is the
comfortable alternative to doing the work. If a fourth is ever proposed, it
displaces one of these.

Nothing here describes a run. Evidence and reports live beside the subject that
produced them, under `runs/`: documentation says how the tool works, and a
report is the tool's output.
