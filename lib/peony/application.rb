require 'rake'

module Rake
  class Application
    alias_method :origin_find_rakefile_location, :find_rakefile_location
    def find_rakefile_location
      ret = origin_find_rakefile_location
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