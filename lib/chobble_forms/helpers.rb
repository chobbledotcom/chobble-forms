# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module ChobbleForms
  module Helpers
    extend T::Sig

    SelectOption = T.type_alias do
      [String, T.any(String, Integer)]
    end

    LocalAssignValue = T.type_alias do
      T.any(
        String,
        Symbol,
        Integer,
        Float,
        T::Boolean,
        T::Array[SelectOption],
        T::Hash[Symbol, T.untyped]
      )
    end

    FieldSetupResult = T.type_alias do
      {
        form_object: T.untyped,
        i18n_base: String,
        value: T.untyped,
        prefilled: T::Boolean,
        field_label: String,
        field_hint: T.nilable(String),
        field_placeholder: T.nilable(String)
      }
    end

    sig { params(field: Symbol, local_assigns: T::Hash[Symbol, LocalAssignValue]).returns(FieldSetupResult) }
    def form_field_setup(field, local_assigns)
      validate_local_assigns(local_assigns)
      validate_form_context

      field_translations = build_field_translations(field)
      form_obj = T.unsafe(instance_variable_get(:@_current_form))
      value, prefilled = get_field_value_and_prefilled_status(form_obj, field)

      build_field_setup_result(field_translations, value, prefilled)
    end

    sig { params(form_object: T.untyped, field: Symbol).returns([T.untyped, T::Boolean]) }
    def get_field_value_and_prefilled_status(form_object, field)
      return [nil, false] unless form_object&.object

      model = form_object.object
      resolved = resolve_field_value(model, field)
      [resolved[:value], resolved[:prefilled]]
    end

    sig { params(form: T.untyped, comment_field: Symbol, base_field_label: String).returns(T::Hash[Symbol, T.untyped]) }
    def comment_field_options(form, comment_field, base_field_label)
      raise ArgumentError, "form_object required" unless form

      model = form.object

      comment_value, comment_prefilled =
        get_field_value_and_prefilled_status(
          form,
          comment_field
        )

      has_comment = comment_value.present?

      base_field = comment_field.to_s.chomp("_comment")

      placeholder_text = t("shared.field_comment_placeholder", field: base_field_label)
      textarea_id = "#{base_field}_comment_textarea_#{model.object_id}"
      checkbox_id = "#{base_field}_has_comment_#{model.object_id}"
      display_style = has_comment ? "block" : "none"

      {
        options: {
          rows: 2,
          placeholder: placeholder_text,
          id: textarea_id,
          style: "display: #{display_style};",
          value: comment_value
        },
        prefilled: comment_prefilled,
        has_comment: has_comment,
        checkbox_id: checkbox_id
      }
    end

    sig do
      params(prefilled: T::Boolean, checked_value: T.untyped,
        expected_value: T.untyped).returns(T::Hash[Symbol, T::Boolean])
    end
    def radio_button_options(prefilled, checked_value, expected_value)
      (prefilled && checked_value == expected_value) ? {checked: true} : {}
    end

    private

    ALLOWED_LOCAL_ASSIGNS = T.let(%i[
      accept
      add_not_applicable
      field
      max
      min
      number_options
      options
      preview_size
      required
      rows
      step
      type
    ].freeze, T::Array[Symbol])

    sig { params(local_assigns: T::Hash[Symbol, LocalAssignValue]).void }
    def validate_local_assigns(local_assigns)
      locally_assigned_keys = local_assigns.keys
      disallowed_keys = locally_assigned_keys - ALLOWED_LOCAL_ASSIGNS

      return unless disallowed_keys.any?

      raise ArgumentError, "local_assigns contains #{disallowed_keys.inspect}"
    end

    sig { void }
    def validate_form_context
      i18n_base = T.unsafe(instance_variable_get(:@_current_i18n_base))
      form_obj = T.unsafe(instance_variable_get(:@_current_form))
      raise ArgumentError, "missing i18n_base" unless i18n_base
      raise ArgumentError, "missing form_object" unless form_obj
    end

    sig { params(field: Symbol).returns(T::Hash[Symbol, T.nilable(String)]) }
    def build_field_translations(field)
      i18n_base = T.unsafe(instance_variable_get(:@_current_i18n_base))

      # Only strip _pass suffix for pass/fail fields, not _comment fields
      lookup_field = if field.to_s.end_with?("_pass")
        FieldUtils.strip_field_suffix(field)
      else
        field
      end
      fields_key = "#{i18n_base}.fields.#{lookup_field}"
      field_label = t(fields_key, raise: true)

      base_parts = i18n_base.split(".")
      root = base_parts[0..-2]
      hint_key = (root + ["hints", field]).join(".")
      placeholder_key = (root + ["placeholders", field]).join(".")

      {
        field_label:,
        field_hint: t(hint_key, default: nil),
        field_placeholder: t(placeholder_key, default: nil)
      }
    end

    sig do
      params(field_translations: T::Hash[Symbol, T.nilable(String)], value: T.untyped,
        prefilled: T::Boolean).returns(FieldSetupResult)
    end
    def build_field_setup_result(field_translations, value, prefilled)
      form_obj = T.unsafe(instance_variable_get(:@_current_form))
      i18n_base = T.unsafe(instance_variable_get(:@_current_i18n_base))

      T.cast(
        {
          form_object: form_obj,
          i18n_base: i18n_base,
          value:,
          prefilled:
        }.merge(field_translations),
        FieldSetupResult
      )
    end

    sig { params(model: T.untyped, field: Symbol, raise_if_missing: T::Boolean).returns(T.untyped) }
    def get_field_value_from_model(model, field, raise_if_missing: false)
      return nil unless model

      # Check for base field first (for fields like step_ramp_size that have a base value)
      # Only check for _pass suffix if base field doesn't exist (for pass_fail_comment partials)
      if model.respond_to?(field)
        model.send(field)
      elsif model.respond_to?("#{field}_pass")
        model.send("#{field}_pass")
      elsif raise_if_missing
        available = model.attributes.keys.sort.join(", ")
        raise "Field '#{field}' or '#{field}_pass' not found on " \
              "#{model.class.name}. Available fields: #{available}"
      end
    end

    sig { params(model: T.untyped, field: Symbol).returns({value: T.untyped, prefilled: T::Boolean}) }
    def resolve_field_value(model, field)
      return {value: nil, prefilled: false} if field.to_s.include?("password")

      current_value = get_field_value_from_model(model, field, raise_if_missing: true)

      # Check if this field should not be prefilled based on excluded fields list
      excluded_fields = T.unsafe(instance_variable_get(:@_excluded_prefill_fields))
      return {value: current_value, prefilled: false} if excluded_fields&.include?(field)

      prev_inspection = T.unsafe(instance_variable_get(:@previous_inspection))
      previous_value = extract_previous_value(prev_inspection, model, field)

      if current_value.nil? && !previous_value.nil?
        return {
          value: format_numeric_value(previous_value),
          prefilled: true
        }
      end

      {value: current_value, prefilled: false}
    end

    sig { params(previous_inspection: T.untyped, current_model: T.untyped, field: Symbol).returns(T.untyped) }
    def extract_previous_value(previous_inspection, current_model, field)
      if !previous_inspection
        nil
      elsif current_model.class.name.include?("Assessment")
        assessment_type = current_model.class.name.demodulize.underscore
        previous_model = previous_inspection.send(assessment_type)
        get_field_value_from_model(previous_model, field, raise_if_missing: false)
      else
        previous_inspection.send(field)
      end
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def format_numeric_value(value)
      if value.is_a?(String) &&
          value.match?(/\A-?\d*\.?\d+\z/) &&
          (float_value = Float(value, exception: false))
        value = float_value
      end

      return value unless value.is_a?(Numeric)

      number_with_precision(
        value,
        precision: 4,
        strip_insignificant_zeros: true
      )
    end

    sig { params(value: T.untyped).returns(T.nilable(String)) }
    def strip_trailing_zeros(value)
      value&.to_s&.sub(/\.0+$/, "")
    end

    sig { params(model: T.untyped, field_str: String).returns(T::Hash[Symbol, T.untyped]) }
    def resolve_association_value(model, field_str)
      base_name = field_str.chomp("_id")
      association_name = base_name.to_sym

      if model.respond_to?(association_name)
        {value: model.send(association_name), prefilled: true}
      elsif model.respond_to?(field_str)
        value = model.send(field_str)
        if value && model.class.reflect_on_association(association_name)
          associated = model.class
            .reflect_on_association(association_name)
            .klass.find_by(id: value)
          {value: associated, prefilled: true}
        else
          {value: value, prefilled: true}
        end
      else
        {value: nil, prefilled: false}
      end
    end
  end
end
