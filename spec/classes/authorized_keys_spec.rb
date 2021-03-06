# frozen_string_literal: true

require 'spec_helper'

describe 'openssh::authorized_keys' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let :pre_condition do
        'include openssh'
      end

      it { is_expected.to compile }
    end
  end
end
