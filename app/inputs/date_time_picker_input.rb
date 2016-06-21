class DateTimePickerInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field(attribute_name, input_html_options)
      template.concat span_table
    end
  end

  def input_html_options
    options = { class: 'form-control' }
    options.merge!({value: I18n.l(@builder.object.start_date, :format => '%d/%m/%Y')}) if @builder.object.start_date.present?
    super.merge(options)
  end

  def span_remove
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_remove
    end
  end

  def span_table
    template.content_tag(:span, class: 'input-group-addon') do
      template.concat icon_table
    end
  end

  def icon_table
    "<span class='glyphicon glyphicon-calendar'></span>".html_safe
  end

end
