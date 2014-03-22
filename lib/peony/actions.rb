module Peony
  module Actions
    def self.included(base)
      base.extend ClassMethods
    end
        
    module ClassMethods
      def source_paths
        ["#{Dir.pwd}/templates", File.expand_path('../../templates', __dir__)]
      end    
    end
    
    
    # Do something in the root or on a provided subfolder. If a relative path
    # is given it's referenced from the current root. The full path is yielded
    # to the block you provide. The path is set back to the previous path when
    # the method exits.
    #
    # ==== Parameters
    # dir<String>:: the directory to move to.
    # config<Hash>:: give :verbose => true to log and use padding.
    #
    def inside(dir='', config={}, &block)
      verbose = config.fetch(:verbose, false)
      pretend = options[:pretend]

      say_status :inside, dir, verbose
      shell.padding += 1 if verbose
      @destination_stack.push File.expand_path(dir, destination_root)

      # If the directory doesnt exist and we're not pretending
      if !File.exist?(destination_root) && !pretend
        FileUtils.mkdir_p(destination_root)
      end

      if pretend
        # In pretend mode, just yield down to the block
        block.arity == 1 ? yield(destination_root) : yield
      else
        FileUtils.cd(destination_root) { block.arity == 1 ? yield(destination_root) : yield }
      end

      @destination_stack.pop
      shell.padding -= 1 if verbose
    end
    
    # Loads an external file and execute it in the instance binding.
    #
    # ==== Parameters
    # path<String>:: The path to the file to execute. Can be a web address or
    #                a relative path from the source root.
    #
    # ==== Examples
    #
    #   apply "http://gist.github.com/103208"
    #
    #   apply "recipes/jquery.rb"
    #
    def apply(path, config={})
      verbose = config.fetch(:verbose, true)
      is_uri  = path =~ /^https?\:\/\//
      path    = find_in_source_paths(path) unless is_uri

      say_status :apply, path, verbose
      shell.padding += 1 if verbose

      if is_uri
        contents = open(path, "Accept" => "application/x-peony-template") {|io| io.read }
      else
        contents = open(path) {|io| io.read }
      end

      instance_eval(contents, path)
      shell.padding -= 1 if verbose
    end
    
    # Executes a command returning the contents of the command.
    #
    # ==== Parameters
    # command<String>:: the command to be executed.
    # config<Hash>:: give :verbose => false to not log the status, :capture => true to hide to output. Specify :with
    #                to append an executable to command executation.
    #
    # ==== Example
    #
    #   inside('vendor') do
    #     run('ln -s ~/edge rails')
    #   end
    #
    def run(command, config={})
      return unless behavior == :invoke

      destination = relative_to_original_destination_root(destination_root, false)
      desc = "#{command} from #{destination.inspect}"

      if config[:with]
        desc = "#{File.basename(config[:with].to_s)} #{desc}"
        command = "#{config[:with]} #{command}"
      end

      say_status :run, desc, config.fetch(:verbose, true)

      unless options[:pretend]
        config[:capture] ? `#{command}` : system("#{command}")
      end
    end
      
  end
end

