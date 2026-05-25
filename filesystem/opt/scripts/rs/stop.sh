#!/bin/bash
echo "This script should not be executed directly, instead use systemd:"
echo "     systemctl status rtirouting.service"
echo "     systemctl start rtirouting.service"
echo "     systemctl stop rtirouting.service"
echo ""

if pgrep -f rtiroutingserviceapp > /dev/null; then
    pkill -f rtiroutingserviceapp
    sleep 1
    if pgrep -f rtiroutingserviceapp > /dev/null; then
        echo "Failed to stop rtiroutingserviceapp"
    else
        echo "Successfully stopped rtiroutingserviceapp"
    fi
else
    echo "rtiroutingserviceapp not running"
fi
