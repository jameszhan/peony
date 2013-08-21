require 'peony/template_binding'

module Peony
  module Utils
        
    def sudo(cmd, &block)
      run "sudo #{cmd}", &block
    end
    
    def run(cmd)
      sh cmd do|res, stat|
        if block_given?
          yield res, stat
        else
          puts stat.inspect unless res
        end
      end
    end
    
    def mkdir_p(*dirs)
      dirs.each do|dir|
        if !FileTest.exists?(dir)
          FileUtils.mkdir_p(dir)
        end
        fail "#{dir} must be a directory!" unless FileTest.directory?(dir)
      end
    end

    # ### invoke
    # Invokes another Rake task.
    #
    # Invokes the task given in `task`. Returns nothing.
    #
    #     invoke :'git:clone'
    #     invoke :restart
    #
    # Options:
    #   reenable (bool) - Execute the task even next time.
    #
    def invoke(task, options = {})
      Rake.application.invoke_task task
      Rake::Task[task].reenable if options[:reenable]
    end
    
    def template(from, to, override=false)
      template = find_templates(from).first
      raise "Can't find tempalte #{from} in directory #{search_paths}." unless template
      raise "File #{to} have already exists." if !override && File.exists?(to)
      puts "copy #{template} to #{to}"
      open(to, "w+") do|out|
        out.write(erb(template, template_binding))
      end
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
      ERB.new(File.read(file), nil, "-").result(b)
    end

    # ### report_time
    # Report time elapsed in the block.
    # Returns the output of the block.
    #
    #     report_time do
    #       sleep 2
    #       # do other things
    #     end
    #
    #     # Output:
    #     # Elapsed time: 2.00 seconds
    def report_time(&blk)
      time, output = measure &blk
      print_str "Elapsed time: %.2f seconds" % [time]
      output
    end

    # ### measure
    # Measures the time (in seconds) a block takes.
    # Returns a [time, output] tuple.
    def measure(&blk)
      t = Time.now
      output = yield
      [Time.now - t, output]
    end

    # ### error
    # __Internal:__ Prints to stdout.
    # Consider using `print_error` instead.
    def error(str)
      $stderr.write "#{str}\n"
    end

    # ### echo_cmd
    # Converts a bash command to a command that echoes before execution.
    # Used to show commands in verbose mode. This does nothing unless verbose mode is on.
    #
    # Returns a string of the compound bash command, typically in the format of
    # `echo xx && xx`. However, if `verbose_mode?` is false, it returns the
    # input string unharmed.
    #
    #     echo_cmd("ln -nfs releases/2 current")
    #     #=> echo "$ ln -nfs releases/2 current" && ln -nfs releases/2 current
    def echo_cmd(str)
      if verbose_mode?
        require 'shellwords'
        "echo #{Shellwords.escape("$ " + str)} &&\n#{str}"
      else
        str
      end
    end
    
    # ### set
    # Sets settings.
    # Sets given symbol `key` to value in `value`.
    #
    # Returns the value.
    #
    #     set :domain, 'kickflip.me'
    def set(key, *args, &block)
      settings.send :"#{key}=", *args, block
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
      set(key, *args, block) unless settings.send(:"#{key}?")
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
    
    def search_paths
      ["#{Dir.pwd}/templates", File.expand_path("../../templates", __dir__)]
    end    
    
    def find_templates(name, file_only=true)
      templates = []
      search_paths.each do|path|
        templates += Dir[File.expand_path(name, path)].reject{|filename| file_only && File.directory?(filename) }
      end
      templates
    end

    # ### method_missing
    # Hook to get settings.
    # See #settings for an explanation.
    #
    # Returns things.
    def method_missing(meth, *args, &blk)
      settings.send meth, *args
    end

    private
      def template_binding
        @template_binding ||= TemplateBinding.new(settings)
        @template_binding.context_binding
      end
  end
end
