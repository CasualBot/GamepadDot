# Releasing to CurseForge

Releases are built by GitHub Actions (`.github/workflows/release.yml`, BigWigs packager) when a `v*` tag is pushed. The game version is set by hand, never guessed from the `.toc`.

## One-time setup (owner)
1. Create the project on CurseForge; note the Project ID ("About This Project").
2. Create a CurseForge API token and save it as the repo secret `CF_API_TOKEN` (`gh secret set CF_API_TOKEN` or GitHub Settings > Secrets > Actions). Never commit it.
3. In `release.yml` set `CF_PROJECT_ID` and `GAME_VERSION` (replace both `TODO`s).

## Each release
1. Test in game (`deploy.ps1`, then `/reload`).
2. Confirm `## Interface:` in `GamepadDot.toc` matches the client; update `GAME_VERSION` in `release.yml` if the target game version changed.
3. Commit with a readable message (becomes the changelog), push, then:
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```
   Tags containing `alpha` or `beta` upload as those types; other tags upload as release.
4. Check the Actions run, then the file on the CurseForge project page.

Agents: never create the secret, never push tags, and never edit `GAME_VERSION` without the owner asking.
