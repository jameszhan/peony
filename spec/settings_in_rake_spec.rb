require 'spec_helper'

describe 'Settings in rake tasks' do
  it '#set should work' do
    peony { set :domain, 'localhost' }

    peony.domain.should == 'localhost'
    peony.settings.domain.should == 'localhost'
  end

  it '#settings ||= should work' do
    peony {
      set :version, '2'
      settings.version ||= '3'
    }

    peony.settings.version.should == '2'
    peony.version.should == '2'
  end

  it '#settings with lambdas should work' do
    peony {
      set :version, '42'
      set :path, lambda { "/var/www/#{version}" }
    }

    peony.path.should == '/var/www/42'
    peony.settings.path?.should be_true
  end

  it '#settings with a bang should work' do
    expect {
      peony {
        set :path, lambda { "/var/www/#{settings.version!}" }
      }
      peony.path
    }.to raise_error(Peony::Error, /version/)
  end
end
