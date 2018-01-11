require 'spec_helper'

describe 'omd::client::checks::logwatch' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'some_logfile' }
      let(:params) do
        {
          :content => "/path/to/log\n C crit"
        }
      end

      # we need to set the must parameter
      let(:pre_condition) do
        [
          'class omd::client { $check_mk_version = "1.2.3" }',
          'class omd::client { $logwatch_install = true }',
          'class omd::client { $user = "check_user" }',
          'class omd::client { $group = "check_group" }',
        ]
      end


      it do
        is_expected.to contain_class('omd::client::checks')
      end

      it do
        is_expected.to contain_file('/etc/check_mk/logwatch.d/some_logfile.cfg').with(
          :content => "/path/to/log\n C crit",
          :owner   => 'check_user',
          :group   => 'check_group'
        )
      end

      context 'parameter title => break me' do
        let(:title) do
          {
            :path => 'break me'
          }
        end

        it do
          is_expected.to raise_error(/does not match/)
        end
      end

      describe 'reinventorize trigger export' do
        # not testable for the moment
      end
    end
  end
end
