#!/bin/bash -e

public_key_file="${1}"
public_key_cert="${2}"

public_key_fingerprint=$( ssh-keygen -l -f $public_key_file |awk '{print $2}' | awk -F: '{print $2}' )
public_cert_fingerprint=$( ssh-keygen -l -f $public_key_cert |awk '{print $2}' | awk -F: '{print $2}' )

if [[ $public_key_fingerprint == $public_cert_fingerprint ]]; then
    exit 0
fi
exit 1
