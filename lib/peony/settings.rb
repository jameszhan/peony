module Peony
  class Settings
    attr_reader :current_scope, :root_scope

    def initialize
      @current_scope = @root_scope = Scope.new(:root)
    end

    def with_scope(name)
      original_scope = current_scope
      begin
        @current_scope = original_scope.new_scope(name)
        yield
      ensure
        @current_scope = original_scope
      end
    end

    def method_missing(method, *args, &block)
      if current_scope.respond_to?(method, false)
        current_scope.__send__(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_all = true)
      current_scope.respond_to?(method, include_all)
    end

  end
end