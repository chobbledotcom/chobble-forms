# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sorbet Integration" do
  context "when sorbet-runtime is available" do
    before do
      skip "Sorbet runtime not available" unless defined?(T)
    end

    it "extends modules with T::Sig" do
      expect(ChobbleForms).to respond_to(:sig) if defined?(T::Sig)
      expect(ChobbleForms::Helpers).to respond_to(:sig) if defined?(T::Sig)
    end

    it "defines sig methods on helpers" do
      # Check that signature methods are defined when Sorbet is available
      helper_class = Class.new { include ChobbleForms::Helpers }
      helper = helper_class.new

      # These methods should still work even with signatures
      expect(helper).to respond_to(:form_field_setup)
      expect(helper).to respond_to(:get_field_value_and_prefilled_status)
      expect(helper).to respond_to(:comment_field_options)
      expect(helper).to respond_to(:radio_button_options)
    end
  end

  context "when sorbet-runtime is not available" do
    it "loads the gem successfully" do
      expect { require "chobble-forms" }.not_to raise_error
    end

    it "defines all required modules and classes" do
      expect(defined?(ChobbleForms)).to be_truthy
      expect(defined?(ChobbleForms::VERSION)).to be_truthy
      expect(defined?(ChobbleForms::Engine)).to be_truthy
      expect(defined?(ChobbleForms::Helpers)).to be_truthy
    end

    it "allows helper methods to work without Sorbet" do
      helper_class = Class.new do
        include ChobbleForms::Helpers
        attr_accessor :_current_form, :_current_i18n_base

        def t(key, options = {})
          "Translated: #{key}"
        end
      end

      helper = helper_class.new
      expect(helper).to respond_to(:form_field_setup)
      expect(helper).to respond_to(:radio_button_options)
    end
  end
end
