require 'peony/version'
require 'peony/application'

module Peony
  PREFIX = File.dirname(__FILE__)
  ROOT = File.expand_path('../../', __FILE__)

  autoload :Scope,      'peony/scope'
  autoload :Settings,   'peony/settings'
  autoload :Configure,  'peony/configure'

  autoload :Shell,      'peony/shell'
  autoload :LineEditor, 'peony/line_editor'
  autoload :Actions,    'peony/actions'

  
  Error = Class.new(Exception)
  
  def self.root_path(*a)
    File.join ROOT, *a
  end
end
