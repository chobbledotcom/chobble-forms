#!/usr/bin/env ruby
# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"
require "chobble-forms"

# Example of using ChobbleForms with Sorbet type checking
class TypedFormExample
  extend T::Sig
  include ChobbleForms::Helpers

  sig { params(field_name: Symbol).returns(String) }
  def get_field_label(field_name)
    # This will be type-checked at both development and runtime
    ChobbleForms::FieldUtils.form_field_label(:my_form, field_name)
  end

  sig { params(field: Symbol).returns(T::Boolean) }
  def is_special_field?(field)
    # Type-safe boolean return
    ChobbleForms::FieldUtils.is_pass_field?(field) ||
      ChobbleForms::FieldUtils.is_comment_field?(field)
  end

  sig { params(field: Symbol, partial: Symbol).returns(T::Array[String]) }
  def get_related_fields(field, partial)
    # Returns strongly typed array of strings
    ChobbleForms::FieldUtils.get_composite_fields(field, partial)
  end

  sig { params(field: Symbol).void }
  def process_field(field)
    base_name = ChobbleForms::FieldUtils.base_field_name(field)
    puts "Processing field: #{base_name}"

    if is_special_field?(field)
      puts "  This is a special field (pass/comment)"
    end

    related = get_related_fields(field, :pass_fail_comment)
    if related.any?
      puts "  Related fields: #{related.join(", ")}"
    end
  end
end

# Usage example
if __FILE__ == $0
  example = TypedFormExample.new

  # These calls are all type-safe
  example.process_field(:inspection_date)
  example.process_field(:safety_check_pass)
  example.process_field(:notes_comment)

  # This would cause a type error if uncommented:
  # example.process_field("string_not_symbol") # Type error! Expected Symbol

  puts "\n✅ All type checks passed!"
end
