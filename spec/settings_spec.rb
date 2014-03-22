require 'spec_helper'
describe Peony::Settings do
  describe 'instances' do
    before :each do
      @settings = Peony::Settings.new
    end
    
    it 'setting/getting should work' do
      @settings.email = 'zhiqiangzhan@gmail.com'
      @settings.email.should == 'zhiqiangzhan@gmail.com'
    end
    
    it 'setting proc should work' do
      @settings.email = ->{ 'zhiqiangzhan@gmail.com' }
      @settings.email.should == 'zhiqiangzhan@gmail.com'
    end
    
    it 'lambdas should work' do
      @settings.path = lambda { "/var/www/#{@settings.version}" }
      @settings.version = '3'

      @settings.path?.should be_true
      @settings.path.should == '/var/www/3'
    end
    
    it 'setting block should work' do
      @settings.send(:email=){ 'zhiqiangzhan@gmail.com' }
      @settings.email.should == 'zhiqiangzhan@gmail.com'
    end
    
    it 'setting set default value should be work' do
      @settings.send(:x=, 1){ 3 }
      @settings.x.should == 1
      @settings.send(:y=, nil){ 3 }
      @settings.y.should == 3
      @settings.send(:z=){ 6 }
      @settings.z.should == 6
    end
    
    
    it 'setting get default value should be work' do
      @settings.x = -1
      @settings.x{1}.should == -1
      @settings.y{3}.should == 3
      @settings.z{6}.should == 6
    end
    
    it 'question mark should work with nils' do
      @settings.deploy_to = nil
      @settings.deploy_to?.should be_true
      @settings.foobar?.should be_false
    end

    it '||= should work (1)' do
      @settings.x = 2
      @settings.x ||= 3
      @settings.x.should == 2
    end

    it '||= should work (2)' do
      @settings.x ||= 3
      @settings.x.should == 3
    end
    
    it 'bangs should check for settings' do
      expect { @settings.non_existent_setting! }.to raise_error(Peony::Error, /non_existent_setting/)
    end

    it 'bangs should return settings' do
      @settings.version = 4
      @settings.version!.should == 4
    end
    
  end
end