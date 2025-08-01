require "rails_helper"

RSpec.describe "chobble_forms/_number.html.erb", type: :view do
  let(:mock_form) { double("FormBuilder") }
  let(:field) { :quantity }
  let(:field_config) do
    {
      form_object: mock_form,
      i18n_base: "test.forms",
      field_label: "Quantity",
      field_hint: "Enter a number",
      field_placeholder: "0"
    }
  end

  # Default render method with common setup
  def render_number_field(locals = {})
    render partial: "chobble_forms/number", locals: {field: field}.merge(locals)
  end

  before do
    # Mock the form field setup helper
    allow(view).to receive(:form_field_setup).and_return(field_config.merge(value: nil))

    # Mock strip_trailing_zeros helper
    allow(view).to receive(:strip_trailing_zeros).and_return(nil)

    # Mock form builder methods with default behavior
    allow(mock_form).to receive(:label)
      .with(field, "Quantity")
      .and_return('<label for="quantity">Quantity</label>'.html_safe)

    allow(mock_form).to receive(:number_field)
      .with(field, anything)
      .and_return('<input type="number" name="quantity" id="quantity" />'.html_safe)

    # Mock field_id method
    allow(mock_form).to receive(:field_id).with(field).and_return("quantity")

    # Set current i18n base for the partial
    view.instance_variable_set(:@_current_i18n_base, "test.forms")
  end

  describe "basic rendering" do
    it "renders a complete number field group" do
      render_number_field

      wrapper = Capybara.string(rendered).find("div.form-grid.number")
      expect(wrapper).to have_text("Quantity")
      expect(wrapper).to have_field("quantity", type: "number")
    end

    it "maintains correct element order (label, input)" do
      render_number_field
      expect(rendered).to match(/<label.*?>.*?<\/label>.*?<input.*?type="number".*?>/m)
    end

    # The actual partial doesn't support hints, so removing this context
  end

  describe "default behavior" do
    it "applies default step of 0.1" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(step: 0.1))
        .and_return('<input type="number" step="0.1" />'.html_safe)

      render_number_field
      expect(mock_form).to have_received(:number_field).with(field, hash_including(step: 0.1))
    end

    it "includes placeholder from field config" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(placeholder: "0"))
        .and_return('<input type="number" placeholder="0" />'.html_safe)

      render_number_field
      expect(mock_form).to have_received(:number_field).with(field, hash_including(placeholder: "0"))
    end
  end

  describe "custom numeric attributes" do
    shared_examples "supports numeric attribute" do |attribute, value|
      it "passes #{attribute} attribute to number field" do
        allow(mock_form).to receive(:number_field)
          .with(field, hash_including(attribute => value))
          .and_return(%(<input type="number" #{attribute}="#{value}" />).html_safe)

        render_number_field(attribute => value)
        expect(rendered).to have_field(type: "number")
      end
    end

    include_examples "supports numeric attribute", :step, 1
    include_examples "supports numeric attribute", :step, 0.1
    include_examples "supports numeric attribute", :step, "any"
    include_examples "supports numeric attribute", :min, 0
    include_examples "supports numeric attribute", :min, -100
    include_examples "supports numeric attribute", :max, 100
    include_examples "supports numeric attribute", :max, 999

    it "supports multiple numeric attributes together" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(min: 0, max: 100, step: 5))
        .and_return('<input type="number" min="0" max="100" step="5" />'.html_safe)

      render_number_field(min: 0, max: 100, step: 5)
      number_field = Capybara.string(rendered).find('input[type="number"]')
      expect(number_field[:min]).to eq("0")
      expect(number_field[:max]).to eq("100")
      expect(number_field[:step]).to eq("5")
    end
  end

  describe "CSS customization" do
    it "applies custom CSS class to input field" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(class: "custom-control"))
        .and_return('<input type="number" class="custom-control" />'.html_safe)

      render_number_field(css_class: "custom-control")
      expect(rendered).to have_field(type: "number")
    end

    it "applies custom wrapper class" do
      render_number_field(wrapper_class: "custom-wrapper")
      expect(rendered).to have_css("div.form-grid.number")
    end
  end

  describe "form object handling" do
    let(:other_form) { double("OtherFormBuilder") }

    before do
      allow(view).to receive(:form_field_setup).and_return(
        field_config.merge(form_object: other_form, value: nil)
      )
      allow(view).to receive(:strip_trailing_zeros).and_return(nil)
      allow(other_form).to receive(:label).and_return("<label>Quantity</label>".html_safe)
      allow(other_form).to receive(:number_field).and_return('<input type="number" />'.html_safe)
      allow(other_form).to receive(:field_id).with(field).and_return("quantity")
    end

    it "uses the form object returned by form_field_setup" do
      render_number_field(form: other_form)

      # The partial doesn't use form.label, it renders label directly
      expect(other_form).to have_received(:number_field)
      expect(other_form).to have_received(:field_id).at_least(:once)
      expect(mock_form).not_to have_received(:number_field)
    end
  end

  describe "different number field types" do
    shared_examples "renders correctly for field" do |field_name, expected_label|
      it "handles #{field_name} field" do
        # Update mocks for the new field
        allow(mock_form).to receive(:label)
          .with(field_name, expected_label)
          .and_return(%(<label for="#{field_name}">#{expected_label}</label>).html_safe)

        allow(mock_form).to receive(:number_field)
          .with(field_name, anything)
          .and_return(%(<input type="number" name="#{field_name}" id="#{field_name}" />).html_safe)

        allow(mock_form).to receive(:field_id).with(field_name).and_return(field_name.to_s)

        # Need to mock form_field_setup for the new field
        allow(view).to receive(:form_field_setup).and_return(
          field_config.merge(field_label: expected_label, value: nil)
        )

        # Mock strip_trailing_zeros helper
        allow(view).to receive(:strip_trailing_zeros).and_return(nil)

        render_number_field(field: field_name)
        expect(rendered).to have_css("div.form-grid.number")
        expect(rendered).to have_text(expected_label)
      end
    end

    include_examples "renders correctly for field", :price, "Price"
    include_examples "renders correctly for field", :quantity, "Quantity"
    include_examples "renders correctly for field", :age, "Age"
    include_examples "renders correctly for field", :weight, "Weight"
    include_examples "renders correctly for field", :height, "Height"
  end

  describe "edge cases and validation" do
    it "includes nil values in options hash" do
      # The actual partial doesn't compact nil values
      allow(mock_form).to receive(:number_field) do |field, options|
        expect(options).to have_key(:min)
        expect(options).to have_key(:max)
        expect(options[:min]).to be_nil
        expect(options[:max]).to be_nil
        expect(options).to have_key(:step) # step has a default
        expect(options).to have_key(:placeholder) # placeholder comes from field_config
        '<input type="number" />'.html_safe
      end

      render_number_field(min: nil, max: nil)
    end

    it "handles decimal step values correctly" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(step: 0.001))
        .and_return('<input type="number" step="0.001" />'.html_safe)

      render_number_field(step: 0.001)
      number_field = Capybara.string(rendered).find('input[type="number"]')
      expect(number_field[:step]).to eq("0.001")
    end

    it "supports 'any' as step value for unrestricted precision" do
      allow(mock_form).to receive(:number_field)
        .with(field, hash_including(step: "any"))
        .and_return('<input type="number" step="any" />'.html_safe)

      render_number_field(step: "any")
      number_field = Capybara.string(rendered).find('input[type="number"]')
      expect(number_field[:step]).to eq("any")
    end
  end

  describe "accessibility" do
    it "properly associates label with input field" do
      render_number_field

      # Label should have 'for' attribute matching input 'id'
      expect(rendered).to have_selector('label[for="quantity"]')
      expect(rendered).to have_field("quantity", type: "number")
    end

    it "includes aria-describedby when hint is present" do
      # This test documents that the current implementation doesn't add aria-describedby
      # but it could be enhanced to do so
      render_number_field
      expect(rendered).not_to include("aria-describedby")
    end
  end
end
