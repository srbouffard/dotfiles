# Dotfiles / Shell Utilities

This repo contains personal shell utilities and helper functions for development.


## Structure

- `bootstrap_dotfiles.sh`  
  One-time script to inject the source line into your `~/.bashrc` to load the dotfiles environment.

- `injection.sh`  
  Central entrypoint sourced by the shell on startup; it loads environment variables, functions, and other customizations.

- `env.sh`  
  Environment variables and exports for development workspaces and tools.

- `functions.sh`  
  Shell functions, aliases, and interactive helpers.

- `multipass-utils.sh`  
  Helper functions and scripts related to Multipass VM management.



## Setup

1. Clone this repo somewhere on your host machine:

    ```bash
        git clone git@github.com:srbouffard/dotfiles.git ~/dotfiles
    ```

2. Run the bootstrap script to inject the source line into your shell config:

   ```
   bash ~/dotfiles/bootstrap_dotfiles.sh
   ```

3. Reload your shell or source your config:

   ```
   source ~/.bashrc
   ```

4. The environment variables, functions, and helpers will now be loaded automatically on new shells.

## Usage

- Add environment variables to `env.sh`.
- Add shell functions and aliases to `functions.sh`.
- Add Multipass related helpers to `multipass-utils.sh` and source it from `functions.sh` or `injection.sh`.
- Modify `injection.sh` if you want to add or reorganize loading behavior.
