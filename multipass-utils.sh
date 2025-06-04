#!/bin/bash
# multipass-utils.sh
# Helper functions for Multipass VM SSH config and related tasks

export WORKSPACE_SSH_KEY_NAME=multipass_vm_key

multipass_setup_envs() {
    export HOST_WORKSPACE_LOCATION="$PWD"
    export WORKSPACE_NAME="$(basename "$PWD")"

    local ip
    ip=$(multipass info "$WORKSPACE_NAME" 2>/dev/null | awk '/IPv4/ {print $2; exit}')
    if [[ -n "$ip" ]]; then
        export WORKSPACE_IP="$ip"
        echo "Set WORKSPACE_IP=$WORKSPACE_IP"
    else
        echo "WARNING: Could not find IP for Multipass instance '$WORKSPACE_NAME'. Ignore if multipass instance not created yet."
    fi

    echo "Set HOST_WORKSPACE_LOCATION=$HOST_WORKSPACE_LOCATION"
    echo "Set WORKSPACE_NAME=$WORKSPACE_NAME"
}

multipass_update_ssh_config() {
  local help_msg=$(cat <<'EOF'
Usage:
  multipass_update_ssh_config [--debug|--help]

Description:
  Updates (or creates) the SSH config entry for the Multipass VM defined by
  the environment variables:
    - WORKSPACE_NAME       : Multipass VM name (required)
    - WORKSPACE_SSH_KEY_NAME : SSH private key filename in ~/.ssh/ (required)
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
  local SSH_KEY_PATH="$HOME/.ssh/${WORKSPACE_SSH_KEY_NAME:?WORKSPACE_SSH_KEY_NAME not set}"
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
    WORKSPACE_SSH_KEY_NAME  SSH private key filename under ~/.ssh/ (default: id_ed25519)
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
    echo "Missing config entry for $WORKSPACE_NAME...make sure to run multipass_update_ssh_config()"
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
  multipass launch --cpus 4 --memory 8G --disk 50G --name "$WORKSPACE_NAME" charm-dev || return 1

  echo "Stopping instance '$WORKSPACE_NAME' to setup mount..."
  multipass stop "$WORKSPACE_NAME" || return 1

  echo "Mounting host workspace $HOST_WORKSPACE_LOCATION to /home/ubuntu/$WORKSPACE_NAME in VM..."
  multipass mount --type native "$WORKSPACE_LOCATION" "$HOST_WORKSPACE_LOCATION:/home/ubuntu/$WORKSPACE_NAME" || return 1

  echo "Starting instance '$WORKSPACE_NAME'..."
  multipass start "$WORKSPACE_NAME" || return 1

  echo "Multipass instance '$WORKSPACE_NAME' is ready."
}
