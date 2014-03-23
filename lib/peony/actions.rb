module Peony
  module Actions

    def destination_root
      @destination_stack ||= [File.expand_path(Dir.pwd || '')]
      @destination_stack.last
    end

    # Returns the given path relative to the absolute root (ie, root where
    # the script started).
    #
    def relative_to_original_destination_root(path, remove_dot = true)
      path = path.dup
      if path.gsub!(@destination_stack[0], '.')
        remove_dot ? (path[2..-1] || '') : path
      else
        path
      end
    end

    def mkdir_p(*dirs)
      dirs.each do|dir|
        say "mkdir #{dir}", :yellow, true
        FileUtils.mkdir_p(dir) if !FileTest.exists?(dir)
        fail "#{dir} must be a directory!" unless FileTest.directory?(dir)
      end
    end

    def sudo(cmd)
      run "sudo #{cmd}"
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
      say 'Elapsed time: %.2f seconds' % [time], :yellow
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
    def invoke(task, config = {})
      Rake.application.invoke_task task
      Rake::Task[task].reenable if config[:reenable]
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
      dry_run = ENV['dry-run']

      say_status :inside, dir, verbose
      self.padding.up if verbose
      @destination_stack.push File.expand_path(dir, destination_root)

      # If the directory doesnt exist and we're not pretending
      if !File.exist?(destination_root) && !pretend
        FileUtils.mkdir_p(destination_root)
      end

      if dry_run
        # In dry_run mode, just yield down to the block
        block.arity == 1 ? yield(destination_root) : yield
      else
        FileUtils.cd(destination_root) { block.arity == 1 ? yield(destination_root) : yield }
      end

      @destination_stack.pop
      self.padding.down if verbose
    end


    # Goes to the root and execute the given block.
    #
    def in_root
      inside(@destination_stack.first) { yield }
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
      path    = find_recipes(path).first unless is_uri

      say_status :apply, path, verbose
      self.padding.up if verbose

      if is_uri
        contents = open(path, 'Accept' => 'application/x-peony-template') {|io| io.read }
      else
        contents = open(path) {|io| io.read }
      end

      instance_eval(contents, path)
      self.padding.down if verbose
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
      destination = relative_to_original_destination_root(destination_root, false)
      desc = "#{command} from #{destination.inspect}"

      if config[:with]
        desc = "#{File.basename(config[:with].to_s)} #{desc}"
        command = "#{config[:with]} #{command}"
      end

      say_status :run, desc, config.fetch(:verbose, true)

      unless ENV['dry-run']
        config[:capture] ? `#{command}` : system("#{command}")
      end
    end

  end
end

