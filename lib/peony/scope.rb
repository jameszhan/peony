module Peony
  class Scope < Hash
    def initialize(parent = nil)
      @parent = parent
    end

    alias_method :local?, :key?

    def [](key)
      super(key) || (@parent && @parent[key])
    end

    def key?(key)
      local?(key) || (!@parent.nil? && @parent.key?(key))
    end

    def []=(key, value)
      if !local?(key) && @parent && @parent.key?(key)
        @parent.set key, value
      else
        store(key, value)
      end
    end

    def remove(key, recursively = false)
      delete(key)
      if (recursively && @parent)
        @parent.remove(key, recursively)
      end
      self
    end

    alias_method :set, :[]=
    alias_method :local, :store

  end
end
