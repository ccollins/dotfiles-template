# dotfiles-template

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
| ⬆ update available | remote branch is ahead of local | `dotfiles-update` |

Each of the last two obeys a **mode** — `prompt` (default), `auto`, `reminder`, or
`disabled` — set in `shell/.zshrc`:

```zsh
zstyle ':dotfiles:update' mode prompt      # pulling remote updates
zstyle ':dotfiles:apply'  mode prompt      # restowing after HEAD moves
zstyle ':dotfiles:update' frequency 1      # days between remote checks
```

Full plugin docs and options: **https://github.com/ccollins/dotfiles-update**

## Commands

- **`dotfiles-update`** — fast-forward pull `main`, then apply.
- **`dotfiles-apply`** — restow every package and record the installed commit.

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

## Layout

```
.
├── bootstrap.sh      # idempotent setup: brew, OMZ, plugin, stow, marker
├── Brewfile          # Homebrew packages (edit me)
├── shell/.zshrc      # example zshrc wired to the plugin (edit me)
├── git/.gitconfig    # identity + sane git defaults (edit me)
└── .gitignore        # ignores ~/.zshrc.local and .DS_Store
```

## License

MIT — see [LICENSE](LICENSE).
