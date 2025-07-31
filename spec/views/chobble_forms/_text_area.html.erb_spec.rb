require "rails_helper"

RSpec.describe "chobble_forms/_text_area.html.erb", type: :view do
  let(:mock_form) { double("FormBuilder") }
  let(:field) { :description }

  before do
    # Set up form field setup mock
    allow(view).to receive(:form_field_setup).and_return({
      form_object: mock_form,
      i18n_base: "test.forms",
      field_label: "Description",
      field_hint: "Provide details",
      field_placeholder: "Enter description here..."
    })

    # Mock form builder methods
    allow(mock_form).to receive(:label).and_return('<label for="description">Description</label>'.html_safe)
    allow(mock_form).to receive(:text_area).and_return('<textarea name="description" id="description"></textarea>'.html_safe)

    # Set current i18n base for the partial
    view.instance_variable_set(:@_current_i18n_base, "test.forms")
  end

  context "with default options" do
    it "renders text area with label" do
      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(rendered).to have_selector('label[for="description"]', text: "Description")
      expect(rendered).to have_field("description", type: "textarea")
    end

    it "displays hint when present" do
      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(rendered).to have_selector("small", text: "Provide details")
    end

    it "uses default rows of 4" do
      allow(mock_form).to receive(:text_area).with(field, hash_including(rows: 4)).and_return('<textarea rows="4"></textarea>'.html_safe)

      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(mock_form).to have_received(:text_area).with(field, hash_including(rows: 4))
    end

    it "includes placeholder when provided" do
      allow(mock_form).to receive(:text_area).with(field, hash_including(placeholder: "Enter description here...")).and_return('<textarea placeholder="Enter description here..."></textarea>'.html_safe)

      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(mock_form).to have_received(:text_area).with(field, hash_including(placeholder: "Enter description here..."))
    end
  end

  context "with custom options" do
    it "uses custom rows value" do
      allow(mock_form).to receive(:text_area).with(field, hash_including(rows: 10)).and_return('<textarea rows="10"></textarea>'.html_safe)

      render partial: "chobble_forms/text_area", locals: {field: field, rows: 10}

      expect(mock_form).to have_received(:text_area).with(field, hash_including(rows: 10))
    end

    it "respects required parameter" do
      allow(mock_form).to receive(:text_area).with(field, hash_including(required: true)).and_return("<textarea required></textarea>".html_safe)

      render partial: "chobble_forms/text_area", locals: {field: field, required: true}

      expect(mock_form).to have_received(:text_area).with(field, hash_including(required: true))
    end
  end

  context "without hint" do
    before do
      allow(view).to receive(:form_field_setup).and_return({
        form_object: mock_form,
        i18n_base: "test.forms",
        field_label: "Description",
        field_hint: nil,
        field_placeholder: "Enter description here..."
      })
    end

    it "does not render hint text" do
      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(rendered).not_to have_selector("small")
    end
  end

  context "without placeholder" do
    before do
      allow(view).to receive(:form_field_setup).and_return({
        form_object: mock_form,
        i18n_base: "test.forms",
        field_label: "Description",
        field_hint: "Provide details",
        field_placeholder: nil
      })
    end

    it "does not include placeholder attribute" do
      allow(mock_form).to receive(:text_area).with(field, hash_excluding(:placeholder)).and_return("<textarea></textarea>".html_safe)

      render partial: "chobble_forms/text_area", locals: {field: field}

      expect(mock_form).to have_received(:text_area).with(field, hash_excluding(:placeholder))
    end
  end

  context "form object handling" do
    let(:other_form) { double("OtherFormBuilder") }

    before do
      allow(view).to receive(:form_field_setup).and_return({
        form_object: other_form,
        i18n_base: "test.forms",
        field_label: "Description",
        field_hint: "Provide details",
        field_placeholder: "Enter description here..."
      })
      allow(other_form).to receive(:label).and_return("<label>Description</label>".html_safe)
      allow(other_form).to receive(:text_area).and_return("<textarea></textarea>".html_safe)
    end

    it "uses the form object returned by form_field_setup" do
      render partial: "chobble_forms/text_area", locals: {field: field, form: other_form}

      expect(other_form).to have_received(:label)
      expect(other_form).to have_received(:text_area)
    end
  end

  context "HTML structure" do
    it "has proper semantic structure" do
      render partial: "chobble_forms/text_area", locals: {field: field}

      # Should have label followed by textarea
      expect(rendered).to have_selector("label")
      expect(rendered).to have_selector("textarea")

      # Hint should be in a small tag
      expect(rendered).to have_selector("small", text: "Provide details")
    end
  end
end
