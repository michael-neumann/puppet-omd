require 'spec_helper'

describe 'omd::site::custom_check', :type => :define do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'test_check' }

      let(:params) do
        {
          :site_name           => 'default',
          :service_description => 'test service',
          :host_tags           => [ 'test_check' ],
          :command_name        => 'check_test_app',
          :command             => 'ima_test -command true'
        }
      end

      it do
        is_expected.to contain_file('/opt/omd/sites/default/etc/check_mk/conf.d/test_check.mk')
      end
    end
  end
end
