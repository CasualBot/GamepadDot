# WoW Addon Guidelines (Do / Don't)

Read this before changing any addon code. Rules come from Blizzard's UI Add-On Development Policy, the Warcraft Wiki (taint, secret values) and CurseForge's project rules, plus lessons from this repo. Items marked **(verified here)** were hit in this project on the WoW Forever client (interface `16001`).

## 1. Blizzard policy (legal/compliance)

**Do**
- Keep the addon free, with fully readable (non-obfuscated) source.
- Follow the WoW Terms of Use / EULA.
- Keep performance cost low (no spammy chat output, no needless disk loads, no heavy per-frame work).
- Put any donation links on the distribution page / repo only.

**Don't**
- Add paid tiers, paywalled features, ads, or in-game donation prompts.
- Obfuscate or minify code.
- Add content above an ESRB "T" rating.
- Distribute copyrighted game music/audio.
- Assume an addon is safe from being disabled: Blizzard may disable any addon functionality at its sole discretion.

## 2. Taint and secure execution

Addon code and SavedVariables are *tainted*; Blizzard's signed UI is *secure*. Taint spreads to anything tainted code writes or Blizzard code reads from it, and lasts until `/reload` or relog.

**Do**
- Observe Blizzard UI with `hooksecurefunc(obj, "Method", fn)` and `frame:HookScript(...)` (post-hooks; they don't taint the original).
- Do secure/protected-frame work only out of combat; check `InCombatLockdown()` first.
- Use secure templates (`SecureActionButtonTemplate`, etc.) for anything that casts, targets or uses items.
- Change things via the least invasive call (e.g. `SetAlpha` on a non-protected frame).
- Re-apply a visual change from a hook when Blizzard re-sets it (how this addon keeps `GamepadReticle` hidden).

**Don't**
- Replace or overwrite Blizzard global functions, frame methods, or frame fields (`Frame.field = x` on Blizzard frames taints it).
- Call protected functions from addon code, or touch protected frames/attributes in combat.
- Use logic to pick spells or targets for the player (automation is not allowed; one action per player input).
- Call `SetCVar` for restricted/hardware-gated CVars from load or login code. **(verified here)** Doing so produced "GamepadDot has been blocked from an action only available to the Blizzard UI". Only call it from explicit user actions, never in combat, and never assume `pcall` suppresses the popup.
- Treat a "blocked from an action" popup as harmless: find which call caused it and remove it.

## 3. Secret values (Patch 12.0+)

Combat-related APIs (e.g. `UnitHealth`) and some widget geometry/text can return *secret values* to tainted code in restricted states (combat, encounters, M+, PvP, restricted instances).

**Forbidden on secrets:** arithmetic, comparisons, `#`, indexing, use as table key, calling, boolean tests on booleans.
**Allowed:** store in variables/tables, pass to Lua functions, concatenate/`string.format`, `type()`.

**Do**
- Guard with `issecretvalue(v)` / `canaccessvalue(v)` before comparing or doing math.
- Wrap risky reads of foreign frames' geometry or text in `pcall` and skip on failure. **(verified here)** `GetSize()` on EllesmereUI aura frames returned secrets and `w <= 40` errored.
- Prefer displaying/styling (anchoring, color, alpha, size) over reading combat data; Blizzard's intent is "customize, not compute".
- Test restrictions with the simulation CVars (e.g. `addonCombatRestrictionsForced`), which are not saved across restarts.

**Don't**
- Build features that need to combine/compare combat values (cooldown logic, health thresholds, aura tracking). They are intentionally blocked.
- Assume a value is a normal number just because the function normally returns one.

## 4. Client/version facts

- WoW Forever (Classic beta) reports interface `16001`; other addons on the install list `16001` alongside retail `120xxx` numbers. Check with `/run print((select(4,GetBuildInfo())))`.
- A `## Interface:` mismatch shows "Incompatible" in the AddOns list. **(verified here)**
- Some Blizzard UI is load-on-demand (`Blizzard_Gamepad` etc.): frames like `GamepadReticle` can appear after login, so look them up lazily (ticker / `ADDON_LOADED`).
- Blizzard UI source is not on disk for this client; discover frames in game (`EnumerateFrames`, `GetMouseFoci`), and keep such tools read-only.
- `GamePadCursorCentering` did **not** control the dot; `GamepadReticle` (31x31, parent `UIParent`) did. **(verified here)** If a patch renames it, hiding silently stops working.
- Frame/CVar names on this beta can change between builds. Re-verify before relying on them.

## 5. Project conventions

- Addon folder name == `.toc` name == `.lua` name (`GamepadDot`). SavedVariables is `GamepadDotDB`; never rename it without migration.
- Touch only the one Blizzard frame we need. Do not hide or modify other addons' or Blizzard's frames.
- Default must be safe: nothing destructive at login; user-visible state changes via `/gdot` commands.
- Keep code small, readable, and unobfuscated. No external libraries unless required.
- Test in game before claiming it works; there is no offline Lua harness here.
- Never co-author commits, files, PRs, etc. (see `AGENTS.md`).

## 6. Publishing (CurseForge)

**Do**
- Give the project a distinct name/summary/description with clear functionality and support info on the page.
- Provide a changelog with each file upload; tag releases (`v0.1.0`) so `@project-version@` in the `.toc` resolves.
- Credit and link originals if you ever fork, and only where the license allows.
- Use the `.pkgmeta` in this repo (`package-as: GamepadDot`, ignores docs/README/AGENTS).
- Confirm the game-version option exists for the target client before submitting.

**Don't**
- Submit promotional-only or non-descriptive listings.
- Delete and re-upload a rejected project to bypass review; appeal or clarify instead.
- Use AI-generated avatars if a contest/listing forbids them.

## Sources
- Blizzard UI Add-On Development Policy: https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534
- Secure Execution and Tainting: https://warcraft.wiki.gg/wiki/Secure_Execution_and_Tainting
- Secret Values: https://warcraft.wiki.gg/wiki/Secret_Values
- Patch 12.0.0 planned API changes: https://warcraft.wiki.gg/wiki/Patch_12.0.0/Planned_API_changes
- TOC format: https://warcraft.wiki.gg/wiki/The_TOC_Format
- CurseForge project rules: https://support.curseforge.com/support/solutions/articles/9000197279

Caveat: the Blizzard policy text found is the long-standing version; re-check the current official page before publishing. Scope of 12.0 restrictions has changed over time; verify on the wiki.
