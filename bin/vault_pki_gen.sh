#!/bin/bash

TLDNAME="tacos.local"
INTPKI="intpki"
ROOTPKI="rootpki"
ROOTTTL="175200h"

## Create Root CA, CA Certificate & CA Key

vault mount -path="${ROOTPKI}" \
-description="Example Dot Com Root CA" \
-max-lease-ttl=175200h pki

vault write "${ROOTPKI}"/root/generate/exported \
common_name="${TLDNAME}" ttl="${ROOTTTL}"

vault write "${ROOTPKI}"/root/generate/internal \
common_name="${TLDNAME}" ttl="${ROOTTTL}"

## Configure URLs for Vault CA and CRL Access

vault write "${ROOTPKI}"/config/urls \
issuing_certificates="http://10.1.42.101:8200/v1/${ROOTPKI}"

## Create Intermediate CA, CA Certificate & CA Key

vault mount -path=${INTPKI} -description="Example Dot Com Intermediate CA" \
-max-lease-ttl=17520h pki

## Create Intermediate CSR

vault write ${INTPKI}/intermediate/generate/internal \
common_name="Example Dot Com Intermediate CA" \
ttl=17520h \
key_bits=4096 \
exclude_cn_from_sans=true

## Save the certificate request as `example_dot_com.csr` for the next step,
## which is signing the CSR with the root CA.

## Sign CSR with Root CA

vault write "${ROOTPKI}"/root/sign-intermediate \
csr=@example_dot_com.csr \
common_name="Example Dot Com Intermediate CA" \
ttl=8760h

## Save the Root CA signed certificate (the value of `certificate`)  as
## `example_dot_com.crt` so that it can be imported into the Intermediate
## CA backend.

## Import Signed Certificate into Intermediate CA

vault write ${INTPKI}/intermediate/set-signed certificate=@example_dot_com.crt

## Configure URLs for Vault CA and CRL Access

vault write "${ROOTPKI}"/config/urls \
issuing_certificates="http://10.1.42.101:8200/v1/${ROOTPKI}"

vault write ${INTPKI}/config/urls \
issuing_certificates="http://10.1.42.101:8200/v1/${INTPKI}/ca" \
crl_distribution_points="http://10.1.42.101:8200/v1/${INTPKI}/crl"

## Create a Role

# The final step is to create a role to define the attributes associated with
# the generated certificates. This includes attributes such as certificate
# type, key type, and so on.

# This example `www` role defines 2048 bit keys and 1 year TTLs for only
# subdomains of `"${TLDNAME}"`:

vault write ${INTPKI}/roles/www key_bits=2048 max_ttl=8760h \
allowed_domains="${TLDNAME}" allow_subdomains=true

# Provided everything was successful, you're now ready to request a
# certificate from the Intermediate CA!

vault write ${INTPKI}/issue/www common_name="tacos.${TLDNAME}" \
ip_sans="10.1.74.100" ttl=1080h format=pem

## Resources

## 1. [PKI Secret Backend documentation](https://www.vaultproject.io/docs/secrets/pki/index.html)
