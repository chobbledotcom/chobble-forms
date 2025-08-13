# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module ChobbleForms
  extend T::Sig

  VERSION = T.let("0.5.6", String)
end
