class UserPaymentDatatable < AjaxDatatablesRails::Base

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Payment.created_at', 'Payment.month_year', 'Payment.amount', 'Payment.credit']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Payment.created_at', 'Payment.month_year', 'Payment.amount', 'Payment.credit']
  end

  private

  def data
    records.map do |record|
      [
        I18n.l(record.created_at, :format => '%A, %e de %B del %Y %H:%M hs.'),
        I18n.l(record.month_year, :format => '%B/%Y').capitalize,
        record.amount,
        record.credit
      ]
    end
  end

  def get_raw_records
    Payment.where(:user_id => params[:user_id])
  end

end
