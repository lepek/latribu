class MessageDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :edit_message_path, :message_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Message.message', 'Message.start_date', 'Message.end_date']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Message.message', 'Message.start_date', 'Message.end_date']
  end

  private

  def data
    records.map do |record|
      [
        record.message,
        I18n.l(record.start_date, :format => '%A, %e de %B del %Y'),
        I18n.l(record.end_date, :format => '%A, %e de %B del %Y'),
        '<div class="btn-group">' +
          '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Acciones <span class="caret"></span>
          </button>' +
          '<ul class="dropdown-menu">' +
            "<li>#{link_to('Editar', edit_message_path(record))}</li>" +
            "<li>#{link_to('Borrar', message_path(record), data: { confirm: "¿Está seguro que desea eliminar la notifiación?" }, method: :delete)}</li>" +
          '</ul>' +
        '</div>'
      ]
    end
  end

  def get_raw_records
    Message.all
  end

end
