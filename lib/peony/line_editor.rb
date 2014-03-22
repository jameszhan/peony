# The following classes's code was copied from Thor, available under MIT-LICENSE
# Copyright (c) 2008 Yehuda Katz, Eric Hodel, et al.
require 'peony/line_editor/basic'
require 'peony/line_editor/readline'

module Peony
  module LineEditor
    def self.readline(prompt, options = {})
      best_available.new(prompt, options).readline
    end

    def self.best_available
      [Peony::LineEditor::Readline, Peony::LineEditor::Basic].detect(&:available?)
    end
  end
end