require "rails_helper"

# Test model for display field specs
class DisplayFieldTestModel
  include ActiveModel::Model
  attr_accessor :name, :phone, :email, :status, :created_at, :updated_at, :date_of_birth

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

  it "formats DateTime values nicely" do
    datetime = DateTime.new(2025, 10, 12, 16, 12, 0)
    test_model_with_datetime = DisplayFieldTestModel.new(created_at: datetime)
    form_object_datetime = ActionView::Helpers::FormBuilder.new(:display_field_test_model, test_model_with_datetime, view, {})
    view.instance_variable_set(:@_current_form, form_object_datetime)

    I18n.backend.store_translations(:en, {
      forms: {
        user_settings: {
          fields: {
            created_at: "Created At"
          }
        }
      }
    })

    render "chobble_forms/display_field",
      field: :created_at

    expect(rendered).to have_selector("label", text: "Created At")
    expect(rendered).to have_selector("p", text: "October 12, 2025 - 16:12")
  end

  it "formats Time values nicely" do
    time = Time.new(2025, 10, 12, 16, 12, 0)
    test_model_with_time = DisplayFieldTestModel.new(updated_at: time)
    form_object_time = ActionView::Helpers::FormBuilder.new(:display_field_test_model, test_model_with_time, view, {})
    view.instance_variable_set(:@_current_form, form_object_time)

    I18n.backend.store_translations(:en, {
      forms: {
        user_settings: {
          fields: {
            updated_at: "Updated At"
          }
        }
      }
    })

    render "chobble_forms/display_field",
      field: :updated_at

    expect(rendered).to have_selector("label", text: "Updated At")
    expect(rendered).to have_selector("p", text: "October 12, 2025 - 16:12")
  end

  it "formats Date values without time" do
    date = Date.new(2025, 10, 12)
    test_model_with_date = DisplayFieldTestModel.new(date_of_birth: date)
    form_object_date = ActionView::Helpers::FormBuilder.new(:display_field_test_model, test_model_with_date, view, {})
    view.instance_variable_set(:@_current_form, form_object_date)

    I18n.backend.store_translations(:en, {
      forms: {
        user_settings: {
          fields: {
            date_of_birth: "Date of Birth"
          }
        }
      }
    })

    render "chobble_forms/display_field",
      field: :date_of_birth

    expect(rendered).to have_selector("label", text: "Date of Birth")
    expect(rendered).to have_selector("p", text: "October 12, 2025")
  end
end
