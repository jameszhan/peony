module Peony
  module Shell
    SHELL_DELEGATED_METHODS = [:ask, :error, :set_color, :yes?, :no?, :say, :say_status, :print_in_columns, :print_table, :print_wrapped, :file_collision, :terminal_width]
    # The following classes's code was copied from Thor, available under MIT-LICENSE
    # Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
    autoload :Basic, 'peony/shell/basic'
    autoload :Color, 'peony/shell/color'
    autoload :HTML,  'peony/shell/html'
    
    def shell
      @shell ||= Peony::Shell.shell.new
    end
    
    class << self
      # Returns the shell used in all Peony classes. If you are in a Unix platform
      # it will use a colored log, otherwise it will use a basic one without color.
      def shell
        @shell ||= if ENV['PEONY_SHELL'] && ENV['PEONY_SHELL'].size > 0
          Thor::Shell.const_get(ENV['PEONY_SHELL'])
        elsif (RbConfig::CONFIG['host_os'] =~ /mswin|mingw/) && !(ENV['ANSICON'])
          Thor::Shell::Basic
        else
          Thor::Shell::Color
        end
      end

      # Sets the shell used in all Peony classes.
      def shell=(klass)
       @shell = klass
      end
    end
  end
  
end