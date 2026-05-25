#!/bin/bash
#
# This script creates cryptographic identities and certificates.
#
# Note that this script generates new identities every time it is run. In
# reality, these files need only be generated once.
#
# Before executing this script, first run make_ca.sh, if not already done.
#

# Generate App A key pair and signing request (CSR)
# By default, the req command generates a certificate signing request
# -nodes  : Don't encrypt the output key
# -new    : New request
# -newkey : Create a new key of the specified type
# -keyout : File to send the key to
# -out    : Output file (the CSR)
# -config : Additional configuration options
openssl req \
      -nodes \
      -new \
      -newkey rsa:2048 \
      -keyout cert/a-key.pem \
      -out csr/a-csr.pem \
      -config cnf/a.cnf

# Sign the A identity
# -in     : The CSR (created by the req command)
# -out    : Output file (the certificate)
# -days   : The length the certificate will be valid
# -notext : Do not include certificate text in the certificate
# -batch  : Don't ask for confirmation
# -config : Additional configuration options
openssl ca \
      -in csr/a-csr.pem \
      -out cert/a-cert.pem \
      -days 3650 \
      -notext \
      -batch \
      -config cnf/openssl-req.cnf

# Generate App B key pair and signing request (CSR)
openssl req \
      -nodes \
      -new \
      -newkey rsa:2048 \
      -keyout cert/b-key.pem \
      -out csr/b-csr.pem \
      -config cnf/b.cnf

# Sign the B identity
openssl ca \
      -in csr/b-csr.pem \
      -out cert/b-cert.pem \
      -days 3650 \
      -notext \
      -batch \
      -config cnf/openssl-req.cnf

