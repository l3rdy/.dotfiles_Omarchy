#!/bin/bash

VM="Tiny11"

# Query the VM state and trim whitespace
STATE=$(virsh domstate "$VM" 2>/dev/null | tr -d '[:space:]')

# If not running, try to start it
if [[ "$STATE" != "running" ]]; then
    echo "Starting $VM..."
    if ! virsh start "$VM" ; then
        echo "VM was already running or could not be started."
    fi
else
    echo "$VM is already running."
fi

# Open console in virt-manager
virt-manager --connect qemu:///session --show-domain-console "$VM"
