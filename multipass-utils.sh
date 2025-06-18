#!/bin/bash
# multipass-utils.sh
# Helper functions for Multipass VM SSH config and related tasks

export MULTIPASS_WORKSPACE_SSH_KEY_NAME="multipass_vm_key"
export MULTIPASS_WORKSPACE_MARKER=".multipass-workspace"

alias mps='multipass shell ${WORKSPACE_NAME}'
alias mpi='multipass info ${WORKSPACE_NAME}'
alias mpe='multipass_setup_envs()'

mark_as_multipass_workspace() {
  # Mark the current directory as a Multipass workspace by creating the marker file.
  # Suggests adding the marker to the project's .gitignore.

  local marker="${MULTIPASS_WORKSPACE_MARKER:-.multipass-workspace}"
  touch "$marker"
  echo "✔️ Marked as Multipass workspace with '$MULTIPASS_WORKSPACE_MARKER'"

  if [ -d .git ]; then
    if ! grep -q "$marker" .gitignore 2>/dev/null; then
      echo "💡 Tip: add '$MULTIPASS_WORKSPACE_MARKER' to your GLOBAL .gitignore"
    fi
  fi
}

multipass_setup_envs() {
  # multipass_setup_envs - Export workspace-related env vars based on current directory.
  #   Sets HOST_WORKSPACE_LOCATION, WORKSPACE_NAME, and optionally WORKSPACE_IP.

  local cwd_basename
  cwd_basename="$(basename "$PWD")"
  
  if [[ "$WORKSPACE_NAME" == "$cwd_basename" && "$HOST_WORKSPACE_LOCATION" == "$PWD" ]]; then
    return 0  # Already set, no need to re-export or print
  fi

  export HOST_WORKSPACE_LOCATION="$PWD"
  export WORKSPACE_NAME="$(basename "$PWD")"

  local ip
  ip=$(multipass info "$WORKSPACE_NAME" 2>/dev/null | awk '/IPv4/ {print $2; exit}')
  if [[ -n "$ip" ]]; then
      export WORKSPACE_IP="$ip"
  else
      echo "WARNING: Could not find IP for Multipass instance '$WORKSPACE_NAME'. Ignore if multipass instance not created yet."
  fi

  echo "🌐 Environment variables configured: WORKSPACE_NAME='$WORKSPACE_NAME', IP='$WORKSPACE_IP'"
}

_auto_multipass_env_setup() {
  # Automatically call multipass_setup_envs if the current directory contains the marker.

  if [[ -f "${MULTIPASS_WORKSPACE_MARKER:-.multipass-workspace}" && -z "$_MULTIPASS_ENV_ALREADY_CONFIGURED" ]]; then
    echo "🔧 Detected Multipass workspace. Peforming environment config..."
    multipass_setup_envs
    export _MULTIPASS_ENV_ALREADY_CONFIGURED=1
  fi
}

## Enable to auto workspace env configuration if enabled by `ENABLE_AUTO_WORKSPACE_ENV`
if [[ "$ENABLE_AUTO_WORKSPACE_ENV" == "1" ]]; then
  PROMPT_COMMAND="_auto_multipass_env_setup${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi

