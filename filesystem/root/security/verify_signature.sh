#!/bin/bash
#
# This script dumps the contents of a certificate - typically a pem file.
#

if [ $# -lt 1 ]; then
  echo Must provide path to p7s file.
  exit
fi

# Ignore the default openssl configuration file
export OPENSSL_CONF=/dev/null

openssl smime -verify -in xml/Governance.p7s -CAfile cert/root-ca-cert.pem
