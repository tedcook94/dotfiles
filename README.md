# Dotfiles

This repo contains configuration files for many core applications

## Setup
- Ensure you have both `git` and `stow` installed
- Clone this repo to your home directory
- `cd` into the `dotfiles` directory
- run `stow .` to symlink the config files into the home directory

## Skills (opencode agent skills)

Skills are installed globally via [`npx skills`](https://github.com/vercel-labs/skills) into `~/.agents/skills/`. Only the lockfile (`.agents/.skill-lock.json`) is tracked here; the skill payloads themselves are gitignored and managed by `npx skills`.

Restore on a new device after `stow .`:
```sh
npx skills add -g JuliusBrussee/caveman --skill '*' -y
npx skills add -g vercel-labs/skills --skill find-skills -y
```

Update with `npx skills update -g`. The lockfile is symlinked into this repo, so updates show up in `git diff` — commit the changes to keep devices in sync.

## Notes
- You must preserve the same directory structure in the `dotfiles` directory that you want your config files to have in the home directory
  - e.g. `~/dotfiles/.config/.example` becomes `~/.config/.example` after running `stow .`
- `stow` will automatically ignore some files, such as this README
- A new file added to the `dotfiles` directory won't be symlinked to the home directory until you run `stow .` again
