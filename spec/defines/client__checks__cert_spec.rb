require 'spec_helper'

describe 'omd::client::checks::cert' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:title) { '/etc/ssl/certs/ssl-cert-snakeoil.pem' }

      # we need to set the must parameter
      let(:pre_condition) do
        'class omd::client { $check_mk_version = "1.2.3" }'
      end

      it do
        is_expected.to contain_class('omd::client::checks')
      end

      it do
        is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with(
          :target  => '/etc/check_mk/mrpe.cfg',
          :content => "Cert__etc_ssl_certs_ssl-cert-snakeoil.pem\t/usr/local/lib/nagios/plugins/check_cert.rb -w 2592000 -c 604800 --cert /etc/ssl/certs/ssl-cert-snakeoil.pem \n",
          :order   => '50'
        ).that_requires('File[check_cert]')
      end

      context 'with title => A Cert.pem and parameter path => /path/to/ACert.pem' do
        let(:title) { 'A Cert.pem' }

        let(:params) do
          {
            :path => '/path/to/ACert.pem'
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_cert_A_Cert.pem').with_content(
            "Cert_A_Cert.pem\t/usr/local/lib/nagios/plugins/check_cert.rb -w 2592000 -c 604800 --cert /path/to/ACert.pem \n"
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

      context 'with parameter warn => 14400' do
        let(:params) do
          {
            :warn => 14400
          }
        end

        it do
          is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-w 14400/)
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
          is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-c 14400/)
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
          is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-f -e/)
        end
      end

      context 'with parameter options => {}' do
        let(:params) do
          {
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
