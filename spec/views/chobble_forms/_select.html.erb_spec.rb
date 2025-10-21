require "rails_helper"

RSpec.describe "chobble_forms/_select.html.erb", type: :view do
  let(:mock_form) { double("FormBuilder") }
  let(:mock_object) { double("Model", object_id: 123) }
  let(:field) { :status }
  let(:options) { [["Active", "active"], ["Inactive", "inactive"]] }
  let(:field_config) do
    {
      form_object: mock_form,
      i18n_base: "test.forms",
      field_label: "Status",
      field_hint: "Choose a status",
      field_placeholder: nil,
      value: nil,
      prefilled: false
    }
  end

  def render_select(locals = {})
    render partial: "chobble_forms/select", locals: {field: field, options: options}.merge(locals)
  end

  before do
    allow(view).to receive(:form_field_setup).and_return(field_config)
    allow(mock_form).to receive(:object).and_return(mock_object)
    allow(mock_form).to receive(:label).with(field, "Status").and_return("<label>Status</label>".html_safe)

    view.instance_variable_set(:@_current_i18n_base, "test.forms")
  end

  describe "regular select mode" do
    before do
      allow(mock_form).to receive(:select)
        .with(field, options, {}, {required: false})
        .and_return('<select name="status"></select>'.html_safe)
    end

    it "renders a select element" do
      render_select

      expect(mock_form).to have_received(:select)
      expect(rendered).to have_selector("select")
    end

    it "renders the label" do
      render_select

      expect(mock_form).to have_received(:label).with(field, "Status")
      expect(rendered).to have_text("Status")
    end

    it "renders the hint when present" do
      render_select

      expect(rendered).to have_selector("small", text: "Choose a status")
    end

    context "when hint is not present" do
      let(:field_config) { super().merge(field_hint: nil) }

      it "does not render hint element" do
        render_select

        expect(rendered).not_to have_selector("small")
      end
    end

    context "with required parameter" do
      before do
        allow(mock_form).to receive(:select)
          .with(field, options, {}, {required: true})
          .and_return('<select name="status" required></select>'.html_safe)
      end

      it "passes required attribute to select" do
        render_select(required: true)

        expect(mock_form).to have_received(:select).with(
          field,
          options,
          {},
          {required: true}
        )
      end
    end

    context "with prompt parameter" do
      before do
        allow(mock_form).to receive(:select)
          .with(field, options, {prompt: "Choose..."}, {required: false})
          .and_return('<select name="status"></select>'.html_safe)
      end

      it "passes prompt to select options" do
        render_select(prompt: "Choose...")

        expect(mock_form).to have_received(:select).with(
          field,
          options,
          {prompt: "Choose..."},
          {required: false}
        )
      end
    end

    context "with onchange parameter" do
      before do
        allow(mock_form).to receive(:select)
          .with(field, options, {}, {required: false, onchange: "this.form.submit();"})
          .and_return('<select name="status"></select>'.html_safe)
      end

      it "passes onchange attribute to field options" do
        render_select(onchange: "this.form.submit();")

        expect(mock_form).to have_received(:select).with(
          field,
          options,
          {},
          {required: false, onchange: "this.form.submit();"}
        )
      end
    end
  end

  describe "collection_select mode" do
    let(:collection) { [double(id: 1, name: "Option 1"), double(id: 2, name: "Option 2")] }
    let(:collection_select_params) do
      {
        collection: collection,
        value_method: :id,
        text_method: :name
      }
    end

    before do
      allow(mock_form).to receive(:collection_select)
        .with(field, collection, :id, :name, {}, {required: false})
        .and_return('<select name="status"></select>'.html_safe)
    end

    it "uses collection_select when collection_select_params provided" do
      render_select(collection_select_params: collection_select_params, options: nil)

      expect(mock_form).to have_received(:collection_select).with(
        field,
        collection,
        :id,
        :name,
        {},
        {required: false}
      )
    end

    it "passes prompt to collection_select" do
      allow(mock_form).to receive(:collection_select)
        .with(field, collection, :id, :name, {prompt: "Select..."}, {required: false})
        .and_return('<select name="status"></select>'.html_safe)

      render_select(
        collection_select_params: collection_select_params,
        prompt: "Select...",
        options: nil
      )

      expect(mock_form).to have_received(:collection_select).with(
        field,
        collection,
        :id,
        :name,
        {prompt: "Select..."},
        {required: false}
      )
    end
  end

  describe "combobox mode" do
    before do
      allow(mock_form).to receive(:text_field)
        .with(field, {required: false, list: "status_datalist_123"})
        .and_return('<input type="text" list="status_datalist_123" />'.html_safe)
    end

    it "renders a text field with datalist when combobox is true" do
      render_select(combobox: true)

      expect(mock_form).to have_received(:text_field).with(
        field,
        {required: false, list: "status_datalist_123"}
      )
    end

    it "generates unique datalist id using object_id" do
      render_select(combobox: true)

      expect(rendered).to have_selector('datalist[id="status_datalist_123"]')
    end

    it "renders options in datalist with value and text" do
      render_select(combobox: true)

      datalist = Capybara.string(rendered).find("datalist")
      expect(datalist).to have_selector('option[value="active"]', text: "Active")
      expect(datalist).to have_selector('option[value="inactive"]', text: "Inactive")
    end

    it "renders the label" do
      render_select(combobox: true)

      expect(mock_form).to have_received(:label).with(field, "Status")
      expect(rendered).to have_text("Status")
    end

    it "renders hint when present" do
      render_select(combobox: true)

      expect(rendered).to have_selector("small", text: "Choose a status")
    end

    context "with simple array options" do
      let(:simple_options) { ["red", "green", "blue"] }

      before do
        allow(mock_form).to receive(:text_field)
          .with(field, {required: false, list: "status_datalist_123"})
          .and_return('<input type="text" list="status_datalist_123" />'.html_safe)
      end

      it "handles simple array values" do
        render_select(combobox: true, options: simple_options)

        datalist = Capybara.string(rendered).find("datalist")
        expect(datalist).to have_selector('option[value="red"]', text: "red")
        expect(datalist).to have_selector('option[value="green"]', text: "green")
        expect(datalist).to have_selector('option[value="blue"]', text: "blue")
      end
    end

    context "with required parameter" do
      before do
        allow(mock_form).to receive(:text_field)
          .with(field, {required: true, list: "status_datalist_123"})
          .and_return('<input type="text" required list="status_datalist_123" />'.html_safe)
      end

      it "passes required attribute to text field" do
        render_select(combobox: true, required: true)

        expect(mock_form).to have_received(:text_field).with(
          field,
          {required: true, list: "status_datalist_123"}
        )
      end
    end

    context "with onchange parameter" do
      before do
        allow(mock_form).to receive(:text_field)
          .with(field, {required: false, onchange: "handleChange();", list: "status_datalist_123"})
          .and_return('<input type="text" list="status_datalist_123" />'.html_safe)
      end

      it "passes onchange attribute to text field" do
        render_select(combobox: true, onchange: "handleChange();")

        expect(mock_form).to have_received(:text_field).with(
          field,
          {required: false, onchange: "handleChange();", list: "status_datalist_123"}
        )
      end
    end

    it "does not render select element" do
      render_select(combobox: true)

      expect(mock_form).not_to have_received(:select)
      expect(rendered).not_to have_selector("select")
    end
  end

  describe "different field types" do
    [:manufacturer, :model, :location].each do |field_name|
      context "with field #{field_name}" do
        before do
          allow(view).to receive(:form_field_setup).and_return(
            field_config.merge(field_label: field_name.to_s.titleize)
          )
          allow(mock_form).to receive(:label)
            .with(field_name, field_name.to_s.titleize)
            .and_return("<label>#{field_name.to_s.titleize}</label>".html_safe)
          allow(mock_form).to receive(:select)
            .with(field_name, options, {}, {required: false})
            .and_return("<select></select>".html_safe)
        end

        it "renders correctly for #{field_name}" do
          render_select(field: field_name)

          expect(rendered).to have_selector("select")
          expect(rendered).to have_text(field_name.to_s.titleize)
        end
      end
    end
  end

  describe "HTML structure and semantics" do
    before do
      allow(mock_form).to receive(:select)
        .and_return('<select name="status"></select>'.html_safe)
    end

    it "maintains proper semantic structure for regular select" do
      render_select

      expect(rendered).to have_selector("label")
      expect(rendered).to have_selector("select")
      expect(rendered).to have_selector("small")
    end

    context "in combobox mode" do
      before do
        allow(mock_form).to receive(:text_field)
          .and_return('<input type="text" list="status_datalist_123" />'.html_safe)
      end

      it "maintains proper semantic structure" do
        render_select(combobox: true)

        expect(rendered).to have_selector("label")
        expect(rendered).to have_selector('input[type="text"]')
        expect(rendered).to have_selector("datalist")
        expect(rendered).to have_selector("small")
      end

      it "associates input with datalist via list attribute" do
        render_select(combobox: true)

        input = Capybara.string(rendered).find('input[type="text"]')
        datalist_id = input[:list]

        expect(rendered).to have_selector("datalist[id='#{datalist_id}']")
      end
    end
  end
end
