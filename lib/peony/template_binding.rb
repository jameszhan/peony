module Peony
  class TemplateBinding

    def initialize(settings)
      @settings = settings
    end
    
    def context_binding
      binding
    end
    
    def method_missing(meth, *args, &blk)
      val = @settings.send(meth, *args, &blk) 
      if val == nil
        super
      else
        val
      end
    end
    
  end
end