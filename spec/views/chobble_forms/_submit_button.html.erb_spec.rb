require "rails_helper"

RSpec.describe "chobble_forms/_submit_button.html.erb", type: :view do
  let(:default_button_text) { "Save Form" }
  let(:i18n_base) { "forms.test_form" }
  let(:mock_form) { double("FormBuilder") }

  before do
    # Set up form context
    view.instance_variable_set(:@_current_form, mock_form)
    view.instance_variable_set(:@_current_i18n_base, i18n_base)

    # Mock the submit method
    allow(mock_form).to receive(:submit) do |button_text|
      %(<input type="submit" value="#{button_text}" />).html_safe
    end

    # Mock i18n translation
    allow(view).to receive(:t)
      .with("#{i18n_base}.submit", raise: true)
      .and_return(default_button_text)
  end

  describe "basic rendering" do
    it "renders a submit button with default text" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to have_css('input[type="submit"]')
      expect(rendered).to include(%(value="Save Form"))
      expect(mock_form).to have_received(:submit).with("Save Form")
    end

    it "uses the form object from @_current_form when no form provided" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to include(%(value="Save Form"))
      expect(mock_form).to have_received(:submit).with("Save Form")
    end
  end

  describe "i18n integration" do
    it "uses the i18n base to find submit text" do
      render partial: "chobble_forms/submit_button"

      expect(view).to have_received(:t).with("forms.test_form.submit", raise: true)
      expect(rendered).to include(%(value="Save Form"))
    end

    it "works with different i18n bases" do
      view.instance_variable_set(:@_current_i18n_base, "forms.users")
      allow(view).to receive(:t)
        .with("forms.users.submit", raise: true)
        .and_return("Update User")

      render partial: "chobble_forms/submit_button"

      expect(rendered).to include(%(value="Update User"))
    end
  end

  describe "translation error handling" do
    it "raises error when translation is missing (uses raise: true)" do
      allow(view).to receive(:t)
        .with("forms.test_form.submit", raise: true)
        .and_raise(I18n::MissingTranslationData.new(:en, "forms.test_form.submit"))

      expect { render partial: "chobble_forms/submit_button" }.to raise_error(ActionView::Template::Error)
    end
  end

  describe "different form types" do
    {
      "inspector_companies" => "Save Company",
      "users" => "Update User",
      "session_new" => "Sign In",
      "units" => "Save Unit"
    }.each do |form_type, expected_text|
      it "renders #{form_type} form submit button" do
        view.instance_variable_set(:@_current_i18n_base, "forms.#{form_type}")
        allow(view).to receive(:t)
          .with("forms.#{form_type}.submit", raise: true)
          .and_return(expected_text)

        render partial: "chobble_forms/submit_button"

        expect(rendered).to include(%(value="#{expected_text}"))
      end
    end
  end

  describe "form object handling" do
    it "uses @_current_form to render submit button" do
      render partial: "chobble_forms/submit_button"

      expect(mock_form).to have_received(:submit).with("Save Form")
    end

    it "raises error when no form object available" do
      view.instance_variable_set(:@_current_form, nil)
      expect { render partial: "chobble_forms/submit_button" }.to raise_error(ActionView::Template::Error, /undefined method.*submit.*for nil/)
    end

    it "raises error when no i18n base available" do
      view.instance_variable_set(:@_current_i18n_base, nil)
      allow(view).to receive(:t).and_raise(ArgumentError, "No i18n base")

      expect { render partial: "chobble_forms/submit_button" }.to raise_error(ActionView::Template::Error)
    end
  end

  describe "edge cases and error handling" do
    {
      "HTML entities" => "&lt;Save&gt;",
      "very long text" => "This is a very long submit button text that might wrap or cause layout issues",
      "Unicode characters" => "Submit ✓ 提交"
    }.each do |description, test_text|
      it "handles #{description} from i18n" do
        allow(view).to receive(:t)
          .with("forms.test_form.submit", raise: true)
          .and_return(test_text)

        render partial: "chobble_forms/submit_button"

        expect(rendered).to include(%(value="#{test_text}"))
      end
    end
  end

  describe "HTML output and attributes" do
    it "generates valid HTML submit input" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to include('type="submit"')
      expect(rendered).to include(%(value="Save Form"))
    end

    it "does not add extra wrapper elements" do
      render partial: "chobble_forms/submit_button"
      expect(rendered.strip).to eq('<input type="submit" value="Save Form" />')
    end

    it "maintains button text in value attribute" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to include(%(value="Save Form"))
    end
  end

  describe "accessibility considerations" do
    it "creates focusable submit element" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to have_css('input[type="submit"]')
    end

    it "provides clear action text from i18n" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to include(%(value="Save Form"))
    end

    it "works with screen readers via value attribute" do
      render partial: "chobble_forms/submit_button"

      expect(rendered).to include(%(value="Save Form"))
    end
  end
end
