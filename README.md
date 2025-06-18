Of course. Here is a comprehensive README file for your project, explaining its features, setup, and usage examples.

# Dotfiles / Shell Utilities

This repo contains personal shell utilities and helper functions designed to streamline development workflows, particularly for projects involving Multipass virtual machines.

## Features

  - **Automatic Workspace Configuration**: When you `cd` into a directory marked as a Multipass workspace, the environment automatically configures itself, exporting necessary variables like `WORKSPACE_NAME` and `WORKSPACE_IP`.
  - **Multipass VM Management**: A suite of functions to simplify the entire lifecycle of a development VM:
      - `multipass_create_dev_vm`: Creates a new Ubuntu VM with predefined resources, mounts your project directory, and gets it ready for development.
      - `multipass_update_ssh_config`: Automatically adds or updates the SSH configuration for your VM, making it easy to connect.
      - `multipass_open_vscode`: Opens your project directly in VS Code via a remote SSH connection to the Multipass VM.
  - **Customizable Prompt**: Your shell prompt is enhanced to show the current user, working directory, and the active Git branch. You can customize the user label.
  - **Helper Functions & Aliases**: Includes common aliases (`ll`, `gs`) and a set of shortcuts for Multipass commands (`mps`, `mpi`, `mpe`) to speed up your workflow.
  - **FZF Integration**: Press `Ctrl+T` to get a fuzzy-searchable list of all custom functions available in your dotfiles for quick access.

## Prerequisites

Before you begin, ensure you have the following software installed on your system:

  * **Git**: For cloning the repository.
  * **Multipass**: For virtual machine management. You can find installation instructions on the official [Multipass website](https://multipass.run/install).
  * **fzf**: For the fuzzy finder integration. It can be installed with package managers like Homebrew or `apt`:
      * **macOS**: `brew install fzf`
      * **Debian/Ubuntu**: `sudo apt install fzf`
  * **Visual Studio Code**: Required for the `multipass_open_vscode` function. The `code` command-line tool must be installed in your system's PATH. You can enable this from within VS Code by opening the Command Palette (`Ctrl+Shift+P`), typing `Shell Command: Install 'code' command in PATH`, and pressing Enter.

## Setup

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/srbouffard/dotfiles.git ~/dotfiles
    ```

2.  **Run the bootstrap script**: This will add a line to your `~/.bashrc` file to load the dotfiles environment whenever you open a new shell.

    ```bash
    bash ~/dotfiles/bootstrap_dotfiles.sh
    ```

3.  **Reload your shell**:

    ```bash
    source ~/.bashrc
    ```

Your shell is now equipped with the new functions and features.

## Usage Workflow Example

Here’s a typical workflow for starting a new project using these utilities:

1.  **Create your project directory and navigate into it**:

    ```bash
    mkdir my-new-project
    cd my-new-project
    ```

2.  **Mark it as a Multipass workspace**: This creates a `.multipass-workspace` file that the scripts use to detect the project type.

    ```bash
    mark_as_multipass_workspace
    ```

3.  **Set up the environment**: The environment should configure automatically when you enter the directory. If not, you can trigger it manually. This will set the `WORKSPACE_NAME` and other variables based on the directory name.

    ```bash
    multipass_setup_envs
    ```

4.  **Create the development VM**: This command will launch and configure a new Multipass instance for your project.

    ```bash
    multipass_create_dev_vm
    ```

5.  **Configure SSH**: This step updates your SSH config file so you can connect to the VM easily.

    ```bash
    multipass_update_ssh_config
    ```

6.  **Connect and Develop**: You can now shell into your VM or open the project in VS Code.

    ```bash
    # Shell into the VM
    mps

    # Or open the project directly in VS Code
    multipass_open_vscode
    ```

## Customization

You can easily customize these dotfiles:

  * **Toggle Features**: Edit the `env.sh` file to enable or disable features like the FZF integration or the automatic workspace setup. You can also change your `PROMPT_USER_LABEL` here.
  * **Add Your Own Tools**:
      * Add new shell functions and aliases to `functions.sh`.
      * Add Multipass-specific helpers to `multipass-utils.sh`.

## File Overview

  * `bootstrap_dotfiles.sh`: One-time setup script that injects the source command into `~/.bashrc`.
  * `injection.sh`: The main entrypoint that sources all other scripts to set up the environment.
  * `env.sh`: Contains environment variables for feature flags and customizations.
  * `dependencies.sh`: Ensures dependencies like `fzf` are loaded correctly.
  * `functions.sh`: A place for general-purpose aliases and custom functions.
  * `core-utils.sh`: Core helper functions, including the FZF function list generator.
  * `multipass-utils.sh`: A collection of powerful functions for managing Multipass VMs.
  * `prompt.sh`: Defines the custom shell prompt's appearance and behavior.
  * `.gitignore`: Standard file for ignoring temporary and local files in Git.