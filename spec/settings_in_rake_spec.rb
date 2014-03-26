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
    }.to raise_error(KeyError, /version/)
  end

  it '#settings with default value' do
      peony {
        set :a, '100'
        set_default :a, 3000
        set_default :b, 6000
      }
      peony.a.should == '100'
      peony.b.should == 6000
  end

  it '#settings with scope' do
    peony {
      set :a, 1
      set 'e', 1
      set 'f', 1
      set 'g', 1
      scope 'scope1' do
        set :a, 2
        set :b, 2
        set :u, 2
        set :v, 2
        set :w, 2
        scope 'scope2' do
          set 'a', 3
          set 'b', 3
          set 'c', 3
          set :x, 3
          set :y, 3
          set :z, 3
        end
      end
    }

    peony.a.should == 1
    peony.e.should == 1
    peony.f.should == 1
    peony.g.should == 1
    peony.scope1.a.should == 2
    peony.scope1.b.should == 2
    peony.scope1.a.should == 2
    peony.scope1.u.should == 2
    peony.scope1.v.should == 2
    peony.scope1.w.should == 2
    peony.scope1.scope2.a.should == 3
    peony.scope1.scope2.b.should == 3
    peony.scope1.scope2.c.should == 3
    peony.scope1.scope2.x.should == 3
    peony.scope1.scope2.y.should == 3
    peony.scope1.scope2.z.should == 3

    peony.scope1.e.should == 1
    peony.scope1.f.should == 1
    peony.scope1.g.should == 1
    peony.scope1.scope2.u.should == 2
    peony.scope1.scope2.v.should == 2
    peony.scope1.scope2.w.should == 2
  end


end