multipass_update_ssh_config() {
  local help_msg=$(cat <<'EOF'
Usage:
  multipass_update_ssh_config [--debug|--help]

Description:
  Updates (or creates) the SSH config entry for the Multipass VM defined by
  the environment variables:
    - WORKSPACE_NAME       : Multipass VM name (required)
    - MULTIPASS_WORKSPACE_SSH_KEY_NAME : SSH private key filename in ~/.ssh/ (required)
    - WORKSPACE_IP         : IP address of the VM (optional; auto-detected)

Options:
  --debug   : Show the SSH config changes that would be applied without modifying the config file.
  --help    : Display this help message.

Behavior:
  - Removes any existing SSH config block for the VM to avoid duplicates.
  - Adds a fresh SSH config block with User 'ubuntu', IdentityFile set to your SSH key,
    and disables strict host key checking for easier development usage.
  - If WORKSPACE_IP is not set, attempts to retrieve it automatically using `multipass info`.
EOF
)

  # Help
  if [[ "$1" == "--help" ]]; then
    echo "$help_msg"
    return 0
  fi

  local DEBUG=0
  if [ "$CMD" = "--debug" ]; then
    DEBUG=1
  fi

  local VM_NAME="${WORKSPACE_NAME:?WORKSPACE_NAME not set}"
  local SSH_KEY_PATH="$HOME/.ssh/${MULTIPASS_WORKSPACE_SSH_KEY_NAME:?MULTIPASS_WORKSPACE_SSH_KEY_NAME not set}"
  local SSH_CONFIG="$HOME/.ssh/config"

  if [ -z "$WORKSPACE_IP" ]; then
    WORKSPACE_IP=$(multipass info "$VM_NAME" | awk '/IPv4/ { print $2 }')
    if [ -z "$WORKSPACE_IP" ]; then
      echo "❌ Could not determine IP for VM '$VM_NAME'. Is it running?"
      return 1
    fi
    export WORKSPACE_IP
  fi

  echo "ℹ️  Preparing SSH config update for '$VM_NAME' → $WORKSPACE_IP"

  awk -v host="$VM_NAME" '
    BEGIN {found=0}
    $1 == "Host" && $2 == host {found=1; next}
    found && $1 == "Host" {found=0}
    !found {print}
  ' "$SSH_CONFIG" 2>/dev/null > "$SSH_CONFIG.tmp" || touch "$SSH_CONFIG.tmp"

  cat <<EOF >> "$SSH_CONFIG.tmp"

Host $VM_NAME
  HostName $WORKSPACE_IP
  User ubuntu
  IdentityFile $SSH_KEY_PATH
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF

  if [ $DEBUG -eq 1 ]; then
    echo "---- DEBUG MODE: Preview of updated SSH config ----"
    cat "$SSH_CONFIG.tmp"
    echo "---- End of preview. No changes applied. ----"
    rm "$SSH_CONFIG.tmp"
    return 0
  fi

  # Backup the original config file before overwriting
  if [ -f "$SSH_CONFIG" ]; then
      cp "$SSH_CONFIG" "$SSH_CONFIG.bak"
      echo "ℹ️  Backed up existing SSH config to $SSH_CONFIG.bak"
  fi

  mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"

  echo "✅ SSH config updated for '$VM_NAME'"
}

multipass_open_vscode() {
  local help_msg=$(cat <<'EOF'
  multipass_open_vscode - open VSCode Remote SSH session to a Multipass instance

  Usage:
    multipass_open_vscode [--debug] [project_path]
  
  Description:
    Opens a VSCode Remote SSH session targeting the Multipass instance
    specified by the environment variables WORKSPACE_NAME and WORKSPACE_IP.
    Automatically adds an SSH config entry if needed.

  Arguments:
    --debug       Print the VSCode command instead of running it
    project_path  Optional. Path inside the VM to open in VSCode.
                  Defaults to /home/ubuntu/$WORKSPACE_NAME

  Environment variables:
    WORKSPACE_NAME          Multipass instance name and SSH config Host
    WORKSPACE_IP            IP address of the Multipass instance
    MULTIPASS_WORKSPACE_SSH_KEY_NAME  SSH private key filename under ~/.ssh/ (default: id_ed25519)
EOF
)

  local project_path=""
  local debug=false

  # Help
  if [[ "$1" == "--help" ]]; then
    echo "$help_msg"
    return 0
  fi

  # Parse debug flag
  if [[ "$1" == "--debug" ]]; then
    debug=true
    project_path="$2"
  else
    project_path="$1"
  fi

  # Validate required vars
  if [[ -z "$WORKSPACE_NAME" || -z "$WORKSPACE_IP" ]]; then
    echo "ERROR: WORKSPACE_NAME and WORKSPACE_IP must be set."
    return 1
  fi

  # Default project path
  project_path="${project_path:-/home/ubuntu/$WORKSPACE_NAME}"

  # Ensure SSH config exists
  if ! grep -q "^Host $WORKSPACE_NAME\$" ~/.ssh/config 2>/dev/null; then
      echo "🔍 SSH config entry for '$WORKSPACE_NAME' is missing."
      read -p "Would you like to run 'multipass_update_ssh_config' now? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
          multipass_update_ssh_config
      else
          echo "Please run 'multipass_update_ssh_config' manually before proceeding."
          return 1
      fi
  fi

  # VSCode remote command
  local vscode_cmd="code --remote ssh-remote+$WORKSPACE_NAME $project_path"

  if $debug; then
    echo "[debug] Command to run:"
    echo "  $vscode_cmd"
  else
    eval "$vscode_cmd"
  fi
}

