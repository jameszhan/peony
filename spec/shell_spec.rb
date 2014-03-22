require 'spec_helper'
require 'peony/shell'

describe Peony::Shell do
  
  it :ask do
    ask('What is your favorite Neopolitan flavor?', :limited_to => %w[strawberry chocolate vanilla])
  end
  
end