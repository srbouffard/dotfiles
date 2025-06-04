#!/bin/bash
# multipass-utils.sh
# Helper functions for Multipass VM SSH config and related tasks

update_workspace_ssh_config() {
  cat <<'EOF' > /tmp/__tmp_docstring
Usage:
  update_workspace_ssh_config [--debug|--help]

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

  local CMD="$1"
  if [ "$CMD" = "--help" ]; then
    cat /tmp/__tmp_docstring
    rm /tmp/__tmp_docstring
    return 0
  fi
  rm /tmp/__tmp_docstring

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
