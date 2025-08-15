require "rails_helper"

RSpec.describe "Symbol strictness enforcement", type: :view do
  let(:test_model) do
    Class.new do
      include ActiveModel::Model
      attr_accessor :test_field
      def persisted? = false

      def self.name = "TestModel"
    end.new
  end

  before do
    view.form_with(model: test_model, url: "/", local: true) do |f|
      @_current_form = f
      ""
    end
    @_current_i18n_base = "test.forms"

    I18n.backend.store_translations(:en, {
      test: {
        forms: {
          fields: {
            test_field: "Test Field"
          }
        }
      }
    })
  end

  describe "field name validation" do
    it "accepts symbol field names" do
      expect {
        render partial: "chobble_forms/text_field", locals: {field: :test_field}
      }.not_to raise_error
    end

    it "rejects string field names via Sorbet type checking" do
      # Sorbet's strict typing catches string fields at the parameter level
      expect {
        render partial: "chobble_forms/text_field", locals: {field: "test_field"}
      }.to raise_error(ActionView::Template::Error, /Expected type Symbol, got type String/)
    end

    it "rejects non-snake_case symbol field names" do
      expect {
        render partial: "chobble_forms/text_field", locals: {field: :TestField}
      }.to raise_error(ActionView::Template::Error, /Field names must be snake_case symbols/)
    end

    it "validates field consistency between parameter and local_assigns" do
      # Direct test of the validation method
      helper = Object.new.extend(ChobbleForms::Helpers)

      expect {
        helper.send(:validate_local_assigns, :test_field, {field: :different_field})
      }.to raise_error(ArgumentError, /Field parameter.*doesn't match/)
    end
  end

  describe "FieldUtils symbol enforcement" do
    it "expects symbols for all field utility methods" do
      expect(ChobbleForms::FieldUtils.strip_field_suffix(:test_pass)).to eq(:test)
      expect(ChobbleForms::FieldUtils.is_pass_field?(:test_pass)).to be true
      expect(ChobbleForms::FieldUtils.is_comment_field?(:test_comment)).to be true
      expect(ChobbleForms::FieldUtils.base_field_name(:test_pass)).to eq(:test)
    end
  end
end
