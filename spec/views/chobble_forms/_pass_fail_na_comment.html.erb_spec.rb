require "rails_helper"

# Test model for form specs
class PassFailNaCommentTestModel
  include ActiveModel::Model
  attr_accessor :ropes_pass, :ropes_comment, :seam_integrity_pass, :seam_integrity_comment,
    :material_check_pass, :material_check_comment, :safety_pass, :safety_comment

  def persisted? = false

  # Mock enum behavior for _pass fields to support N/A radio buttons
  def self.defined_enums
    {
      "ropes" => {"fail" => 0, "pass" => 1, "na" => 2},
      "seam_integrity" => {"fail" => 0, "pass" => 1, "na" => 2},
      "material_check" => {"fail" => 0, "pass" => 1, "na" => 2},
      "safety" => {"fail" => 0, "pass" => 1, "na" => 2}
    }
  end
end

RSpec.describe "chobble_forms/_pass_fail_na_comment.html.erb", type: :view do
  let(:test_model) { PassFailNaCommentTestModel.new }
  let(:field) { :ropes_pass }

  # Expected text labels
  let(:field_label) { "Ropes" }
  let(:pass_label) { "Pass" }
  let(:fail_label) { "Fail" }
  let(:na_label) { "Not Applicable" }
  let(:comment_label) { "Comment" }

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
            ropes: "Ropes",
            seam_integrity: "Seam Integrity",
            material_check: "Material Check",
            safety: "Safety Check"
          }
        }
      },
      shared: {
        fail: "Fail",
        pass: "Pass",
        not_applicable: "Not Applicable",
        comment: "Comment"
      }
    })
  end

  def render_pass_fail_na_comment(locals = {})
    render partial: "chobble_forms/pass_fail_na_comment", locals: {field:}.merge(locals)
  end

  # Helper methods for common expectations using Capybara selectors
  def expect_basic_structure
    expect(rendered).to have_css("div.form-grid.radio-comment")
    expect(rendered).to have_content(field_label)
  end

  def expect_pass_fail_radios
    expect(rendered).to have_content(pass_label)
    expect(rendered).to have_content(fail_label)
    expect(rendered).to have_field("Pass", type: "radio")
    expect(rendered).to have_field("Fail", type: "radio")
  end

  def expect_na_radio
    expect(rendered).to have_content(na_label)
    expect(rendered).to have_field("Not Applicable", type: "radio")
  end

  def expect_comment_section
    expect(rendered).to have_content(comment_label)
    expect(rendered).to have_field(type: "textarea", visible: false)
  end

  describe "comment functionality" do
    it "shows comment checkbox when field has existing comment" do
      test_model.ropes_comment = "Test comment"

      render_pass_fail_na_comment

      expect(rendered).to have_checked_field("Comment")
    end
  end

  describe "i18n integration" do
    it "uses i18n for all labels" do
      render_pass_fail_na_comment

      expect(rendered).to have_content(pass_label)
      expect(rendered).to have_content(fail_label)
      expect(rendered).to have_content(na_label)
      expect(rendered).to have_content(comment_label)
    end

    it "uses correct field label from i18n" do
      render_pass_fail_na_comment

      expect(rendered).to have_text(field_label)
    end
  end
end
