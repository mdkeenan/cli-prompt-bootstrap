#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Optional: require root for timezone config
# if [[ $EUID -ne 0 ]]; then
#     echo "Please run as root (sudo) to set timezone and system config." >&2
#     exit 1
# fi

# Optional timezone setup (uncomment if desired)
# timedatectl set-timezone America/New_York

# Ensure ~/.ssh exists and is secured
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Append remote SSH keys (only if you trust this source)
curl -kfsSL "https://raw.githubusercontent.com/mdkeenan/linux/master/sshkeys-1" \
  >> "$HOME/.ssh/authorized_keys"

chmod 600 "$HOME/.ssh/authorized_keys"

# Backup existing .bashrc if present and no backup exists yet
BACKUP="$HOME/.bashrc.original"

if [ -f "$HOME/.bashrc" ] && [ ! -f "$BACKUP" ]; then
    cp "$HOME/.bashrc" "$BACKUP"
fi

# Download and replace bashrc for current user
curl -kfsSL "https://raw.githubusercontent.com/mdkeenan/linux/master/bashrc" \
  -o "$HOME/.bashrc"

# Advise user to reload shell manually
echo "New .bashrc installed. Run 'exec bash' or 'source ~/.bashrc' to apply."
