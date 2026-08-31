# Changelog

All notable changes to this template are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- README: `dotfiles changelog` in the command list, and a **Write PR titles as
  `<scope>: <subject>`** section explaining why the PR title is the only part of a
  squash-merged branch that survives, and what makes the changelog's scope tags land.
- README: the `squash_merge_commit_title=PR_TITLE` repo setting, without which GitHub
  discards the PR title on any single-commit branch.
- README: how to enforce the suggested `main` workflow with a ruleset (PRs required,
  squash only, no force-push or deletion), since template-created repos inherit none.
- Stow + Oh My Zsh dotfiles starter with the
  [`dotfiles-update`](https://github.com/ccollins/dotfiles-update) plugin baked in
  (startup drift/update signals, `dotfiles-update` / `dotfiles-apply`).
- App-managed-config reconcile pattern: a `reconcile-managed` list wired into
  `bootstrap.sh` and the post-stow `dotfiles-apply-hook`, using the plugin's
  `merge-managed-json` / `capture-managed-json` engine. Documented with Claude Code's
  `settings.json` (per-machine model) as the worked example.
- CI: shellcheck + syntax lint.

### Changed
- The reconcile engine is no longer vendored in the template; it ships with the
  `dotfiles-update` plugin (installed by `bootstrap.sh`), so there is a single source.
