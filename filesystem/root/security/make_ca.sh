#!/bin/bash
#
# This script creates a certificate authority.  In this case, we will use
# the same CA for signing identities and permissions files, so only one CA
# is created.
# 
# This script need only be run once.  It must be run prior to executing the
# make_permissions.sh script.
#

# Create some directories that will be used
# csr             - for storing certificate signing requests
# root-ca/private - for the root CA private key
# root-ca/db      - for storing information about generated certificates
# root-ca/cert    - the CA keeps a copy of certificates here
# cert            - for storing generated certs and keys
mkdir -p csr root-ca/private root-ca/db root-ca/cert cert

# Create initial database files
touch root-ca/db/ca.db
touch root-ca/db/ca.db.attr
echo 01 > root-ca/db/ca-cert.srl
echo 01 > root-ca/db/ca-crl.srl

# Generate CA key pair and CA root certificate
# By default, the req command generates a certificate signing request
# -nodes  : Don't encrypt the output key
# -x509   : Output an x509 structure instead of a cert request
# -days   : The length the certificate will be valid
# -sha256 : The hash algorithm to use
# -newkey : Create a new key of the specified type
# -keyout : File to send the key to
# -out    : Output file (the certificate)
# -config : Additional configuration options
openssl req \
      -nodes \
      -x509 \
      -days 3650 \
      -sha256 \
      -newkey rsa:2048 \
      -keyout root-ca/private/key.pem \
      -out cert/root-ca-cert.pem \
      -config cnf/openssl-req.cnf

