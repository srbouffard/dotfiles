# Dotfiles / Shell Utilities

This repo contains personal shell utilities and helper functions designed to streamline development workflows, particularly for projects involving Multipass virtual machines.

The system is designed to be modular. All features are disabled by default, allowing you to opt-in to the functionality you need without altering the core repository files.

## Prerequisites

Before you begin, ensure you have the following software installed on your system (assuming you want all features enabled):

* **Git**: For cloning the repository.
* **Multipass**: For virtual machine management.
* **fzf**: For the fuzzy finder integration (`Ctrl+T`).
* **Visual Studio Code**: The `code` command-line tool should be installed in your system's PATH.

## Setup

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/srbouffard/dotfiles.git ~/dotfiles
    ```

2.  **Run the bootstrap script**: This will add a line to your `~/.bashrc` file to load the dotfiles environment whenever you open a new shell.
    ```bash
    bash ~/dotfiles/bootstrap_dotfiles.sh
    ```

3.  **Configure your local environment**: Create a `env.local.sh` file to enable the features you want to use. See the **Configuration** section below for details.

4.  **Reload your shell**:
    ```bash
    source ~/.bashrc
    ```

## Configuration

This project separates default settings from user settings. The default configurations, with all features disabled, are in `env.sh`. You should not edit this file directly.

To enable features and set your personal preferences, create a local override file.

1.  **Create the local config file**:
    ```bash
    touch ~/dotfiles/env.local.sh
    ```
    This file is already listed in `.gitignore`, so your local changes will not be tracked by Git.

2.  **Enable features in `env.local.sh`**: Copy the variables for the features you want from `env.sh` into your `env.local.sh` file and change their value to `1`.

**Example `env.local.sh`:**
```bash
# My local environment settings. This file is not tracked by Git.

## Enabled Features
export ENABLE_AUTO_WORKSPACE_ENV=1      # Automatically detect and configure Multipass workspaces
export ENABLE_CUSTOM_PROMPT=1           # Use the custom prompt with git info
export ENABLE_DOTFILES_FZF_CTRL_T=1     # Enable Ctrl-T to search dotfile functions

## Custom Options
export PROMPT_USER_LABEL="dave"         # Set a custom label for the prompt
```

3. Don't forget to reload your shell to take these changes into account
```bash
sourceme
```

## Features

* **Automatic Workspace Configuration**: (Opt-in) When you `cd` into a directory marked with a `.multipass-workspace` file, the environment automatically configures itself by exporting `WORKSPACE_NAME` and `WORKSPACE_IP`.
* **Multipass VM Management**: (Opt-in) A suite of functions to simplify the entire lifecycle of a development VM. See example below.
* **Customizable Prompt**: (Opt-in) Your shell prompt is enhanced to show the current user, working directory, and the active Git branch.
* **Helper Functions & Aliases**: A set of shortcuts for Multipass and Git commands to speed up your workflow.
* **FZF Integration**: (Opt-in) Press `Ctrl+T` to get a fuzzy-searchable list of all custom functions available in your dotfiles.

## Available Aliases and Functions

The following aliases and functions are available once enabled/sourced.

### Git
| Command | Description |
|---|---|
| `gs` | `git status` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gpull`| `git pull` |
| `gpush`| `git push` |
| `gd` | `git diff` |
| `gl` | A much more readable, graphical log of your git history. |
| `gacp "msg"` | Add all files, commit with a message, and push in one command. |

### Multipass
| Command | Description |
|---|---|
| `mps` | `multipass shell ${WORKSPACE_NAME}` |
| `mpi` | `multipass info ${WORKSPACE_NAME}` |
| `mpe` | `multipass_setup_envs()` |
| `multipass_create_dev_vm` | Creates and sets up a new development VM for the current project. |
| `multipass_update_ssh_config` | Updates your SSH config to easily connect to the project VM. |
| `multipass_open_vscode` | Opens the project folder in VS Code via Remote-SSH. |

### Navigation & System
| Command | Description |
|---|---|
| `ll` | `ls -alF` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `sourceme` | Reloads your shell configuration by running `source ~/.bashrc`. |


## Example Workflow: From Zero to VS Code

Here is a step-by-step guide to setting up a new project. This example assumes you have enabled `ENABLE_AUTO_WORKSPACE_ENV` in your `env.local.sh` file.

1.  **Create Your Project Directory**
    Create a folder for your new project and navigate into it.
    ```bash
    mkdir my-new-project && cd my-new-project
    ```

2.  **Mark as a Multipass Workspace**
    Run the following command to create a `.multipass-workspace` marker file. This allows the scripts to automatically identify this as a Multipass-enabled project.
    ```bash
    mark_as_multipass_workspace
    ```
    After creating the marker, `cd` out of the directory and back in to trigger the automatic environment setup.

3.  **Create the Development VM**
    This command will launch a new Multipass instance, name it after your project directory, mount your code, and authorize your SSH key.
    ```bash
    multipass_create_dev_vm
    ```

4.  **Configure SSH**
    This command updates your local `~/.ssh/config` file, allowing SSH clients and VS Code to find and connect to your new VM easily.
    ```bash
    multipass_update_ssh_config
    ```

5.  **Open in VS Code**
    You're all set. Run the following command to open your project folder in VS Code, connected directly to the development environment inside your VM.
    ```bash
    multipass_open_vscode
    ```