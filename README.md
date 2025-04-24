# dotfiles

These are my dotfiles.
There are many like them, but these ones are mine.

**WARNING**:
I may, without prior notice, forcefully overwrite the history of this repo.

## Using git to manage dotfiles in the home directory

This repo has a simple script to set up your home directory as a git repo.
It will **_not_** overwrite existing files.
Change it as needed: [.dotfile_misc/bin/dotfiles-bootstrap.sh](.dotfile_misc/bin/dotfiles-bootstrap.sh)

This repo does not track regular shell rc files.
For example, it ignores `.zshrc`, `.bashrc`, `.profile`, and cousins.
Instead, it tracks files like `.zshrc_global.sh`.
The `dotfiles-bootstrap.sh` script above causes files like `.zshrc`
to source the corresponding global overrides like the `.zshrc_global.sh` file.

Thus local overrides or fallbacks can easily be added in the regular rc files.
This is useful since some tool installations modify the default shell rc files.
