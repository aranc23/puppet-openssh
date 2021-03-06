# frozen_string_literal: true

require 'spec_helper'

describe 'openssh' do
  context 'os non-specific' do
    # let(:params) do
    #   {
    #     manage_krl: False,
    #   }
    # end

    it { is_expected.to have_class_count(7) }
    it { is_expected.to contain_class('openssh::install') }
    it { is_expected.to contain_class('openssh::config') }
    it { is_expected.to contain_class('openssh::service') }
    it { is_expected.to contain_class('openssh::authorized_keys') }
    it { is_expected.to contain_class('openssh::ssh_config') }
    it { is_expected.to contain_class('openssh::known_hosts') }
    it {
      is_expected.to contain_file('/etc/ssh/validate_public_cert.sh').with('owner'  => 'root',
                                                                           'group'  => 0,
                                                                           'mode'   => '0750',
                                                                           'source' => 'puppet:///modules/openssh/validate_public_cert.sh')
    }
    it { is_expected.not_to contain_file('/etc/ssh/krl') }
    it { is_expected.not_to contain_file('/etc/ssh/ssh_known_hosts') }
    it { is_expected.not_to contain_sshd_config('RevokedKeys') }
    it { is_expected.not_to contain_sshd_config('TrustedUserCAKeys') }
  end
  context 'manage the krl' do
    let(:params) do
      {
        manage_krl: true,
        krl_path: '/etc/ssh/revoked',
        krl: { 'bob@hal' => { 'type' => 'ssh-rsa', 'key' => 'some key' } },
      }
    end

    it { is_expected.not_to contain_file('/etc/ssh/revoked') }
    it { is_expected.to contain_sshd_config('RevokedKeys') }
    it { is_expected.to contain_ssh_authorized_key('bob@hal').with(target: '/etc/ssh/revoked', type: 'ssh-rsa', key: 'some key') }
  end
  context 'manage the krl using krl_source' do
    let(:params) do
      {
        manage_krl: true,
        krl_path: '/etc/ssh/revoked',
        krl: { 'bob@hal' => { 'type' => 'ssh-rsa', 'key' => 'some key' } },
        krl_source: 'puppet:///modules/profile/krl',
      }
    end

    it { is_expected.to contain_file('/etc/ssh/revoked').with(source: 'puppet:///modules/profile/krl') }
    it { is_expected.to contain_sshd_config('RevokedKeys') }
    it { is_expected.not_to contain_ssh_authorized_key('bob@hal').with(target: '/etc/ssh/revoked', type: 'ssh-rsa', key: 'some key') }
  end
  context 'manage the the trusted user ca keys' do
    let(:params) do
      {
        manage_trusted_user_ca_keys: true,
        trusted_user_ca_keys_path: '/etc/ssh/my_ca.pub',
        trusted_user_ca_keys: {
          'ca@some' => { type: 'ssh-rsa', key: 'some key' },
        },
      }
    end

    it { is_expected.to contain_sshd_config('TrustedUserCAKeys') }
    it { is_expected.to contain_ssh_authorized_key('ca@some').with(type: 'ssh-rsa', key: 'some key', target: '/etc/ssh/my_ca.pub', user: 'root') }
  end
  context 'configure sshd and ssh client' do
    let(:params) do
      {
        sshd_config: {
          'Protocol' => {
            'value' => '2',
          },
        },
        ssh_config: {
          'HashKnownHosts' => {
            'value' => 'no',
          },
        },
      }
    end

    it { is_expected.to contain_sshd_config('Protocol') }
    it { is_expected.to contain_ssh_config('HashKnownHosts') }
  end
  context 'create banner' do
    let(:params) do
      {
        banner_path: '/etc/ssh/banner',
        banner: 'logins are logged',
      }
    end

    it { is_expected.to contain_file('/etc/ssh/banner').with_content('logins are logged') }
  end
  context 'manage known hosts with source' do
    let(:params) do
      {
        manage_known_hosts: true,
        known_hosts_source: 'http://example.com/known_hosts',
        known_hosts_path: '/etc/ssh/other_hosts',
        known_hosts: { 'example.com' => { 'host_aliases' => ['examp'], 'ssh-rsa' => 'rsa key', 'ssh-dss' => 'dsa key', 'marker' => 'cert-authority' } },
        hash_known_hosts: true,
      }
    end

    it { is_expected.to contain_file('/etc/ssh/other_hosts').with(mode: '0644', source: 'http://example.com/known_hosts') }
  end
  context 'manage hashed known hosts' do
    let(:params) do
      {
        manage_known_hosts: true,
        known_hosts_path: '/etc/ssh/other_hosts',
        known_hosts: { 'example.com' => { 'host_aliases' => ['examp'], 'ssh-rsa' => 'rsa key', 'ssh-dss' => 'dsa key', 'marker' => 'cert-authority' } },
        hash_known_hosts: true,
      }
    end

    it { is_expected.to contain_file('/etc/ssh/other_hosts.unhashed').with(mode: '0600').with_content(%r{example.com}) }
    it { is_expected.to contain_file('/etc/ssh/other_hosts').with(mode: '0644') }
    it { is_expected.to contain_file('/etc/ssh/other_hosts.sh').with(mode: '0700') }
    it { is_expected.to contain_exec('/etc/ssh/other_hosts.sh') }
  end
  context 'manage unhashed known hosts' do
    let(:params) do
      {
        manage_known_hosts: true,
        known_hosts_path: '/etc/ssh/other_hosts',
        known_hosts: { 'example.com' => { 'host_aliases' => ['examp'], 'ssh-rsa' => 'rsa key', 'ssh-dss' => 'dsa key', 'marker' => 'cert-authority' } },
        hash_known_hosts: false,
      }
    end

    it { is_expected.to contain_file('/etc/ssh/other_hosts').with(mode: '0644').with_content(%r{example.com}) }
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          fqdn: 'test.example.com',
        )
      end

      it { is_expected.to compile }
      it { is_expected.to contain_service('sshd') }
      it { is_expected.to contain_package('openssh-server') }

      case os_facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_package('openssh-client') }
      else
        ['openssh', 'openssh-clients'].each do |p|
          it { is_expected.to contain_package(p) }
        end
      end
      context 'manage host keys' do
        let(:node) { 'test.example.com' }
        let(:params) do
          {
            rsa_private_key: 'some key',
            rsa_public_cert: 'some key',
            rsa_public_key: 'some key',
            dsa_private_key: 'some key',
            dsa_public_key: 'some key',
            dsa_public_cert: 'some key',
            ecdsa_private_key: 'some key',
            ecdsa_public_key: 'some key',
            ecdsa_public_cert: 'some key',
            ed25519_private_key: 'some key',
            ed25519_public_key: 'some key',
            ed25519_public_cert: 'some key',
            supported_key_types: ['rsa', 'dsa', 'ecdsa', 'ed25519'],
          }
        end

        withs =
          case os_facts[:osfamily]
          when 'RedHat'
            case os_facts[:operatingsystemmajrelease]
            when ['5', '6']
              # old red hats
              {
                'mode'  => '0600',
                'owner' => 'root',
                'group' => 0,
              }
            else
              # newer red hats
              {
                'mode'  => '0640',
                'owner' => 'root',
                'group' => 'ssh_keys',
              }
            end
          else
            # all the other hats
            {
              'mode'  => '0600',
              'owner' => 'root',
              'group' => 0,
            }
          end
        ['rsa', 'dsa', 'ecdsa', 'ed25519'].each do |keytype|
          it { is_expected.to contain_openssh__keypair("test.example.com #{keytype} key").with(withs.merge('keytype' => keytype)) }
        end
      end
    end
  end
end
