require 'spec_helper'

describe 'omd::site::config' do
  let(:title) { 'default' }
  let(:default_params) do
    {
      :options => {
        'DEFAULT_GUI' => 'check_mk',
        'CORE' => 'nagios',
      },
    }
  end

  let(:params) { default_params }

  it do
    is_expected.to contain_omd__site__config('default')
  end

  it do
    is_expected.to contain_omd__site__config_variable('default - DEFAULT_GUI = check_mk')
  end

  it do
    is_expected.to contain_omd__site__config_variable('default - CORE = nagios')
  end

  context 'parameter options => [breakme]' do
    let(:params) do
      default_params.merge({ :options => ['breakme'] })
    end

    it do
      is_expected.to raise_error(/is not a Hash/)
    end
  end
end
