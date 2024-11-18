require "tty-prompt"

module Heal::Cli
end

PROMPT = TTY::Prompt.new(interrupt: :exit)
