class StatDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :stats_path


  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Stat.month_year', 'Stat.credits', 'Stat.incriptions']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Stat.month_year', 'Stat.credits', 'Stat.incriptions']
  end

  private

  def data
    records.map do |record|
      [
        I18n.l(record.month_year, :format => '%B %Y').capitalize,
        record.credits,
        record.inscriptions,
        link_to("Detalle", stats_path(date: I18n.l(record.month_year, :format => '%Y-%m-%d'), order: 'desc'), class: 'btn btn-primary' )
      ]
    end
  end

  def get_raw_records
    Stat.all
  end

end
