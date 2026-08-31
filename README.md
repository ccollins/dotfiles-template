# dotfiles-template

[![ci](https://github.com/ccollins/dotfiles-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ccollins/dotfiles-template/actions/workflows/ci.yml)

A minimal, opinionated starting point for a **macOS/Linux dotfiles repo** managed with
[GNU stow](https://www.gnu.org/software/stow/) and [Oh My Zsh](https://ohmyz.sh), with the
[`dotfiles-update`](https://github.com/ccollins/dotfiles-update) plugin baked in so your
shell tells you when your dotfiles have drifted and offers to fix it.

> **This is a GitHub template.** Click **“Use this template” → “Create a new repository”**,
> then clone *your* copy and customize it. Everything below assumes you cloned it to
> `~/dotfiles`.

## The idea in 60 seconds

- Your config files live in this repo, grouped into **stow packages** (one top-level
  directory per package). `stow` symlinks them into `$HOME`, so edits are live.
- `bootstrap.sh` sets a machine up from scratch — Homebrew, Oh My Zsh, the plugin, and
  the symlinks — and is safe to re-run.
- The **`dotfiles-update` plugin** checks on every shell startup whether your repo is
  dirty, un-applied, or behind its remote, and offers `dotfiles-apply` / `dotfiles-update`.

## How stow packages work

Each top-level directory is a “package” whose internal layout mirrors `$HOME`:

```
~/dotfiles/
├── shell/.zshrc      ->  ~/.zshrc
├── git/.gitconfig    ->  ~/.gitconfig
└── <package>/<path>  ->  ~/<path>
```

`stow -d ~/dotfiles -t ~ --restow shell` creates those symlinks. To add config for a new
tool, make a package directory and put the file at the path it should have under `$HOME`.

⚠️ **stow won’t overwrite a real file.** If you already have a `~/.zshrc` (Oh My Zsh’s
installer may create one), back it up first: `mv ~/.zshrc ~/.zshrc.bak`, then bootstrap.

## Quick start

```sh
# 1. Create your repo from this template (button above), then:
git clone git@github.com:<you>/<your-dotfiles>.git ~/dotfiles
cd ~/dotfiles

# 2. Edit your identity and packages
#    - git/.gitconfig      -> your name/email
#    - shell/.zshrc        -> DOTFILES_PACKAGES + your config
#    - Brewfile            -> your packages
#    - bootstrap.sh        -> PACKAGES (keep in sync with DOTFILES_PACKAGES)

# 3. Install
./bootstrap.sh
exec zsh
```

## What you get on shell startup

The plugin surfaces three independent signals for `~/dotfiles`:

| Signal | Meaning | Fix |
|--------|---------|-----|
| ⚠ uncommitted / unpushed | local work not saved/pushed | `git commit` / `git push` |
| ⬇ not applied | `HEAD` moved past what you last installed | `dotfiles-apply` |
| ⬆ update available | remote branch is ahead of local | `dotfiles-update` (prints a changelog of what it pulled) |

Each of the last two obeys a **mode** — `prompt` (default), `auto`, `reminder`, or
`disabled` — set in `shell/.zshrc`:

```zsh
zstyle ':dotfiles:update' mode prompt      # pulling remote updates
zstyle ':dotfiles:apply'  mode prompt      # restowing after HEAD moves
zstyle ':dotfiles:update' frequency 1      # days between remote checks
```

Full plugin docs and options: **https://github.com/ccollins/dotfiles-update**

## Commands

- **`dotfiles status`** — on-demand state of every axis; **`dotfiles doctor`** — health check.
- **`dotfiles update`** — fast-forward pull `main`, then apply.
- **`dotfiles apply`** — restow every package and record the installed commit.
- **`dotfiles changelog`** shows what changed, grouped and tagged by scope. `dotfiles
  update` prints it automatically after a pull, so you see the commits you just picked
  up instead of a bare "updated" line.
- **`dotfiles vendored`** — check any vendored (pinned) copies for upstream updates; point
  `DOTFILES_VENDORED_DIRS` at the dirs holding your `.vendor` files (see the
  [plugin README](https://github.com/ccollins/dotfiles-update#checking-vendored-dependencies)).

Run `dotfiles help` for the full list.

## A suggested workflow for `main`

For a repo that also holds “config as code,” a lightweight PR flow keeps a reviewable
history even solo:

1. Branch: `git checkout -b change-x`
2. Commit and push.
3. Open a PR against `main` and merge it (`gh pr merge --squash --delete-branch`).
4. Sync: `git checkout main && git pull --ff-only` — and a new shell will offer to
   `dotfiles-apply` the change.

This is optional; commit straight to `main` if you prefer. Either way, the update check
keeps every machine you own honest about which commit is actually installed.

### Write PR titles as `<scope>: <subject>`

If you squash-merge, the PR title becomes the commit subject verbatim, plus `(#N)`. That
one string is what `git log` shows forever and what `dotfiles changelog` prints when you
pull on another machine. Branch commit messages are discarded by the squash, so the title
is the only part worth writing carefully.

Prefix it with the stow package or top-level path you touched:

```
shell: fold the fzf keybindings in behind a guard
git: add the Heroku credential helper
brewfile: drop the built-in VSCode extensions
docs: explain the not-applied signal
```

**Set your repo to use the PR title first.** GitHub's default for squash merges is
`COMMIT_OR_PR_TITLE`, which uses the *branch commit's* message whenever the branch has
exactly one commit. On that default, a branch you committed as `wip` lands on `main` as
`wip (#12)` and the title you wrote is thrown away. Fix it once per repo:

```bash
gh api -X PATCH repos/<you>/<your-dotfiles> \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY
```

(Settings → General → Pull Requests → "Default to PR title for squash merge commits" does
the same thing.)

Two rules make the tags land:

- **One lowercase token, no spaces.** A multi-word prefix (`Shell config: ...`) is not
  read as a scope, and the changelog leaves that row's tag blank.
- **Start the subject lowercase**; the changelog capitalizes it for you.

`docs:` and `fix:` are [Conventional Commit](https://www.conventionalcommits.org) types,
so the changelog files them under their own `Documentation:` and `Bug fixes:` headings
instead of one flat list. You don't have to adopt Conventional Commits to benefit here: a
plain `<package>: <subject>` prefix is enough to get a readable, scannable changelog, and
a repo that uses no prefix at all still gets one clean list.

## Reconciling app-managed config files

Some tools **own and rewrite their own config** — think an editor or CLI that persists
your model/account/UI choices back to disk. You can't just `stow` a tracked copy in:
the app's edits fight git, and machine-specific choices (e.g. a per-laptop model or
account) would propagate to every machine.

This uses a small, **tool-agnostic** pattern:

- **`merge-managed-json`** / **`capture-managed-json`** — the engine, shipped by the
  [`dotfiles-update`](https://github.com/ccollins/dotfiles-update) plugin (installed by
  `bootstrap.sh`, on `PATH` when the plugin loads). `merge` regenerates the *live* file
  from a tracked *base* — base wins for shared keys, your listed **machine-local keys**
  are preserved; `capture` promotes live shared changes back into the base.
- **`bin/.local/bin/reconcile-managed`** — *your* list. Add one `merge-managed-json` line
  per managed file. It runs at install (`bootstrap.sh`) and on every `dotfiles-apply`
  (via the `dotfiles-apply-hook` in `shell/.zshrc`), so one edit keeps every machine
  reconciled.

### Example — Claude Code's `~/.claude/settings.json`

Claude Code rewrites `~/.claude/settings.json` (via `/model`, `/config`). To share
plugins/theme but keep the **per-machine `model`** out of git:

```sh
# 1. Track the shared half (everything except model):
mkdir -p claude
jq 'del(.model)' ~/.claude/settings.json > claude/settings.base.json

# 2. In bin/.local/bin/reconcile-managed, add:
merge-managed-json "$DOTFILES/claude/settings.base.json" \
                   "$HOME/.claude/settings.json" model
```

Now `/model` on any machine stays local and never commits; shared plugins flow via the
base. Add more preserved keys by listing them: `... settings.json model theme`.

Don't use this? Delete `bin/.local/bin/reconcile-managed`, the `dotfiles-apply-hook` in
`shell/.zshrc`, and the reconcile step in `bootstrap.sh`.

## Layout

```
.
├── bootstrap.sh      # idempotent setup: brew, OMZ, plugin, stow, marker, reconcile
├── Brewfile          # Homebrew packages (edit me)
├── shell/.zshrc      # example zshrc wired to the plugin (edit me)
├── git/.gitconfig    # identity + sane git defaults (edit me)
├── bin/.local/bin/
│   └── reconcile-managed   # your list of managed files (engine comes from the plugin)
└── .gitignore        # ignores ~/.zshrc.local and .DS_Store
```

## License

MIT — see [LICENSE](LICENSE).
