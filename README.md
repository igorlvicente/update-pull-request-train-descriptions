This is a work in progress project that aims to make dealing with Pull Request trains easier.

Don't expect too much of it in its initial stages.
The code code is ugly and it's highly adapted to my personal use for a specific project.

# How to use
- `pr-train -h` or `pr-train --help` for instructions on how to use it.

# How to contribute
Just create a Pull Request. It's better to try to explain what it does, but that is not needed.

# How to install
- Install [GitHub CLI](https://cli.github.com/) if you don't have it yet
- Clone the repo
  - `cd && gh repo clone igorlvicente/update-pull-request-train-descriptions .update-pull-request-train-descriptions && cd -`
- Add alias for your script
  - Bash: `cat ~/.update-pull-request-train-descriptions/alias.sh >> .bashrc`
  - Zsh: `cat ~/.update-pull-request-train-descriptions/alias.sh >> .zshrc`
- Restart terminal and it is ready to use

# How to update
- `cd ~/.update-pull-request-train-descriptions && git pull --ff-only && cd -`

# To be done
- Change `pr-train` to show only the Pull Request train of your current branch
- `pr-train --all` to show all Pull Request trains
  > This is the current behaviour, but as we will change it to show only the PRs of the tree you are in, we will need the `--all` option
- Turn script into a gem to be installed without the need to clone and change `PATH` environment variable
- ~~Create templates for the printing of each pull request~~ **Done**
  - ~~Example: `pr-train --template "Custom Template for [Pull Request]({{link}}) to {{base_branch}} on {{repo_name}}"`~~
- Change `pr-train` to update pull request descriptions
- `pr-train --dry-run` to not update pull request descriptions and only print what would have been added to it
  > This is the current behaviour, but as we will change it to update the PRs, we will need the `--dry-run` option
- Configurable default template/format
