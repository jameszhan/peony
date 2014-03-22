require 'spec_helper'
require 'peony/shell'

describe Peony::Shell do

  before :each do
    @shell = Peony::Shell.shell
  end
  
  it :ask do
    @shell.ask('What is your favorite Neopolitan flavor?', :limited_to => %w[strawberry chocolate vanilla])
  end
  
end