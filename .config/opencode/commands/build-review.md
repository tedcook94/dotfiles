---
description: Build a feature/fix, then iterate with automated review until clean
agent: build
---

Complete the following task, then get it reviewed through an automated loop.

## Task
$ARGUMENTS

## After Building
Once your changes are complete:
1. Invoke @quick-reviewer to review your changes (pass it the output of `git diff`)
2. Read the feedback carefully
3. For each item:
   - **critical/warning**: Address it
   - **nit**: Use your judgment -- fix if trivial, skip if you disagree
4. If the verdict is REQUEST_CHANGES, address the items and invoke @quick-reviewer again
5. Repeat until the reviewer returns APPROVE
6. Summarize what was built and what changed during review

Do not skip the review step. Do not mark the task complete until reviewed.
