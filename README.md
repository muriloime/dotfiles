# Dotfiles

Personal development environment configuration for Linux/macOS.

## Installation

```bash
cd ~
mkdir code
cd code
git clone git@github.com:muriloime/dotfiles.git
cd dotfiles
sh fresh_start.sh
```

## What Gets Installed

The `fresh_start.sh` script sets up the complete development environment:

### Shell Configuration

- **Zsh** as default shell with Oh-My-Zsh framework
- **Agnoster** theme with syntax highlighting and autosuggestions
- Auto-launch **tmux** on terminal open (except in VSCode)
- Auto-cd to `~/code` or `~/Documents` directories
- Extensive plugin support: git, docker, fasd, rake, ruby, rails, web-search

### Aliases

Platform-aware aliases for common operations:

| Category   | Examples                                                         |
| ---------- | ---------------------------------------------------------------- |
| **Safety** | `cp`, `rm`, `mv` with confirmation prompts                       |
| **Pipes**  | `G` (grep), `L` (less), `H` (head), `T` (tail), `CP` (clipboard) |
| **Git**    | `gg`, `gd`, `gdc`, `gp`, `gpr`, `gco`, `gcm`, `gsweep`, `gdel`   |
| **Rails**  | `be`, `br`, `bsf`, `bsm`, `migrate`, `rollback`                  |
| **Python** | `pyt` (pytest), `pir` (pip install -r)                           |
| **Heroku** | `staging-console`, `production-console`, `db-pull-*`             |

### Git Configuration

- Extensive aliases: `co`, `br`, `ci`, `st`, `lg`, `uncommit`, `car`, `shorty`, `slap`
- Fast-forward only merges with diff3 conflict style
- Vimdiff as diff/merge tool
- Auto-prune on fetch
- Git template with hooks

### Git Utilities (`bin/`)

| Script                            | Purpose                       |
| --------------------------------- | ----------------------------- |
| `git-churn`                       | Show files with most changes  |
| `git-divergence`                  | Show divergence from upstream |
| `git-create-pull-request`         | Automated PR creation         |
| `git-what-the-hell-just-happened` | Debug recent git activity     |
| `git-whodoneit`                   | Blame statistics              |
| `tat`                             | tmux attach or create session |

### Text-to-Speech (TTS)

Voice feedback system with fallback levels:

- **read-loud** / **spd-say**: TTS commands with automatic fallback
  1. Edge-TTS (online, high quality)
  2. Piper (offline, local)
  3. spd-say (system fallback)
- Single voice mode to prevent audio overlap

### Claude Code Integration

Complete Claude Code configuration in `~/.claude/`:

| Component    | Description                                                       |
| ------------ | ----------------------------------------------------------------- |
| **Commands** | `/prime`, `/scout`, `/build`, `/plan_w_docs`, `/scout_plan_build` |
| **Agents**   | `build_agent` for autonomous implementation                       |
| **Scripts**  | Voice notifications, code formatting (Prettier, Rubocop, Ruff)    |
| **Hooks**    | Context bar, voice notifications on completion                    |

### Tmux Configuration

- **Prefix**: `Ctrl+Space`
- **Vim-style** navigation and copy mode
- **Window splitting**: `|` or `\` (horizontal), `-` (vertical)
- 256-color support with activity monitoring
- Auto-renumber windows
- Plugin manager (tpm)

### Vim Configuration

- Vundle plugin manager
- Custom key bindings and plugins

### Ruby/Rails Development

- Bundler configuration
- Pry and IRB with custom configs
- RSpec configuration
- Faster Rubocop via daemon wrapper

### Aider AI Coding Assistant

Python scripts for AI-assisted development:

- `aider_component.py`: Component generation
- `aider_i18n.py`: Internationalization
- `aider_prettify.py`: Code formatting
- `aider_spec.py`: Test generation

### Text Expansion (Espanso)

Quick triggers for common text:

- `\mg`, `\ma`: Email addresses
- `\ty`, `\att`, `\obg`: Signatures
- `\date`, `\ydate`, `\time`: Date/time stamps
- `\pdb`, `\pry`: Debugger breakpoints
- `\zoom`, `\cal`: Meeting links

### IDE Configuration

- VSCode settings synced to `~/.config/Code/User/settings.json`
- Karabiner configuration (macOS)
- IPython profile

### Other Tools

- **ripgrep** (`rgrc`): Search configuration
- **PostgreSQL** (`psqlrc`): Client configuration
- **Mise**: Version manager configuration
- **LLM**: Azure LLM configuration

## Custom Functions

| Function                      | Description                        |
| ----------------------------- | ---------------------------------- |
| `cdl [dir]`                   | cd and list directory              |
| `gpa [dir]`                   | Push all git repos recursively     |
| `rna <name> <version> [opts]` | Create new Rails app with defaults |
| `qq`                          | Reload zshrc                       |

## Local Customization

- `~/.aliases.local`: Local alias overrides
- `~/.zshrc.local`: Local zsh configuration
- `private_vars.sh`: Private environment variables (git-ignored)
