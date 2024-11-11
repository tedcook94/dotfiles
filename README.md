# Dotfiles

This repo contains configuration files for many core applications

## Setup
- Ensure you have both `git` and `stow` installed
- Clone this repo to your home directory
- `cd` into the `dotfiles` directory
- run `stow .` to symlink the config files into the home directory

## Notes
- You must preserve the same directory structure in the `dotfiles` directory that you want your config files to have in the home directory
  - e.g. `~/dotfiles/.config/.example` becomes `~/.config/.example` after running `stow .`
- `stow` will automatically ignore some files, such as this README
- A new file added to the `dotfiles` directory won't be symlinked to the home directory until you run `stow .` again
