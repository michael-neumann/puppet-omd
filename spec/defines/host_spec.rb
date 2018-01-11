require 'spec_helper'

describe 'omd::host' do
  let(:title) { 'default' }
  let(:default_params) do
    {
      :folder => 'collected_hosts',
      :tags   => ['some_tag']
    }
  end

  let(:params) { default_params }

  # we need to set the must parameter
  let(:pre_condition) do
    'class omd::client { $check_mk_version = "1.2.3" }'
  end

  it do
    is_expected.to contain_class('omd::client')
  end

  # external resource cannot be tested...

  describe 'with broken site name (title) => break me' do
    let(:title) { 'break me' }
    it do
      is_expected.to raise_error(/does not match/)
    end
  end
end
