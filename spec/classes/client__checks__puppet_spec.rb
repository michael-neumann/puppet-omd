require 'spec_helper'

describe 'omd::client::checks::puppet' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      # we need to set the must parameter
      let(:pre_condition) do
        'class omd::client { $check_mk_version = "1.2.3" }'
      end

      it do
        is_expected.to contain_class('omd::client::checks')
      end

      it do
        is_expected.to contain_concat__fragment('check_puppet').with(
          :target  => '/etc/check_mk/mrpe.cfg',
          :content => "Puppet_Agent\t/usr/local/lib/nagios/plugins/check_puppet.rb -w 3600 -c 7200 \n",
          :order   => '50'
        ).that_requires('File[check_puppet]')
      end

      context 'with parameter warn => 14400' do
        let(:params) do
          {
            :warn => 14400
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_puppet').with_content(/-w 14400/)
        end
      end

      context 'with parameter warn => breakme' do
        let(:params) do
          {
            :warn => 'breakme'
          }
        end

        it do
          is_expected.to raise_error(Puppet::PreformattedError, //)
        end
      end

      context 'with parameter crit => 14400' do
        let(:params) do
          {
            :crit => 14400
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_puppet').with_content(/-c 14400/)
        end
      end

      context 'with parameter crit => breakme' do
        let(:params) do
          {
            :crit => 'breakme'
          }
        end

        it do
          is_expected.to raise_error(Puppet::PreformattedError, //)
        end
      end

      context 'with parameter options => \'-f -e\'' do
        let(:params) do
          {
            :options => '-f -e'
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_puppet').with_content(/-f -e/)
        end
      end

      context 'with parameter options => {}' do
        let(:params) do
          {
            :options => {}
          }
        end

        it do
          is_expected.to raise_error(Puppet::PreformattedError, //)
        end
      end

      describe 'reinventorize trigger export' do
        # not testable for the moment
      end
    end
  end
end
