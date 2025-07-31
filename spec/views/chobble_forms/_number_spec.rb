require "spec_helper"

RSpec.describe "Number partial (_number.html.erb)" do
  let(:helper_class) do
    Class.new do
      include ChobbleForms::Helpers
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::NumberHelper
      include ActionView::Context

      attr_accessor :_current_form, :_current_i18n_base

      def output_buffer
        @output_buffer ||= ActionView::OutputBuffer.new
      end

      attr_writer :output_buffer

      def t(key, options = {})
        "Test #{key}"
      end
    end
  end

  let(:helper) { helper_class.new }
  let(:mock_form) { double("FormBuilder", field_id: ->(field) { "form_#{field}" }, object: nil) }

  before do
    helper._current_form = mock_form
    helper._current_i18n_base = "test.forms"
  end

  describe "#form_field_setup" do
    it "returns field data with label and placeholder" do
      result = helper.form_field_setup(:amount, {})

      expect(result).to include(:field_label, :field_placeholder)
      expect(result).to be_a(Hash)
    end
  end

  describe "#strip_trailing_zeros" do
    it "removes trailing zeros only after decimal point" do
      expect(helper.send(:strip_trailing_zeros, 25.0)).to eq("25")
      expect(helper.send(:strip_trailing_zeros, 100.00)).to eq("100")
      expect(helper.send(:strip_trailing_zeros, "25.0")).to eq("25")
      expect(helper.send(:strip_trailing_zeros, "100.000")).to eq("100")
    end

    it "preserves non-zero decimal places" do
      expect(helper.send(:strip_trailing_zeros, 25.50)).to eq("25.5")
      expect(helper.send(:strip_trailing_zeros, 25.123)).to eq("25.123")
      expect(helper.send(:strip_trailing_zeros, 0.5)).to eq("0.5")
      expect(helper.send(:strip_trailing_zeros, "25.50")).to eq("25.50")
    end

    it "handles edge cases" do
      expect(helper.send(:strip_trailing_zeros, nil)).to be_nil
      expect(helper.send(:strip_trailing_zeros, 0)).to eq("0")
      expect(helper.send(:strip_trailing_zeros, 0.0)).to eq("0")
    end
  end
end
