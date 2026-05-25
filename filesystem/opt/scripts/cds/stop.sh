#!/bin/bash
echo "This script should not be executed directly, instead use systemd:"
echo "     systemctl status rticlouddiscovery.service"
echo "     systemctl start rticlouddiscovery.service"
echo "     systemctl stop rticlouddiscovery.service"
echo ""

if pgrep -f rticlouddiscoveryserviceapp > /dev/null; then
    pkill -f rticlouddiscoveryserviceapp
    sleep 1
    if pgrep -f rticlouddiscoveryserviceapp > /dev/null; then
        echo "Failed to stop rticlouddiscoveryserviceapp"
    else
        echo "Successfully stopped rticlouddiscoveryserviceapp"
    fi
else
    echo "rticlouddiscoveryserviceapp not running"
fi
