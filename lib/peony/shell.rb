module Peony
  module Shell
    SHELL_DELEGATED_METHODS = [:ask, :error, :set_color, :yes?, :no?, :say, :say_status, :print_in_columns,
                               :print_table, :print_wrapped, :file_collision, :terminal_width, :padding]

    # The following classes's code was copied from Thor, available under MIT-LICENSE
    # Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
    autoload :Basic, 'peony/shell/basic'
    autoload :Color, 'peony/shell/color'
    autoload :HTML,  'peony/shell/html'


    # Holds the shell for the given Thor instance. If no shell is given,
    # it gets a default shell from Thor::Base.shell.
    def shell
      @shell ||= if ENV['PEONY_SHELL'] && ENV['PEONY_SHELL'].size > 0
        Peony::Shell.const_get(ENV['PEONY_SHELL']).new
      elsif (RbConfig::CONFIG['host_os'] =~ /mswin|mingw/) && !(ENV['ANSICON'])
        Peony::Shell::Basic.new
      else
        Peony::Shell::Color.new
      end
    end

    # Common methods that are delegated to the shell.
    SHELL_DELEGATED_METHODS.each do |method|
      module_eval <<-METHOD, __FILE__, __LINE__
        def #{method}(*args, &block)
          shell.#{method}(*args, &block)
        end
      METHOD
    end

    # Yields the given block with padding.
    def with_padding
      shell.padding.up
      yield
    ensure
      shell.padding.down
    end

  end

end

