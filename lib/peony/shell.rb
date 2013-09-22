module Peony
  module Shell
    # Asks something to the user and receives a response.
    #
    # If asked to limit the correct responses, you can pass in an
    # array of acceptable answers.  If one of those is not supplied,
    # they will be shown a message stating that one of those answers
    # must be given and re-asked the question.
    #
    # ==== Example
    # ask("What is your name?")
    #
    # ask("What is your favorite Neopolitan flavor?", :limited_to => ["strawberry", "chocolate", "vanilla"])
    #
    def ask(statement, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options[:limited_to] ? ask_filtered(statement, options[:limited_to], *args) : ask_simply(statement, *args)
    end
    
    # Say (print) something to the user. If the sentence ends with a whitespace
    # or tab character, a new line is not appended (print + flush). Otherwise
    # are passed straight to puts (behavior got from Highline).
    #
    # ==== Example
    # say("I know you knew that.")
    #
    def say(message="", color=nil, force_new_line=(message.to_s !~ /( |\t)\Z/))
      message = message.to_s

      message = set_color(message, *color) if color && can_display_colors?

      spaces = "  " * padding

      if force_new_line
        stdout.puts(spaces + message)
      else
        stdout.print(spaces + message)
      end
      stdout.flush
    end

    # Say a status with the given color and appends the message. Since this
    # method is used frequently by actions, it allows nil or false to be given
    # in log_status, avoiding the message from being shown. If a Symbol is
    # given in log_status, it's used as the color.
    #
    def say_status(status, message, log_status=true)
      return if quiet? || log_status == false
      spaces = "  " * (padding + 1)
      color  = log_status.is_a?(Symbol) ? log_status : :green

      status = status.to_s.rjust(12)
      status = set_color status, color, true if color

      stdout.puts "#{status}#{spaces}#{message}"
      stdout.flush
    end
    
    
    # Make a question the to user and returns true if the user replies "y" or
    # "yes".
    #
    def yes?(statement, color=nil)
      !!(ask(statement, color) =~ is?(:yes))
    end

    # Make a question the to user and returns true if the user replies "n" or
    # "no".
    #
    def no?(statement, color=nil)
      !yes?(statement, color)
    end
    
    protected
      def stdout
        $stdout
      end

      def stdin
        $stdin
      end

      def stderr
        $stderr
      end
    
  end
end