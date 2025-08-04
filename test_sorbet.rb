#!/usr/bin/env ruby
# typed: strict

require "sorbet-runtime"
require_relative "lib/chobble-forms"

# Test that type checking works
T.assert_type!(ChobbleForms::VERSION, String)

puts "Sorbet type checking is working!"
puts "ChobbleForms version: #{ChobbleForms::VERSION}"