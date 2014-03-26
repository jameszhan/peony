module Peony
  class Scope < Hash
    attr_reader :name

    def initialize(name = nil, parent = nil)
      @name = name
      @parent = parent
      yield name, self if block_given?
    end

    alias_method :local?, :has_key?

    def [](key)
      super || (@parent && @parent[key])
    end

    ## also change the method key?, include?, member?
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

    def respond_to_missing?(method, _ = true)
      self.include?(method) || method.to_s =~ /[a-z]\w*[?=!]?$/
    end

    alias_method :set,      :[]=
    alias_method :local,    :store

    alias_method :include?, :has_key?
    alias_method :key?,     :has_key?
    alias_method :member?,  :has_key?


    def method_missing(method, *args, &block)
      return evaluate(self.[](method), &block) if has_key?(method)
      match = method.to_s.match(/(.*?)([?=!]?)$/)
      case match[2]
        when '='
          #self[match[1].to_sym] = args.first || block
          local(match[1].to_sym, args.first || block)
        when '?'
          !!self[match[1].to_sym]
        when '!'
          evaluate(fetch(match[1].to_sym), &block)  #just fetch local key
        else
          evaluate(self[match[1]], &block)          #support string key
      end
    end

    def evaluate(value)
      ret = value.is_a?(Proc) ? value.call : value
      ret.nil? && block_given? ? yield : ret
    end

    def new_scope(name)
      clazz = self.class
      self.send(name) || Scope.new(name, self) do|_name, _scope|
        clazz.send :define_method, _name do
          _scope
        end
      end
    end

  end
end
