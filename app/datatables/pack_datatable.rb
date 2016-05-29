class PackDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :edit_pack_path, :pack_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Pack.name', 'Pack.enabled']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Pack.name', 'Pack.enabled']
  end

  private

  def data
    records.map do |record|
      [
        record.name,
        record.enabled? ? 'Activado' : 'Desactivado',
        link_to('Editar', edit_pack_path(record), class: "btn btn-default") + " " +
        link_to('Borrar', pack_path(record), class: "btn btn-default", data: { confirm: "¿Está seguro que desea eliminar \n#{record.name}?" }, method: :delete)
      ]
    end
  end

  def get_raw_records
    Pack.all
  end

end
