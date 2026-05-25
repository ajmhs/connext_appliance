#!/bin/bash
echo "This script should not be executed directly, instead use systemd:"
echo "     systemctl status rtirouting.service"
echo "     systemctl start rtirouting.service"
echo "     systemctl stop rtirouting.service"
echo ""

if pgrep -f rtiroutingserviceapp > /dev/null; then
     echo "It looks like rtiroutingserviceapp is already running, try killing it first"
     echo "Likely process IDs:`pgrep -f rtiroutingserviceapp`"
     exit
fi

echo "Starting $EXEC"
/usr/local/bin/connext/rtiroutingserviceapp -cfgFile /opt/scripts/rs/rs.xml -cfgName RoutingService &
