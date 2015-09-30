class RookyDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :rooky_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Rooky.shift_date', 'Rooky.full_name', 'Rooky.phone', 'Rooky.email']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Rooky.shift_date', 'Rooky.full_name', 'Rooky.phone', 'Rooky.email']
  end

  private

  def data
    records.map do |record|
      [
          I18n.l(record.shift_date, :format => '%A, %e de %B %H:%M hs.'),
          record.full_name,
          record.phone,
          record.email,
          link_to('Borrar', rooky_path(record), class: 'btn btn-danger', data: { confirm: "¿Está seguro que desea eliminar \nla inscripción de #{record.full_name}?" }, method: :delete)
      ]
    end
  end

  def get_raw_records
    Rooky.all
  end

end
