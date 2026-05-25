#!/bin/bash
echo "This script should not be executed directly, instead use systemd:"
echo "     systemctl status rticlouddiscovery.service"
echo "     systemctl start rticlouddiscovery.service"
echo "     systemctl stop rticlouddiscovery.service"
echo ""

if pgrep -f rticlouddiscoveryserviceapp > /dev/null; then
     echo "It looks like rticlouddiscoveryserviceapp is already running, try killing it first"
     echo "Likely process IDs:`pgrep -f rticlouddiscoveryserviceapp`"
     exit
fi

echo "Starting $EXEC"
/usr/local/bin/connext/rticlouddiscoveryserviceapp -cfgFile /opt/scripts/cds/cds.xml -cfgName CDS &
