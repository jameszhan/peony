module Peony
  module Utils
    
    def parse_args
      ARGV.each do|arg|
        set $1.strip.to_sym, $2 if arg =~ /([^=]+)=(.+)/
      end
    end

    def template(from, to, override=false, sudo=false)
      template = find_templates(from).first
      raise "Can't find tempalte #{from} in directory #{template_paths}." unless template
      raise "File #{to} have already exists." if !override && File.exists?(to)
      say "copy #{template} to #{to}", :green

      target = sudo ? "/tmp/peony-#{rand(10000)}" : to
      open(target, 'w+') do|out|
        out.write(erb(template))
      end
      sudo "mv #{tmp} #{to}" if sudo
    end

    # ### erb
    # Evaluates an ERB block in the current scope and returns a string.
    #
    #     a = 1
    #     b = 2
    #
    #     # Assuming foo.erb is <%= a %> and <%= b %>
    #     puts erb('foo.erb')
    #
    #     #=> "1 and 2"
    #
    # Returns the output string of the ERB template.
    def erb(file, b=binding)
      require 'erb'
      ERB.new(File.read(file), nil, '-').result(b)
    end

    # ### set
    # Sets settings.
    # Sets given symbol `key` to value in `value`.
    #
    # Returns the value.
    #
    #     set :domain, 'kickflip.me'
    def set(key, *args, &block)
      settings.send :"#{key}=", *args, &block
    end

    # ### set_default
    # Sets default settings.
    # Sets given symbol `key` to value in `value` only if the key isn't set yet.
    #
    # Returns the value.
    #
    #     set_default :term_mode, :pretty
    #     set :term_mode, :system
    #     settings.term_mode.should == :system
    #
    #     set :term_mode, :system
    #     set_default :term_mode, :pretty
    #     settings.term_mode.should == :system
    def set_default(key, *args, &block)
      set(key, *args, block) unless settings.send(:local?, key.to_sym)
    end

    # ### settings
    # Accesses the settings hash.
    #
    #     set :domain, 'kickflip.me'
    #
    #     settings.domain  #=> 'kickflip.me'
    #     domain           #=> 'kickflip.me'
    def settings
      @settings ||= Settings.new
    end

    def scope(name)
      settings.with_scope(name.to_sym) do
        yield
      end
    end

    def template_paths
      ["#{Dir.pwd}/templates", File.expand_path('../../templates', __dir__)]
    end

    def find_templates(name, file_only=true)
      find_in_directories(template_paths, name, file_only)
    end

    def recipes_paths
      ["#{Dir.pwd}/recipes", File.expand_path('../../recipes', __dir__)]
    end

    def find_recipes(name, file_only=true)
      find_in_directories(recipes_paths, name, file_only)
    end

    def find_in_directories(paths, name, file_only)
      templates = []
      paths.each do|path|
        templates += Dir[File.expand_path(name, path)].reject{|filename| file_only && File.directory?(filename)}
      end
      templates
    end


    # ### method_missing
    # Hook to get settings.
    # See #settings for an explanation.
    #
    # Returns things.
    def method_missing(method, *args, &blk)
      if settings.respond_to? method, true
        settings.__send__(method, *args, &blk)
      else
        super
      end
    end

  end
end
