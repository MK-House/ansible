#!/bin/bash

if [ -z "$1" ]; then
    LOG_FILE="/tmp/ansible-setup.log"
else
    LOG_FILE="$1"
fi

: > $LOG_FILE
exec > >(tee -i $LOG_FILE)
exec 2>&1

log() {
    echo "$1"
    echo "$1" >> $LOG_FILE
}

log "User executing the script: $(whoami)"

log "Installing dependencies..."
if command -v apt-get >/dev/null; then
    sudo apt-get update && sudo apt-get install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible sshpass
elif command -v yum >/dev/null; then
    sudo yum install -y epel-release
    sudo yum install -y ansible sshpass
else
    log "Unsupported package manager. Please install Ansible and sshpass manually."
    exit 1
fi

log "Verifying Ansible installation..."
if ! command -v ansible >/dev/null; then
    log "Ansible installation failed."
    exit 1
fi

log "Verifying sshpass installation..."
if ! command -v sshpass >/dev/null; then
    log "sshpass installation failed."
    exit 1
fi

log "Ansible and sshpass installation completed successfully"
log "Ansible version: $(ansible --version | head -n 1)"