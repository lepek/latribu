class DisciplineDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :edit_discipline_path, :enable_all_discipline_path, :disable_all_discipline_path, :discipline_path, :button_to

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Discipline.name']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Discipline.name']
  end

  private

  def data
    records.map do |record|
      [
        record.name,
        '<div class="btn-group">' +
            '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Acciones <span class="caret"></span>
          </button>' +
            '<ul class="dropdown-menu">' +
            "<li>#{link_to('Editar', edit_discipline_path(record))}</li>" +
            "<li>#{link_to('Habilitar a todos', enable_all_discipline_path(record), method: :post, data: { confirm: "¿Está seguro que desea permitir que todos\n los usuarios se inscriban a #{record.name}?" })}</li>" +
            "<li>#{link_to('Deshabilitar a todos', disable_all_discipline_path(record), method: :post, data: { confirm: "¿Está seguro que desea NO permitir que todos\n los usuarios se inscriban a #{record.name}?" })}</li>" +
            "<li>#{link_to('Borrar', discipline_path(record), data: { confirm: "¿Está seguro que desea eliminar \n#{record.name}?" }, method: :delete)}</li>" +
            '</ul>' +
        '</div>'
      ]
    end
  end

  def get_raw_records
    Discipline.all
  end

end
