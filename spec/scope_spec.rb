require 'spec_helper'

describe Peony do
  describe 'Scope' do
    it 'should can set and get value' do
      root_scope = Peony::Scope.new
      scope = Peony::Scope.new(root_scope)

      root_scope[:a], scope[:b] = 1, 2
      scope[:a].should == 1
      scope.set(:a, 2)
      scope[:a].should == 2
      root_scope[:a].should == 2

      scope[:b].should == 2
      root_scope[:b].should == nil
      scope.set(:b, 3)
      scope[:b].should == 3
      root_scope[:b].should == nil

      root_scope.set(:b, 5)
      scope[:b].should == 3
      root_scope[:b].should == 5

      scope.local(:a, 6)
      scope[:a].should == 6
      root_scope[:a].should == 2
      scope[:a] = 8
      scope[:a].should == 8
      root_scope[:a].should == 2

      scope.delete(:a)
      scope[:a] = 9
      scope[:a].should == 9
      root_scope[:a].should == 9

    end
  end
end