class UserDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :new_user_payment_path, :edit_user_path, :user_path, :impersonate_user_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['User.last_name', 'User.profession', 'User.phone', 'User.credit']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['User.last_name', 'User.first_name', 'User.profession']
  end

  private

  def data
    records.map do |record|
      [
        record.full_name,
        record.profession,
        record.phone,
        record.credit,
        '<div class="btn-group">' +
          '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Acciones <span class="caret"></span>
          </button>' +
          '<ul class="dropdown-menu">' +
            "<li>#{link_to('Pago', new_user_payment_path(record))}</li>" +
            "<li>#{link_to('Editar', edit_user_path(record))}</li>" +
            "<li>#{link_to('Impersonar', impersonate_user_path(record))}</li>" +
            "<li>#{link_to('Borrar', user_path(record), data: { confirm: "¿Está seguro que desea eliminar \nel usuario #{record.full_name.upcase}?" }, method: :delete)}</li>" +
          '</ul>' +
        '</div>'
      ]
    end
  end

  def get_raw_records
    User.clients
  end

end
