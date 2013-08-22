module Rake
  class Application
    
    def find_rakefile_location
      ret = super
      unless ret
        if ENV["peony_root"]
          Dir.chdir(ENV["peony_root"])
          if fn = have_rakefile
            ret = [fn, Dir.pwd]
          end
        end
      end
      ret
    ensure
      Dir.chdir(Rake.original_dir)
    end
    
  end
end