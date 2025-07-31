require "rails_helper"

# Test model for display field specs
class DisplayFieldTestModel
  include ActiveModel::Model
  attr_accessor :name, :phone, :email, :status

  def persisted? = false
end

RSpec.describe "chobble_forms/_display_field.html.erb", type: :view do
  let(:test_model) { DisplayFieldTestModel.new(name: "Test User") }
  let(:form_object) { ActionView::Helpers::FormBuilder.new(:display_field_test_model, test_model, view, {}) }

  before do
    # Set up form context like fieldset would
    view.instance_variable_set(:@_current_form, form_object)
    view.instance_variable_set(:@_current_i18n_base, "forms.user_settings")

    # Mock i18n translations
    I18n.backend.store_translations(:en, {
      forms: {
        user_settings: {
          fields: {
            name: "Name",
            phone: "Phone",
            email: "Email",
            status: "Status"
          }
        }
      }
    })
  end

  it "renders display field using model value automatically" do
    render "chobble_forms/display_field",
      field: :name

    expect(rendered).to have_selector("label", text: "Name")
    expect(rendered).to have_selector("p", text: "Test User")
  end

  it "handles nil values gracefully" do
    test_model_with_nil = DisplayFieldTestModel.new(phone: nil)
    form_object_nil = ActionView::Helpers::FormBuilder.new(:display_field_test_model, test_model_with_nil, view, {})
    view.instance_variable_set(:@_current_form, form_object_nil)

    render "chobble_forms/display_field",
      field: :phone

    expect(rendered).to have_selector("label", text: "Phone")
    expect(rendered).to have_selector("p")
    # Should not crash with nil value
  end
end
