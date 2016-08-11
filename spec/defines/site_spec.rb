require 'spec_helper'

describe 'omd::site' do
  let(:title) { 'default_site' }

  # mock function from puppetdbquery
  # users rspec-puppet-utils MockFunction
  let!(:query_nodes) do
    MockFunction.new('query_nodes') do |f|
      f.stubs(:call).returns([1,2,3,4])
    end
  end

  it do
    is_expected.to contain_omd__site('default_site')
  end

  it do
    is_expected.to contain_class('omd::server')
  end

  it do
    is_expected.to contain_class('omd::server::install').that_comes_before('Omd::Site[default_site]')
  end

  # generic to trigger
  it do
    is_expected.to contain_exec("check_mk update site: default_site").with(
      :command     => "su - default_site -c 'check_mk -O'",
      :refreshonly => true
    )
  end

  context 'with title => break me' do
    let(:title) { 'break me' }

    it do
      is_expected.to raise_error(/does not match/)
    end
  end

  describe 'site creation' do
    it do
      is_expected.to contain_exec('create omd site: default_site').with(
        :command  => 'omd create default_site',
        :unless   => 'omd sites -b | grep -q \'\\<default_site\\>\'',
        :path     => ['/bin', '/usr/bin']
      )
    end

    context 'for \'othersite\' with parameter ensure => absent' do
      let(:title)  { 'othersite' }

      let(:params) do
        {
          :ensure => 'absent',
        }
      end

      it do
        is_expected.to contain_exec('remove omd site: othersite').with(
          :command  => 'yes yes | omd rm --kill othersite',
          :onlyif   => 'omd sites -b | grep -q \'\\<othersite\\>\''
        )
      end
    end

    context 'with parameter ensure => breakme' do
      let(:params) do
        {
          :ensure => 'breakme'
        }
      end

      it do
        is_expected.to raise_error(/does not match/)
      end
    end

    context 'with parameter uid => 678' do
      let(:params) do
        {
          :uid => 678
        }
      end

      it do
        is_expected.to contain_exec('create omd site: default_site').with_command(
          'omd create --uid 678 default_site'
        )
      end
    end

    context 'with parameter uid => breakme' do
      let(:params) do
        {
          :uid => 'breakme'
        }
      end

      it do
        is_expected.to raise_error(/does not match/)
      end
    end

    context 'with parameter gid => 789' do
      let(:params) do
        {
          :gid => 789
        }
      end

      it do
        is_expected.to contain_exec('create omd site: default_site').with_command(
          'omd create --gid 789 default_site'
        )
      end
    end

    context 'with parameter gid => breakme' do
      let(:params) do
        {
          :uid => 'breakme'
        }
      end

      it do
        is_expected.to raise_error(/does not match/)
      end
    end
  end

  describe 'site configuration' do
    let(:params) do
      {
        :options         => { 'DEFAULT_GUI' => 'check_mk' },
        :main_mk_content => 'some content'
      }
    end

    it do
      is_expected.to contain_omd__site__config('default_site').with_options(
        { 'DEFAULT_GUI' => 'check_mk' }
      )\
        .that_requires('Exec[create omd site: default_site]')\
        .that_notifies('Omd::Site::Service[default_site]')
    end

    it do
      is_expected.to contain_file('/omd/sites/default_site/etc/check_mk/main.mk').with(
        :owner   => 'default_site',
        :group   => 'default_site',
        :content => /some content/
      ).that_notifies('Exec[check_mk update site: default_site]')
    end

    context 'with parameter main_mk_content => [breakme]' do
      let(:params) do
        {
          :main_mk_content => ['breakme']
        }
      end

      it do
        is_expected.to raise_error(/is not a string/)
      end
    end
  end

  describe 'site service' do
    it do
      is_expected.to contain_omd__site__service('default_site').with(
        :ensure => 'running',
        :reload => false
      ).that_subscribes_to('Exec[create omd site: default_site]')
    end

    context 'for \'othersite\' with parameters { service_ensure => stopped, service_reload => true }' do
      let(:title) { 'othersite' }

      let(:params) do
        {
          :service_ensure => 'stopped',
          :service_reload => true
        }
      end

      it do
        is_expected.to contain_omd__site__service('othersite').with(
          :ensure => 'stopped',
          :reload => true
        ).that_subscribes_to('Exec[create omd site: othersite]')
      end
    end
  end

  describe 'hosts configuration' do
    it do
      is_expected.to contain_omd__site__config_hosts('default_site - collected_hosts')\
        .that_requires( 'Omd::Site::Service[default_site]')
    end

    context 'with parameter config_hosts => false' do
      let(:params) do
        {
          :config_hosts => false
        }
      end

      it do
        is_expected.to_not contain_omd__site__config_hosts('default_site - collected_hosts')
      end
    end

    context 'with parameter config_hosts => breakme' do
      let(:params) do
        {
          :config_hosts => 'breakme'
        }
      end

      it do
        is_expected.to raise_error(/is not a boolean/)
      end
    end

    context 'with parameter config_hosts_folders => [folder, otherfolder]' do
      let(:params) do
        {
          :config_hosts_folders => ['folder', 'otherfolder']
        }
      end

      it do
        is_expected.to contain_omd__site__config_hosts('default_site - folder')\
          .that_notifies('Exec[check_mk update site: default_site]')
      end

      it do
        is_expected.to contain_omd__site__config_hosts('default_site - otherfolder')\
          .that_notifies('Exec[check_mk update site: default_site]')
      end
    end

    context 'with parameter config_hosts_folders => { :folder => {} , :otherfolder => {} }' do
      let(:params) do
        {
          :config_hosts_folders => {
            'folder' => {} ,
            'otherfolder' => {}
          }
        }
      end

      it do
        is_expected.to contain_omd__site__config_hosts('default_site - folder')\
          .that_notifies('Exec[check_mk update site: default_site]')
      end

      it do
        is_expected.to contain_omd__site__config_hosts('default_site - otherfolder')\
          .that_notifies('Exec[check_mk update site: default_site]')
      end
    end

    context 'with parameter config_hosts_folders => { :folder => { :cluster => true, :cluster_tags => [one,two]}  }' do
      let(:params) do
        {
          :config_hosts_folders => {
            'folder'    => {
              'cluster'      => true,
              'cluster_tags' => [ 'one', 'two' ]
            }
          }
        }
      end

      it do
        is_expected.to contain_omd__site__config_hosts('default_site - folder').with(
          :cluster => true,
          :cluster_tags => ['one', 'two']
        ).that_notifies('Exec[check_mk update site: default_site]')
      end
    end

    context 'with parameter config_hosts_folders => breakme' do
      let(:params) do
        {
          :config_hosts_folders => 'breakme'
        }
      end

      it do
        is_expected.to raise_error(/\$config_hosts_folders must be either an Array or Hash/)
      end
    end
  end
end
