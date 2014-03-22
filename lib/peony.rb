require 'peony/version'
require 'peony/application'

module Peony
  PREFIX = File.dirname(__FILE__)
  ROOT = File.expand_path('../../', __FILE__)

  autoload :Utils,      'peony/utils'
  autoload :Shell,      'peony/shell'
  autoload :Actions,    'peony/actions'
  autoload :LineEditor, 'peony/line_editor'
  autoload :Settings,   'peony/settings'
  
  Error = Class.new(Exception)
  
  def self.root_path(*a)
    File.join ROOT, *a
  end
end
