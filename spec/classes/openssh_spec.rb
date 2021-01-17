# frozen_string_literal: true

require 'spec_helper'

describe 'openssh' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to have_class_count(7) }
      it { is_expected.to contain_class('openssh::install') }
      it { is_expected.to contain_class('openssh::config') }
      it { is_expected.to contain_class('openssh::service') }
      it { is_expected.to contain_class('openssh::authorized_keys') }
      it { is_expected.to contain_class('openssh::ssh_config') }
      it { is_expected.to contain_class('openssh::known_hosts') }
    end
  end
end
