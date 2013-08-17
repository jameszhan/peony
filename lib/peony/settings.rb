module Peony
  class Settings < Hash
    def method_missing(method, *args, &block)
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
        ret = evaluate self[method]
        ret = block.call unless block.nil?
        ret
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
