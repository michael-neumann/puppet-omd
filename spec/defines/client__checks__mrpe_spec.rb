require 'spec_helper'

describe 'omd::client::checks::mrpe' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { 'Test_Check' }
      let(:params) do
        {
          :path => '/usr/local/lib/nagios/plugins/test_check.sh'
        }
      end

      # we need to set the must parameter
      let(:pre_condition) do
        'class omd::client { $check_mk_version = "1.2.3" }'
      end

      it do
        is_expected.to contain_class('omd::client::checks')
      end

      it do
        is_expected.to contain_concat__fragment('check_mrpe_Test_Check').with(
          :target  => '/etc/check_mk/mrpe.cfg',
          :content => "Test_Check\t/usr/local/lib/nagios/plugins/test_check.sh \n",
          :order   => '50'
        )
      end

      context 'with title => A_check, parameter path => /path/to/check.sh and options => -H ahost.localhost' do
        let(:title) { 'A_Check' }
        let(:params) do
          {
            :path    => '/path/to/ACert.pem',
            :options => '-H ahost.localhost'
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_mrpe_A_Check').with_content(
            "A_Check\t/path/to/ACert.pem -H ahost.localhost\n"
          )
        end
      end

      context 'parameter path => break me' do
        let(:params) do
          {
            :path => 'break me'
          }
        end

        it do
          is_expected.to raise_error(/is not an absolute path/)
        end
      end

      context 'with parameter options => {}' do
        let(:params) do
          {
            :path => '/some/set/path',
            :options => {}
          }
        end

        it do
          is_expected.to raise_error(/is not a string/)
        end
      end

      describe 'reinventorize trigger export' do
        # not testable for the moment
      end
    end
  end
end
