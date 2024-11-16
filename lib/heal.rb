# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load_namespace(Heal::Cli) # We need all commands loaded.

module Heal
  class Error < StandardError; end
end
