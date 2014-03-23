module Peony
  class Settings
    attr_reader :root_scope

    def initialize
      @root_scope = Scope.new(:root)
    end

    def current_scope
      @current_scope ||= @root_scope
    end

    def include?(key)
      current_scope.include? key
    end

    def method_missing(method, *args, &block)
      name = method.to_s
      key, punct = name[0..-2].to_sym, name[-1..-1]
      case punct
      when '='
        current_scope[key] = args.first != nil ? args.first : block
      when '?'
        current_scope.include? key
      when '!'
        raise Error, "Setting :#{key} is not set" unless current_scope.include?(key)
        evaluate current_scope[key]
      else
        if current_scope.include? method
          evaluate current_scope[method]
        else
          block.call unless block.nil? 
        end
      end
    end

    def method_missing1(method, *args, &block)
      name = method.to_s
      key, punct = name[0..-2].to_sym, name[-1..-1]
      case punct
        when '='
          self[key] = args.first != nil ? args.first : block
        when '?'
          include? key
        when '!'
          raise Error, "Setting :#{key} is not set" unless include?(key)
          evaluate self[key]
        else
          if include? method
            evaluate self[method]
          else
            block.call unless block.nil?
          end
      end
    end


    def evaluate(value)
      if value.is_a?(Proc)
        value.call
      else
        value
      end
    end
  end
end