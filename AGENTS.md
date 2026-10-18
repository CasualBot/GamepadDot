# Agents

- Never co-author commits, files, PRs, etc.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (CasualBot/GamepadDot), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default vocabulary: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## WoW addon rules

Before editing addon code, read `docs/agents/wow-addon-guidelines.md` (Blizzard policy, taint, secret values, CurseForge do's and don'ts).

## Code location

- All code lives in `D:\dev` (this repo: `D:\dev\GamepadDot`). Never keep or edit the main code in the game's AddOns folder.
- To test, run `powershell -ExecutionPolicy Bypass -File deploy.ps1`, which copies only `GamepadDot.lua` and `GamepadDot.toc` into `G:\Blizzard\World of Warcraft\_classic_beta_\Interface\AddOns\GamepadDot`, then `/reload` in game.
