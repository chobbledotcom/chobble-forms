#!/usr/bin/env ruby
# typed: strict

require "sorbet-runtime"
require_relative "lib/chobble-forms"

# Test that the module loads and types are correct
T.assert_type!(ChobbleForms::VERSION, String)

# Test FieldUtils methods
base = ChobbleForms::FieldUtils.strip_field_suffix(:test_pass)
T.assert_type!(base, String)

is_pass = ChobbleForms::FieldUtils.is_pass_field?(:test_pass)
T.assert_type!(is_pass, T::Boolean)

puts "✅ Sorbet type checking successful!"
puts "Version: #{ChobbleForms::VERSION}"
