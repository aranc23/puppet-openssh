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
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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
    end
  end
end
