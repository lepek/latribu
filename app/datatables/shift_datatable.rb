class ShiftDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :new_in_shift_rookies_path, :shift_path, :edit_shift_path, :new_in_shift_rookies_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['next_shift', 'Shift.max_attendants', 'next_shift']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Shift.start_time', 'Shift.end_time', 'Shift.max_attendants']
  end

  private

  def data
    records.map do |record|
      [
        record.day_and_time,
        record.max_attendants,
        I18n.l(record.next_fixed_shift, :format => '%A, %e de %B %H:%M hs.').capitalize,
        record.next_fixed_shift_count,
        record.status.capitalize,
        '<div class="btn-group">' +
            '<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            Acciones <span class="caret"></span>
          </button>' +
            '<ul class="dropdown-menu">' +
            "<li>#{link_to('Inscribir', new_in_shift_rookies_path(record))}</li>" +
            "<li>#{link_to('Ver', shift_path(record))}</li>" +
            "<li>#{link_to('Editar', edit_shift_path(record))}</li>" +
            "<li>#{link_to('Borrar', shift_path(record), data: { confirm: "¿Está seguro que desea eliminar \nla clase del #{I18n.l(record.next_fixed_shift, :format => '%A, %e de %B %H:%M hs.').capitalize}?" }, method: :delete)}</li>" +
            '</ul>' +
        '</div>'
      ]
    end
  end

  def get_raw_records
    Shift.with_shift_dates
  end

end
