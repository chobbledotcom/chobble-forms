#!/usr/bin/env ruby
# typed: strict

require "sorbet-runtime"
require_relative "lib/chobble-forms"

# Test that the module loads and types are correct
T.assert_type!(ChobbleForms::VERSION, String)

# Test FieldUtils methods - all use symbols now!
base = ChobbleForms::FieldUtils.strip_field_suffix(:test_pass)
T.assert_type!(base, String)

is_pass = ChobbleForms::FieldUtils.is_pass_field?(:test_pass)
T.assert_type!(is_pass, T::Boolean)

# Symbol-only API is enforced by type signatures
fields = ChobbleForms::FieldUtils.get_composite_fields(:my_field, :pass_fail_comment)
T.assert_type!(fields, T::Array[String])

# This would fail at type-check time:
# ChobbleForms::FieldUtils.is_pass_field?("string_field") # ❌ Type error!

puts "✅ Sorbet type checking successful!"
puts "Version: #{ChobbleForms::VERSION}"
puts "API: Symbols-only for cleaner, more consistent code"
