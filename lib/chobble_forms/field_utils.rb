# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module ChobbleForms
  module FieldUtils
    extend T::Sig

    sig { params(field: T.any(Symbol, String)).returns(String) }
    def self.strip_field_suffix(field)
      field.to_s.gsub(/_pass$|_comment$/, "")
    end

    sig { params(field: T.any(Symbol, String), partial: T.any(Symbol, String)).returns(T::Array[String]) }
    def self.get_composite_fields(field, partial)
      fields = T.let([], T::Array[String])
      partial_str = partial.to_s

      if partial_str.include?("pass_fail") && !field.to_s.end_with?("_pass")
        fields << "#{field}_pass"
      end

      if partial_str.include?("comment")
        base = field.to_s.end_with?("_pass") ? strip_field_suffix(field) : field
        fields << "#{base}_comment"
      end

      fields
    end

    sig { params(field: T.any(Symbol, String)).returns(T::Boolean) }
    def self.is_pass_field?(field)
      field.to_s.end_with?("_pass")
    end

    sig { params(field: T.any(Symbol, String)).returns(T::Boolean) }
    def self.is_comment_field?(field)
      field.to_s.end_with?("_comment")
    end

    sig { params(field: T.any(Symbol, String)).returns(T::Boolean) }
    def self.is_composite_field?(field)
      is_pass_field?(field) || is_comment_field?(field)
    end

    sig { params(field: T.any(Symbol, String)).returns(String) }
    def self.base_field_name(field)
      strip_field_suffix(field)
    end

    sig { params(form: T.any(Symbol, String), field: T.any(Symbol, String)).returns(String) }
    def self.form_field_label(form, field)
      I18n.t("forms.#{form}.fields.#{field}")
    end
  end
end
