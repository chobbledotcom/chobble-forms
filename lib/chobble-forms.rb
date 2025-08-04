# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require_relative "chobble_forms/version"
require_relative "chobble_forms/engine"
require_relative "chobble_forms/helpers"

module ChobbleForms
  extend T::Sig
end
