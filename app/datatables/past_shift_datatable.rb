class PastShiftDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :past_shift_path

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Inscription.shift_date']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Inscription.shift_date']
  end

  private

  def data
    records.map do |record|
      [
        I18n.l(record.shift_date, :format => '%A %H:%M hs, %e de %B del %Y').capitalize,
        record.registered,
        link_to('Ver', past_shift_path(URI.encode(record.shift_date.to_s)), class: "btn btn-default")
      ]
    end
  end

  def get_raw_records
    inscriptions = Inscription.select(:id, :shift_date).to_sql
    rookies = Rooky.select(:id, :shift_date).to_sql
    Inscription.from("(#{inscriptions} UNION ALL #{rookies}) AS inscriptions").select('shift_date, count(id) as registered').group(:shift_date)
  end

end
