# frozen_string_literal: true

require 'spec_helper'

describe 'openssh::keypair' do
  let(:title) { 'namevar' }

  {
    'rsa'     => 'ssh-rsa public foo.example.com',
    'dsa'     => 'ssh-dss public foo.example.com',
    'ecdsa'   => 'ecdsa-sha2-nistp512 public foo.example.com',
    'ed25519' => 'ssh-ed25519 public foo.example.com',
  }.each do |keytype, public_key|
    context "keytype #{keytype} with full public key" do
      let(:node) { 'foo.example.com' }
      let(:params) do
        {
          'keytype' => keytype,
          'private_key' => nil,
          'public_key' => public_key,
          'mode' => '0666',
          'owner' => 'bob',
          'group' => 0,
          'ssh_etc' => '/etc/ssh',
        }
      end

      keyfile = "ssh_host_#{keytype}_key"

      it {
        is_expected.to contain_file("/etc/ssh/#{keyfile}.pub").with('mode' => '0644',
                                                                    'owner' => 'bob',
                                                                    'group' => 0,
                                                                    'content' => "#{public_key}\n")
      }
    end
  end
  ['rsa', 'dsa', 'ecdsa', 'ed25519'].each do |keytype|
    context "keytype #{keytype}" do
      let(:node) { 'foo.example.com' }
      let(:params) do
        {
          'keytype' => keytype,
          'private_key' => 'private key',
          'public_key' => 'public key',
          'public_cert' => 'public cert',
          'mode' => '0666',
          'owner' => 'ssh-key',
          'group' => 5,
          'ssh_etc' => '/opt/ssh/etc',
        }
      end

      case keytype
      when 'rsa'
        keyfile = 'ssh_host_rsa_key'
        public_key = "ssh-rsa public key foo.example.com\n"
      when 'dsa'
        keyfile = 'ssh_host_dsa_key'
        public_key = "ssh-dss public key foo.example.com\n"
      when 'ecdsa'
        keyfile = 'ssh_host_ecdsa_key'
        public_key = "ecdsa-sha2-nistp256 public key foo.example.com\n"
      when 'ed25519'
        keyfile = 'ssh_host_ed25519_key'
        public_key = "ssh-ed25519 public key foo.example.com\n"
      end

      it { is_expected.to contain_file("/opt/ssh/etc/#{keyfile}").with('mode' => '0666', 'owner' => 'ssh-key', 'group' => 5, 'content' => 'private key') }
      it { is_expected.to contain_file("/opt/ssh/etc/#{keyfile}.pub").with('mode' => '0644', 'owner' => 'ssh-key', 'group' => 0).with_content(public_key) }
      it { is_expected.to contain_file("/opt/ssh/etc/#{keyfile}-cert.pub").with('mode' => '0644', 'owner' => 'ssh-key', 'group' => 0).with_content("public cert\n") }
    end
  end
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:params) do
        { 'keytype' => 'rsa', 'private_key' => nil, 'public_key' => nil }
      end
      let(:facts) { os_facts }
      let :pre_condition do
        'include openssh'
      end

      it { is_expected.to compile }
    end
  end
end
