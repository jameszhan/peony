require 'spec_helper'

describe Peony do
  describe 'Shell' do
    it 'should can print something with colors' do
      peony do
        say_status :success, 'say_status: Unintall it.', :green
        say_status :failure, 'say_status: No premission', :red

        print_in_columns %w{A BB CCC DDDD EEEEE FFFFFF GGGGGGG}

        print_table [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

        print_wrapped 'print_wrapped: I know you knew that.', indent: 16

        say 'say: I know you knew that.', :yellow, false
        say 'say: I know you knew that.', :blue, true

        error 'error: I know you knew that.'
      end
    end
  end

  describe 'Actions' do
    it 'should can run command' do
      peony do
        run "echo 'Hello World!'"
        run 'ls -l'

        inside 'lib/peony' do
          run 'ls -l'
        end

        report_time do
          inside 'lib/peony' do
            run 'ls -la'
          end
          run 'ls -la'
        end
      end
    end
  end

  
end