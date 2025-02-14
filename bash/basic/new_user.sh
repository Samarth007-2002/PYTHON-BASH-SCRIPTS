#!/bin/bash

if [[ $EUID -ne 0 ]]; then
        echo "Run as Root"
        exit 1
fi

if [[ -z "$1"]]; then
        echo "Usage: $0 <username>"
fi

USERNAME=$1
HOME_DIR="/home/$USERNAME"
PASSWORD="default123"

useradd -m -d "$HOME_DIR" "$USERNAME"

chmod 750 "$HOME_DIR"
chown "$USERNAME":"$USERNAME" "$HOME_DIR"

echo "$USERNAME:$PASSWORD" | chpasswd

echo "User $USERNAME created"
