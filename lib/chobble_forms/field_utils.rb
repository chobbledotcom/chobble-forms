# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module ChobbleForms
  module FieldUtils
    extend T::Sig

    sig { params(field: Symbol).returns(Symbol) }
    def self.strip_field_suffix(field)
      field.to_s.gsub(/_pass$|_comment$/, "").to_sym
    end

    sig { params(field: Symbol, partial: Symbol).returns(T::Array[Symbol]) }
    def self.get_composite_fields(field, partial)
      fields = T.let([], T::Array[Symbol])
      partial_str = partial.to_s

      fields << :"#{field}_pass" if partial_str.include?("pass_fail") && !field.to_s.end_with?("_pass")

      if partial_str.include?("comment")
        base = field.to_s.end_with?("_pass") ? strip_field_suffix(field) : field
        fields << :"#{base}_comment"
      end

      fields
    end

    sig { params(field: Symbol).returns(T::Boolean) }
    def self.is_pass_field?(field)
      field.to_s.end_with?("_pass")
    end

    sig { params(field: Symbol).returns(T::Boolean) }
    def self.is_comment_field?(field)
      field.to_s.end_with?("_comment")
    end

    sig { params(field: Symbol).returns(T::Boolean) }
    def self.is_composite_field?(field)
      is_pass_field?(field) || is_comment_field?(field)
    end

    sig { params(field: Symbol).returns(Symbol) }
    def self.base_field_name(field)
      strip_field_suffix(field)
    end

    sig { params(form: Symbol, field: Symbol).returns(String) }
    def self.form_field_label(form, field)
      I18n.t("forms.#{form}.fields.#{field}")
    end

    sig { params(assessment_key: Symbol).returns(Symbol) }
    def self.form_name_from_assessment(assessment_key)
      assessment_key.to_s.gsub(/_assessment$/, "").to_sym
    end
  end
end
