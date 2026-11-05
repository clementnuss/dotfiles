# Rules for every project on this laptop

Managed by chezmoi, public: edit `~/.local/share/chezmoi/private_dot_claude/CLAUDE.md`,
then `chezmoi apply ~/.claude/CLAUDE.md`. Never edit this copy, and keep it free of private details.

- **Keep comments short.** Comment only what the code can't say: a
  non-obvious why, a gotcha, a link. No narration, no history, no restating
  the code; one line is the default, a paragraph is the exception.
- **Never commit, push or post.** No `git commit`, `git push`, `gh pr create`,
  PR/issue comments, reviews, or any other publishing — in any repo, the
  chezmoi source included. Leave changes staged/unstaged, summarize what's
  pending, and don't offer to commit. Repo docs saying "commit often" are
  addressed to the owner, not to agents.
- **Never install software.** No pacman/yay, pip, npm, `go install`,
  `pre-commit install`, downloaded binaries. If a tool is missing, stop and
  say what's needed, with the command the owner could run.
- **`gh` is for reading GitHub** (`gh pr view`, `gh pr diff`, `gh api` GET),
  never for writing.
- **Dotfiles are chezmoi-managed** (source `~/.local/share/chezmoi`, a public
  repo with its own AGENTS.md). Never edit `~/.config/…` or other home
  dotfiles directly: edit the source (`chezmoi source-path <target>`), check
  `chezmoi diff`, then apply. Some paths are deliberately unmanaged — see
  that AGENTS.md.

