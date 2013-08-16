require 'singleton'

module Peony
  class Configuration  
    attr_accessor :debug, :logger, :dry_run

    def initialize(options={}) #:nodoc:
      @debug = false
      @dry_run = false
      @logger = Logger.new(options)
    end
    
      
    include Singleton, Variables
    
  end
end