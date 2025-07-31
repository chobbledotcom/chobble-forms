require "rails_helper"

# Test model for form specs
class PassFailTestModel
  include ActiveModel::Model
  attr_accessor :status, :passed, :meets_requirements, :satisfactory,
    :compliant, :approved

  def persisted? = false
end

RSpec.describe "chobble_forms/_pass_fail.html.erb", type: :view do
  let(:test_model) { PassFailTestModel.new }
  let(:field) { :status }

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
            approved: "Approved",
            compliant: "Compliant",
            meets_requirements: "Meets Requirements",
            passed: "Passed",
            satisfactory: "Satisfactory",
            status: "Status"
          }
        }
      },
      shared: {
        fail: "Fail",
        pass: "Pass"
      }
    })
  end

  def render_pass_fail(locals = {})
    render partial: "chobble_forms/pass_fail", locals: {field:}.merge(locals)
  end

  describe "basic rendering" do
    it "renders a complete pass/fail radio group" do
      render_pass_fail

      expect(rendered).to have_css("div")
      expect(rendered).to have_text("Status")
      expect(rendered).to have_field("pass_fail_test_model[status]", with: "true", type: "radio")
      expect(rendered).to have_field("pass_fail_test_model[status]", with: "false", type: "radio")
      expect(rendered).to have_text("Pass")
      expect(rendered).to have_text("Fail")
    end

    it "nests radio buttons inside their labels" do
      render_pass_fail

      # Check that Pass label contains the radio button
      pass_label = Capybara.string(rendered).find("label", text: "Pass")
      expect(pass_label).to have_css('input[type="radio"][value="true"]')

      # Check that Fail label contains the radio button
      fail_label = Capybara.string(rendered).find("label", text: "Fail")
      expect(fail_label).to have_css('input[type="radio"][value="false"]')
    end

    it "generates proper radio button IDs for accessibility" do
      render_pass_fail

      expect(rendered).to have_field("pass_fail_test_model_status_true", type: "radio")
      expect(rendered).to have_field("pass_fail_test_model_status_false", type: "radio")
    end
  end

  describe "with prefilled value" do
    it "checks the appropriate radio button when prefilled" do
      test_model.status = nil
      @previous_inspection = PassFailTestModel.new(status: true)

      render_pass_fail

      expect(rendered).to have_checked_field("pass_fail_test_model[status]", with: "true")
      expect(rendered).to have_unchecked_field("pass_fail_test_model[status]", with: "false")
    end

    it "does not check any radio button when field value is nil" do
      test_model.status = nil

      render_pass_fail

      # When the field value is nil, no radio button should be checked
      expect(rendered).to have_unchecked_field("pass_fail_test_model[status]", with: "true")
      expect(rendered).to have_unchecked_field("pass_fail_test_model[status]", with: "false")
    end
  end

  describe "different field contexts" do
    shared_examples "renders correctly for field" do |field_name, expected_label|
      it "handles #{field_name} field" do
        view.form_with(model: test_model, url: "/", local: true) do |f|
          @_current_form = f
          ""
        end

        render partial: "chobble_forms/pass_fail", locals: {field: field_name}

        expect(rendered).to have_css("div")
        expect(rendered).to have_text(expected_label)
      end
    end

    include_examples "renders correctly for field", :approved, "Approved"
    include_examples "renders correctly for field", :compliant, "Compliant"
    include_examples "renders correctly for field", :meets_requirements, "Meets Requirements"
    include_examples "renders correctly for field", :passed, "Passed"
    include_examples "renders correctly for field", :satisfactory, "Satisfactory"
  end

  describe "i18n integration" do
    it "uses i18n for pass/fail labels" do
      render_pass_fail

      expect(rendered).to have_content("Pass")
      expect(rendered).to have_content("Fail")
    end

    it "uses the correct i18n keys" do
      I18n.backend.store_translations(:en, {
        shared: {
          pass: "CustomPass",
          fail: "CustomFail"
        }
      })

      render_pass_fail

      expect(rendered).to have_content("CustomPass")
      expect(rendered).to have_content("CustomFail")
    end
  end

  describe "accessibility and semantic structure" do
    it "properly associates radio buttons with their labels through nesting" do
      render_pass_fail

      # Check that Pass label contains the radio button
      pass_label = Capybara.string(rendered).find("label", text: "Pass")
      expect(pass_label).to have_css('input[type="radio"][value="true"]')

      # Check that Fail label contains the radio button
      fail_label = Capybara.string(rendered).find("label", text: "Fail")
      expect(fail_label).to have_css('input[type="radio"][value="false"]')
    end

    it "uses boolean values for pass/fail" do
      render_pass_fail

      expect(rendered).to have_field("pass_fail_test_model[status]", with: "true", type: "radio")
      expect(rendered).to have_field("pass_fail_test_model[status]", with: "false", type: "radio")
    end
  end
end
