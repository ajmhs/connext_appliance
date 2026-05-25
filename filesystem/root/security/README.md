# DDS Secure Artifacts README

## License

Copyright (c) 2026 Real-Time Innovations, Inc. (RTI). All rights reserved.

RTI grants Licensee a license to use, modify, compile, and create derivative
works of the software solely for use with RTI Connext DDS. Licensee may
redistribute copies of the software provided that all such copies are subject
to this license. The software is provided "as is", with no warranty of any
type, including any warranty for fitness for any purpose. RTI is under no
obligation to maintain or support the software. RTI shall not be liable for
any incidental or consequential damages arising out of the use or inability
to use the software.

## Overview

This folder contains example scripts and configuration files for enabling
DDS Secure.

## Prerequisites

- RTI Connext DDS 5.3.0 or later.
- Corresponding RTI Connext DDS Security Plugins installation:
  - Host installation
  - Target installation (if building your own applications)
- OpenSSL version appropriate for your Connext version:
  - 5.3.0: 1.0.2j
  - 5.3.1: 1.0.2n
  - 6.0.0: 1.0.2o
  - 6.0.1: 1.1.1d

## Generate Security Artifacts

Run the following scripts in order.

### RSA cryptography

1. make_ca.sh: sets up a CA.
2. make_certificates.sh: creates two identity certificates and corresponding keys.
3. make_governance_and_perms.sh: signs the governance and permissions files.

### ECDSA cryptography

1. make_ca_ecdsa.sh: sets up a CA.
2. make_certificates_ecdsa.sh: creates two identity certificates and corresponding keys.
3. make_governance_and_perms.sh: signs the governance and permissions files.

## Using with Shapes Demo

The created artifacts can be used to run experiments with Shapes Demo using
different security configurations.

1. Start Shapes Demo in this directory (the directory containing ShapesSecurityQos.xml).
2. Open the configuration link in Shapes Demo and stop the participant.
3. Add ShapesSecurityQos.xml (or ShapesSecurityQos.53x.xml for 5.3.x).
4. Change the domain to 10.
5. Disable distributed logger.
6. Select one of the security profiles.
7. Restart the participant.

## Regenerating Signed Files

If governance or permissions files are changed, regenerate signed files by
rerunning make_governance_and_perms.sh.

## Note for 5.3.x

Not all governance settings are supported in 5.3.x. Some security profiles
may not work as expected.
