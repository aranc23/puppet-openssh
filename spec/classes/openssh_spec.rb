# frozen_string_literal: true

require 'spec_helper'

describe 'openssh' do
  context "os non-specific" do
    it { is_expected.to have_class_count(7) }
    it { is_expected.to contain_class('openssh::install') }
    it { is_expected.to contain_class('openssh::config') }
    it { is_expected.to contain_class('openssh::service') }
    it { is_expected.to contain_class('openssh::authorized_keys') }
    it { is_expected.to contain_class('openssh::ssh_config') }
    it { is_expected.to contain_class('openssh::known_hosts') }
  end
  context "configure sshd and ssh client" do
    let(:params) {
      {
        :sshd_config => {
          'Protocol' => {
            'value' => '2',
          },
        },
        :ssh_config => {
          'HashKnownHosts' => {
            'value' => 'no',
        },
        },
      }
    }
    it { is_expected.to contain_sshd_config('Protocol') }
    it { is_expected.to contain_ssh_config('HashKnownHosts') }
  end
  context "create banner" do
    let(:params) {
      {
        :banner_path => '/etc/ssh/banner',
        :banner => 'logins are logged',
      }
    }
    it { is_expected.to contain_file('/etc/ssh/banner').with_content('logins are logged') }
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge({
                         :fqdn => 'test.example.com',
                       })
      end
      it { is_expected.to compile }
      it { is_expected.to contain_service('sshd') }
      case os_facts[:osfamily]
      when 'Debian'
        ['openssh-server', 'openssh-client' ].each do
          |p| it { is_expected.to contain_package(p) }
        end
      else
        %w(openssh openssh-server openssh-clients).each do
          |p| it { is_expected.to contain_package(p) }
        end
      end
      context "manage host keys" do
        let(:node) { 'test.example.com' }
        let(:params) {
          {
            :rsa_private_key => 'some key',
            :rsa_public_cert => 'some key',
            :rsa_public_key => 'some key',
            :dsa_private_key => 'some key',
            :dsa_public_key => 'some key',
            :dsa_public_cert => 'some key',
            :ecdsa_private_key => 'some key',
            :ecdsa_public_key => 'some key',
            :ecdsa_public_cert => 'some key',
            :ed25519_private_key => 'some key',
            :ed25519_public_key => 'some key',
            :ed25519_public_cert => 'some key',
            :supported_key_types => ['rsa','dsa','ecdsa','ed25519'],
          }
        }
        it { is_expected.to contain_openssh__keypair("test.example.com rsa key").with(:keytype => 'rsa') }
        it { is_expected.to contain_openssh__keypair("test.example.com dsa key").with(:keytype => 'dsa') }
        it { is_expected.to contain_openssh__keypair("test.example.com ecdsa key").with(:keytype => 'ecdsa') }
        it { is_expected.to contain_openssh__keypair("test.example.com ed25519 key").with(:keytype => 'ed25519') }
      end
    end
  end
end
