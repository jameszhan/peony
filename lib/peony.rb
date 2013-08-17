require "peony/version"

module Peony
  PREFIX = File.dirname(__FILE__)
  ROOT = File.expand_path('../../', __FILE__)

  autoload :Utils, 'peony/utils'
  autoload :Settings, 'peony/settings'
 
  
  Error = Class.new(Exception)
  
  def self.root_path(*a)
    File.join ROOT, *a
  end
end
