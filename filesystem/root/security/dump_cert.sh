#!/bin/bash
#
# This script dumps the contents of a certificate - typically a pem file.
#

if [ $# -lt 1 ]; then
  echo Must provide path to pem file.
  exit
fi

# Ignore the default openssl configuration file
export OPENSSL_CONF=/dev/null

openssl x509 -in $1 -text
