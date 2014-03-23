module Peony
  class Scope < Hash
    class << self
      def scopes
        @scopes ||= Hash.new
      end
    end

    attr_reader :name

    def initialize(name = nil, parent = nil)
      @name = name
      @parent = parent
      self.class.scopes[name] = self
      yield name, self if block_given?
    end

    alias_method :local?, :has_key?

    def [](key)
      super(key) || (@parent && @parent[key])
    end

    ## also change the method key?, include?
    #
    def has_key?(key)
      local?(key) || (!@parent.nil? && @parent.key?(key))
    end

    def []=(key, value)
      if !local?(key) && @parent && @parent.has_key?(key)
        @parent.set key, value
      else
        store(key, value)
      end
    end

    def remove(key, recursively = false)
      delete(key)
      if recursively && @parent
        @parent.remove(key, recursively)
      end
      self
    end

    alias_method :set,      :[]=
    alias_method :local,    :store
    alias_method :include?, :has_key?
    alias_method :key?,     :has_key?

  end
end
