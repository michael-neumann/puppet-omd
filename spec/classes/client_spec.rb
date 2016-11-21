require 'spec_helper'

describe 'omd::client' do
  on_supported_os.each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:default_params) do
        {
          :check_mk_version => '1.2.4p5-1',
        }
      end

      let(:params) do
        default_params
      end

      it do
        is_expected.to contain_class('omd::client::install')
      end

      it do
        is_expected.to contain_class('omd::client::config').that_requires('Class[omd::client::install]')
      end

      describe 'installation' do
        it do
          is_expected.to contain_file('/etc/check_mk').with(
            :ensure => 'directory',
            :owner  => 'root',
            :group  => 'root',
            :mode   => '0755'
          ).that_comes_before('Package[check_mk-agent]')
        end

        case facts[:osfamily]
        when 'Debian'
          it do
            is_expected.to contain_staging__file('check-mk-agent_1.2.4p5-1_all.deb')\
              .with_source('http://mathias-kettner.de/download/check-mk-agent_1.2.4p5-1_all.deb')\
              .that_comes_before('Package[check_mk-agent]')
          end

          it do
            is_expected.to contain_package('check_mk-agent').with(
              :ensure   => 'installed',
              :name     => 'check-mk-agent',
              :source   => '/opt/staging/omd/check-mk-agent_1.2.4p5-1_all.deb',
              :provider => 'dpkg'
            )
          end

          context 'with parameter logwatch_install => true' do
            let(:params) do
              default_params.merge({ :logwatch_install => true })
            end

            it do
              is_expected.to contain_staging__file('check-mk-agent-logwatch_1.2.4p5-1_all.deb')\
                .with_source('http://mathias-kettner.de/download/check-mk-agent-logwatch_1.2.4p5-1_all.deb')\
                .that_comes_before('Package[check_mk-agent-logwatch]')
            end

            it do
              is_expected.to contain_package('check_mk-agent-logwatch').with(
                :ensure   => 'installed',
                :name     => 'check-mk-agent-logwatch',
                :source   => '/opt/staging/omd/check-mk-agent-logwatch_1.2.4p5-1_all.deb',
                :provider => 'dpkg'
              )
            end
          end

          context 'with parameter download_source=> http://localhost, logwatch_install => true' do
            let(:params) do
              default_params.merge(
                :download_source  => 'http://localhost',
                :logwatch_install => true
              )
            end

            it do
              is_expected.to contain_staging__file('check-mk-agent_1.2.4p5-1_all.deb')\
                .with_source('http://localhost/check-mk-agent_1.2.4p5-1_all.deb')\
                .that_comes_before('Package[check_mk-agent]')
            end

            it do
              is_expected.to contain_staging__file('check-mk-agent-logwatch_1.2.4p5-1_all.deb')\
                .with_source('http://localhost/check-mk-agent-logwatch_1.2.4p5-1_all.deb')\
                .that_comes_before('Package[check_mk-agent-logwatch]')
            end
          end

          context 'with parameter download_package => false' do
            let(:params) do
              default_params.merge( :download_package => false )
            end

            it do
              is_expected.to contain_package('check_mk-agent').with(
                :ensure   => 'installed',
                :name     => 'check-mk-agent'
              ).without_source.without_provider
            end
          end

          context 'with parameter download_package => false, logwatch_install => true' do
            let(:params) do
              default_params.merge(
                :download_package => false,
                :logwatch_install => true
              )
            end

            it do
              is_expected.to contain_package('check_mk-agent-logwatch').with(
                :ensure   => 'installed',
                :name     => 'check-mk-agent-logwatch'
              ).without_source.without_provider
            end
          end
        when 'RedHat'
          it do
            is_expected.to contain_package('check_mk-agent').with(
              :ensure   => 'installed',
              :name     => 'check_mk-agent',
              :source   => 'http://mathias-kettner.de/download/check_mk-agent-1.2.4p5-1.noarch.rpm',
              :provider => 'rpm'
            )
          end

          context 'with parameter logwatch_install => true' do
            let(:params) do
              default_params.merge( :logwatch_install => true )
            end

            it do
              is_expected.to contain_package('check_mk-agent-logwatch').with(
                :ensure   => 'installed',
                :name     => 'check_mk-agent-logwatch',
                :source   => 'http://mathias-kettner.de/download/check_mk-agent-logwatch-1.2.4p5-1.noarch.rpm',
                :provider => 'rpm'
              ).that_requires('Package[check_mk-agent]')
            end
          end

          context 'with parameter download_source=> http://localhost, logwatch_install => true' do
            let(:params) do
              default_params.merge(
                :download_source  => 'http://localhost',
                :logwatch_install => true
              )
            end

            it do
              is_expected.to contain_package('check_mk-agent').with(
                :ensure   => 'installed',
                :name     => 'check_mk-agent',
                :source   => 'http://localhost/check_mk-agent-1.2.4p5-1.noarch.rpm',
                :provider => 'rpm'
              )
            end

            it do
              is_expected.to contain_package('check_mk-agent-logwatch').with(
                :ensure   => 'installed',
                :name     => 'check_mk-agent-logwatch',
                :source   => 'http://localhost/check_mk-agent-logwatch-1.2.4p5-1.noarch.rpm',
                :provider => 'rpm'
              ).that_requires('Package[check_mk-agent]')
            end
          end

          context 'with parameter download_package => false' do
            let(:params) do
              default_params.merge( :download_package => false )
            end

            it do
              is_expected.to contain_package('check_mk-agent').with(
                :ensure   => 'installed',
                :name     => 'check_mk-agent'
              ).without_source.without_provider
            end
          end

          context 'with parameter download_package => false, logwatch_install => true' do
            let(:params) do
              default_params.merge(
                :download_package => false,
                :logwatch_install => true
              )
            end

            it do
              is_expected.to contain_package('check_mk-agent-logwatch').with(
                :ensure   => 'installed',
                :name     => 'check_mk-agent-logwatch'
              ).without_source.without_provider
            end
          end
        when 'FreeBSD'
          it do
            is_expected.to contain_wget__fetch('check_mk_agent.freebsd').with(
              'source'      => 'http://git.mathias-kettner.de/git/?p=check_mk.git;a=blob_plain;f=agents/check_mk_agent.freebsd;hb=refs/heads/1.2.4',
              'destination' => '/usr/local/bin/check_mk_agent',
              'unless'      => 'test -f /usr/local/bin/check_mk_agent',
              'before'      => 'File[/usr/local/bin/check_mk_agent]'
            )
          end

          it do
            is_expected.to contain_file('/usr/local/bin/check_mk_agent').with(
              'ensure' => 'present',
              'owner'  => 'root',
              'group'  => 'wheel',
              'mode'   => '0755'
            )
          end
        end

        context 'with parameter check_mk_version => 1.2.3' do
          let(:params) do
            {
              :check_mk_version => '1.2.3'
            }
          end

          it do
            is_expected.to contain_package('check_mk-agent').with_source(/1\.2\.3/)
          end
        end

        context 'with parameter check_mk_version => [breakme]' do
          let(:params) do
            {
              :check_mk_version => ['breakme']
            }
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end

        context 'with parameter download_source => [ breakme ]' do
          let(:params) do
            default_params.merge( :download_source => ['breakme'] )
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end

        context 'with parameter download_package => false' do
          let(:params) do
            default_params.merge( :download_package => false )
          end

          it do
            is_expected.to contain_package('check_mk-agent').without_provider.without_source
          end
        end

        context 'with parameter download_package => breakme' do
          let(:params) do
            default_params.merge( :download_package => 'breakme' )
          end

          it do
            is_expected.to raise_error(/is not a boolean/)
          end
        end

        context 'with parameter package_name => test-name' do
          let(:params) do
            default_params.merge( :package_name => 'test-name' )
          end

          it do
            is_expected.to contain_package('check_mk-agent').with(
              :ensure   => 'installed',
              :name     => 'test-name'
            )
          end
        end

        context 'with parameter package_name => [breakme]' do
          let(:params) do
            default_params.merge( :package_name => ['breakme'] )
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end

        describe 'with parameter logwatch_install => true' do
          context 'with parameter user => check_user, group => check_group' do
            let(:params) do
              default_params.merge(
                :logwatch_install => true,
                :user             => 'check_user',
                :group            => 'check_group'
              )
            end

            it do
              is_expected.to contain_file('/etc/check_mk/logwatch.cfg').with(
                :ensure => 'present',
                :owner  => 'check_user',
                :group  => 'check_group'
              )
            end

            it do
              is_expected.to contain_file('/etc/check_mk/logwatch.d').with(
                :ensure => 'directory',
                :owner  => 'check_user',
                :group  => 'check_group'
              )
            end
          end
        end

        context 'with parameter user => {}' do
          let(:params) do
            default_params.merge( :user => {} )
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end

        context 'with parameter group => {}' do
          let(:params) do
            default_params.merge( :group => {} )
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end
      end

      describe 'configuration' do
        it do
          is_expected.to contain_xinetd__service('check_mk').with(
            :service_type            => 'UNLISTED',
            :port                    => 6556,
            :disable                 => 'no',
            :server                  => '/usr/bin/check_mk_agent',
            :log_on_success          =>  '',
            :log_on_success_operator => '='
          ).without_only_from
        end

        context 'with parameter check_only_from => 192.168.1.1' do
          let(:params) do
            default_params.merge( :check_only_from => '192.168.1.1' )
          end

          it do
            is_expected.to contain_xinetd__service('check_mk').with_only_from('192.168.1.1')
          end
        end

        context 'with parameter check_only_from => [breakme]' do
          let(:params) do
            default_params.merge( :check_only_from => ['breakme'] )
          end

          it do
            is_expected.to raise_error(/is not a string/)
          end
        end

        context 'with parameter check_agent => /usr/bin/check_mk_caching_agent' do
          let(:params) do
            default_params.merge( :check_agent => '/usr/bin/check_mk_caching_agent' )
          end

          it do
            is_expected.to contain_xinetd__service('check_mk').with_server('/usr/bin/check_mk_caching_agent')
          end
        end

        context 'with parameter check_agent => brea kme' do
          let(:params) do
            default_params.merge( :check_agent => 'brea kme' )
          end

          it do
            is_expected.to raise_error(/is not an absolute path/)
          end
        end

        context 'with parameter xinetd_disable => yes' do
          let(:params) do
            default_params.merge( :xinetd_disable => 'yes' )
          end

          it do
            is_expected.to contain_xinetd__service('check_mk').with_disable('yes')
          end
        end

        context 'with parameter xinetd_disable => breakme' do
          let(:params) do
            default_params.merge( :xinetd_disable => 'breakme' )
          end

          it do
            is_expected.to raise_error(/does not match/)
          end
        end
      end

      describe 'host creation' do
        it do
          is_expected.to contain_omd__host('default')
        end

        context 'with paramter hosts => breakme' do
          let(:params) do
            default_params.merge( :hosts => 'breakme' )
          end

          it do
            is_expected.to raise_error(/is not a Hash/)
          end
        end

        context 'with parameter hosts => { othersite => { folder => otherfolder }, site2 => {} }' do
          let(:params) do
            default_params.merge(
              :hosts => {
                'othersite' => { 'folder' => 'otherfolder' },
                'site2'     => {}
              }
            )
          end

          it do
            is_expected.to contain_omd__host('othersite').with_folder('otherfolder')
          end

          it do
            is_expected.to contain_omd__host('site2')
          end
        end

        context 'with parameter hosts_defaults => { folder => testfolder, tags => [atag] }' do
          let(:params) do
            default_params.merge(
              :hosts_defaults => {
                'folder' => 'testfolder',
                'tags'   => ['atag']
              }
            )
          end

          it do
            is_expected.to contain_omd__host('default').with_folder('testfolder').with_tags(['atag'])
          end
        end
      end
    end
  end
end
