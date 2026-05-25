#!/bin/bash
#
# This script signs the governance and permissions files.
#
# Before executing this script, first run make_ca.sh and make_permissions.sh,
# if not already done.
#

# Ignore the default openssl configuration file
export OPENSSL_CONF=/dev/null

# Sign the governance and permissions file(s)
# The smime command can encrypt, decrypt, sign and verify S/MIME messages.
# -sign  : Sign the file
# -in    : The file to sign
# -out   : The resulting signed file
# -signer : Signer certificate file
# -inkey  : Private key to use for signing
acfiles=$(find xml -name "*.xml")
for acf in $acfiles; do
  openssl smime \
        -sign \
        -in $acf \
        -out ${acf%%.*}.p7s \
        -signer cert/root-ca-cert.pem \
        -inkey root-ca/private/key.pem
done

