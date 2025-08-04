# typed: strict
# frozen_string_literal: true

require_relative "chobble_forms/version"

# Only require sorbet-runtime if it's available
begin
  require "sorbet-runtime"
rescue LoadError
  # Sorbet runtime is optional
end

require_relative "chobble_forms/engine"
require_relative "chobble_forms/helpers"

module ChobbleForms
  extend T::Sig if defined?(T::Sig)
end
