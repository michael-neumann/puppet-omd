require 'spec_helper'

describe 'omd::client::checks' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Debian'
        # we need to set the must parameter
        let(:pre_condition) do
          'class omd::client { $check_mk_version = "1.2.3" }'
        end

        it do
          is_expected.to contain_class('omd::client').that_comes_before('Class[omd::client::checks]')
        end

        it do
          is_expected.to contain_class('omd::client::checks::params')
        end

        it do
          is_expected.to contain_class('omd::client::checks::install')
        end

        it do
          is_expected.to contain_class('omd::client::checks::config')\
            .that_requires('Class[omd::client::checks::install]')
        end

        describe 'installation' do
          it do
            is_expected.to contain_file('/usr/local/lib/nagios').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file('/usr/local/lib/nagios/plugins').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_puppet").with(
              :path   => '/usr/local/lib/nagios/plugins/check_puppet.rb',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_cert").with(
              :path   => '/usr/local/lib/nagios/plugins/check_cert.rb',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end
        end

        describe 'configuration' do
          it do
            is_expected.to contain_concat('/etc/check_mk/mrpe.cfg').with(
              :ensure => 'present',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0644'
            )
          end

          it do
            is_expected.to contain_concat__fragment('mrpe.cfg header').with(
              :target  => '/etc/check_mk/mrpe.cfg',
              :order   => '01',
              :content => "### Managed by puppet.\n\n"
            )
          end
        end

      when 'RedHat'
        #context 'RedHat based system' do
        #      let(:facts) do
        #        {
        #          :osfamily => 'RedHat'
        #        }
        #      end

        # we need to set the must parameter
        let(:pre_condition) do
          'class omd::client { $check_mk_version = "1.2.3" }'
        end

        it do
          is_expected.to contain_class('omd::client').that_comes_before('Class[omd::client::checks]')
        end

        it do
          is_expected.to contain_class('omd::client::checks::params')
        end

        it do
          is_expected.to contain_class('omd::client::checks::install')
        end

        it do
          is_expected.to contain_class('omd::client::checks::config')\
            .that_requires('Class[omd::client::checks::install]')
        end

        describe 'installation' do
          it do
            is_expected.to contain_file('/usr/local/lib/nagios').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file('/usr/local/lib/nagios/plugins').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_puppet").with(
              :path   => '/usr/local/lib/nagios/plugins/check_puppet.rb',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_cert").with(
              :path   => '/usr/local/lib/nagios/plugins/check_cert.rb',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0755'
            )
          end
        end

        describe 'configuration' do
          it do
            is_expected.to contain_concat('/etc/check_mk/mrpe.cfg').with(
              :ensure => 'present',
              :owner  => 'root',
              :group  => 'root',
              :mode   => '0644'
            )
          end

          it do
            is_expected.to contain_concat__fragment('mrpe.cfg header').with(
              :target  => '/etc/check_mk/mrpe.cfg',
              :order   => '01',
              :content => "### Managed by puppet.\n\n"
            )
          end
        end


      when 'FreeBSD'
        #      context 'FreeBSD based system' do
        #      let(:facts) do
        #        {
        #          :osfamily => 'FreeBSD'
        #        }
        #      end

        # we need to set the must parameter
        let(:pre_condition) do
          'class omd::client { $check_mk_version = "1.2.8" }'
        end

        it do
          is_expected.to contain_class('omd::client').that_comes_before('Class[omd::client::checks]')
        end

        it do
          is_expected.to contain_class('omd::client::checks::params')
        end

        it do
          is_expected.to contain_class('omd::client::checks::install')
        end

        it do
          is_expected.to contain_class('omd::client::checks::config')\
            .that_requires('Class[omd::client::checks::install]')
        end

        describe 'installation' do
          it do
            is_expected.to contain_file('/usr/local/lib/nagios').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'wheel',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file('/usr/local/lib/nagios/plugins').with(
              :ensure => 'directory',
              :owner  => 'root',
              :group  => 'wheel',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_puppet").with(
              :path   => '/usr/local/lib/nagios/plugins/check_puppet.rb',
              :owner  => 'root',
              :group  => 'wheel',
              :mode   => '0755'
            )
          end

          it do
            is_expected.to contain_file("check_cert").with(
              :path   => '/usr/local/lib/nagios/plugins/check_cert.rb',
              :owner  => 'root',
              :group  => 'wheel',
              :mode   => '0755'
            )
          end
        end

        describe 'configuration' do
          it do
            is_expected.to contain_concat('/etc/check_mk/mrpe.cfg').with(
              :ensure => 'present',
              :owner  => 'root',
              :group  => 'wheel',
              :mode   => '0644'
            )
          end

          it do
            is_expected.to contain_concat__fragment('mrpe.cfg header').with(
              :target  => '/etc/check_mk/mrpe.cfg',
              :order   => '01',
              :content => "### Managed by puppet.\n\n"
            )
          end
        end
      end
    end
  end
end