multipass_create_dev_vm() {
  local help_msg=$(cat <<'EOF'
multipass_create_dev_vm - create and setup a Multipass dev VM for the current project

Usage:
  multipass_create_dev_vm [--help]

Description:
  Launches a Multipass instance named by $WORKSPACE_NAME with fixed resources,
  stops it, mounts the host workspace at $HOST_WORKSPACE_LOCATION into
  /home/ubuntu/$WORKSPACE_NAME inside the VM, then restarts the instance.

Requirements:
  - $HOST_WORKSPACE_LOCATION: full path to your local project directory
  - $WORKSPACE_NAME: name for the Multipass instance (usually project folder name)

Example:
  export HOST_WORKSPACE_LOCATION="$PWD"
  export WORKSPACE_NAME=$(basename "$PWD")
  multipass_create_dev_vm
EOF
)

  if [[ "$1" == "--help" ]]; then
    echo "$help_msg"
    return 0
  fi

  if [[ -z "$HOST_WORKSPACE_LOCATION" || -z "$WORKSPACE_NAME" ]]; then
    echo "ERROR: Please set HOST_WORKSPACE_LOCATION and WORKSPACE_NAME before running this. Run command multipass_setup_envs()"
    return 1
  fi

  echo "Launching Multipass instance '$WORKSPACE_NAME'..."
  multipass launch 24.04 \
  --name "$WORKSPACE_NAME" \
  --cpus 4 \
  --memory 8G \
  --disk 50G \
  --timeout 1800 \
  -vvvv \
  --cloud-init https://raw.githubusercontent.com/canonical/multipass/refs/heads/main/data/cloud-init-yaml/cloud-init-charm-dev.yaml \
  || return 1

  # blueprints are depricated
  # multipass launch -vvvv --cpus 4 --memory 8G --disk 50G --name "$WORKSPACE_NAME" charm-dev || return 1

  echo "Stopping instance '$WORKSPACE_NAME' to setup mount..."
  multipass stop "$WORKSPACE_NAME" || return 1

  echo "Mounting host workspace $HOST_WORKSPACE_LOCATION to /home/ubuntu/$WORKSPACE_NAME in VM..."
  multipass mount --type native "$HOST_WORKSPACE_LOCATION" "$WORKSPACE_NAME:/home/ubuntu/$WORKSPACE_NAME" || return 1

  echo "Starting instance '$WORKSPACE_NAME'..."
  multipass start "$WORKSPACE_NAME" || return 1

  echo "Authorizing SSH key..."
  _multipass_authorize_ssh_key || return 1

  echo "Multipass instance '$WORKSPACE_NAME' is ready."
  multipass info $WORKSPACE_NAME
}

_multipass_authorize_ssh_key() {
  local help_msg=$(cat <<'EOF'
multipass_authorize_ssh_key - authorize SSH key in a Multipass VM

Usage:
  _multipass_authorize_ssh_key

Description:
  Copies the public key corresponding to MULTIPASS_WORKSPACE_SSH_KEY_NAME
  into the authorized_keys of the WORKSPACE_NAME VM.
EOF
)

  if [[ "$1" == "--help" ]]; then
    echo "$help_msg"
    return 0
  fi

  local pub_key_path="$HOME/.ssh/${MULTIPASS_WORKSPACE_SSH_KEY_NAME:-id_ed25519}.pub"

  if [[ -z "$WORKSPACE_NAME" ]]; then
    echo "ERROR: WORKSPACE_NAME is not set"
    return 1
  fi

  if [[ ! -f "$pub_key_path" ]]; then
    echo "ERROR: Public key not found at $pub_key_path"
    return 1
  fi

  echo "Authorizing SSH key in instance '$WORKSPACE_NAME'..."

  cat "$pub_key_path" | multipass exec "$WORKSPACE_NAME" -- tee -a /home/ubuntu/.ssh/authorized_keys > /dev/null
}
