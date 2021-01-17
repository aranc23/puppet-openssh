# openssh

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with openssh](#setup)
    * [What openssh affects](#what-openssh-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with openssh](#beginning-with-openssh)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will install openssh server and client packages,
optionally configure the server and client, and start the service.

The server and client are configured by passing ssh_config and
sshd_config resources as defined by the
herculesteam/augeasproviders_ssh module to the class parameters of the
same name.

The module can optionally configure the following elements of a
typical openssh install as well:

* ssh_known_hosts
* authorized_keys
* host key pairs
* signed ssh host certs (ie: /etc/ssh/ssh_host_ecdsa-cert.pub)

## Setup

### What openssh affects

Without additional class parameters passed to the main class this module
will only install and start the service and clients.  Since the module
uses augeas to configure sshd_config and ssh_config it will not
completely replace an existing sshd_config or ssh_config file.

If the module is used to manage the ssh_known_hosts file, it will be
completely replaced.  This module does not use the sshkey type from
the sshkeys_core module and instead uses a template to generate the
ssh_known_hosts file.  This is largely because sshkey is innefficient
with a large number of public keys and it doesn't support markers
(@revoke, and @cert-authority).

The module uses the ssh_authorized_key type from sshkeys_core for
managing authorized_keys, and therefore it will not completely replace
an existing user's authorized keys file.

The module can handle installing ssh host key pairs, but does not
generate them, nor does it attempt to protect the private key.  You
would need something like eyaml or some secret injection service to
securely manage private keys.

### Setup Requirements

Modules required:
* puppetlabs/stdlib
* herculesteam/augeasproviders_core
* herculesteam/augeasproviders_ssh
* puppetlabs/sshkeys_core


## Usage

Install packages and start the service:

```
include openssh
```

### class invocation

``` puppet
class { 'openssh':
  ssh_config => {
    'StrictHostKeyChecking' => {
      value => 'yes',
    }
  },
  sshd_config => {
    'PermitRootLogin' => {
      value => 'no',
    },
    # use the default
    MaxAuthTries => {
      ensure => absent,
    }
  }
}
```
    
## Reference

see the REFERENCE.md

## Limitations

Needs match statement support.

