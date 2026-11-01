# CLAUDE.md

## What this repo is

Research on the rules and process for publishing iOS apps on the App Store. The main case is 7EDU shipping 7edu.vip (Seven by 7EDU) as an iOS app; a few practice apps are used to run through the process.

- Main document: `README.md`. It covers the first-release checklist, the per-version release flow, likely rejection reasons, the practice plan and the review log.
- The 7edu.vip source lives in `/Users/chen/Codes/v0-ai-powered-counselor-system` (Next.js 15 + Supabase, deployed on Vercel). For product background, read `PRODUCT.md`, `ARCHITECTURE.md` and `CLAUDE.md` there. Don't change anything in that repo.

## Writing the docs

- Write in English, so the whole team can read it.
- Cite a source for every rule: an App Review Guidelines number (e.g. 4.8, 5.1.2(i)) or a link to Apple's official docs.
- Apple's rules change. Before adding or changing anything about dates, sizes or version requirements, check Apple's official pages. If only a third-party source confirms it, mark it "not verified against Apple's docs".
- When you update the README, update the "Last updated" date at the top.
- Log every rejection in the README's review log, with the guideline number and the fix.

## Git

- Use Conventional Commits for the subject, e.g. `docs: ...`, `feat: ...`.
- Leave a blank line after the subject, then write a body that says what changed and why.
- **Don't add a `Co-Authored-By` line to commit messages**, and don't add AI attribution to PR descriptions.
- The remote must use the company account's SSH alias: `git@github.com-work:YangChen7EDU/ios-app-publication.git`. Plain `github.com` pushes as the personal account tjcchen and is rejected.
