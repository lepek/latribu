class UserResetCreditDatatable < AjaxDatatablesRails::Base

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['User.last_name', 'User.credit']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['User.last_name', 'User.credit']
  end

  private

  def data
    records.map do |record|
      [
        record.full_name,
        record.credit,
        record.calculate_future_credit(options[:date])
      ]
    end
  end

  def get_raw_records
    options[:date].present? ? User.to_reset : User.none
  end

end