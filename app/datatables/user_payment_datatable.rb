class UserPaymentDatatable < AjaxDatatablesRails::Base

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Payment.created_at', 'Payment.credit_end_date', 'Payment.amount', 'Payment.credit', 'Payment.used_credit']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Payment.created_at', 'Payment.credit_end_date', 'Payment.amount', 'Payment.credit', 'Payment.used_credit']
  end

  private

  def data
    records.map do |record|
      [
        I18n.l(record.created_at, :format => '%A, %e de %B del %Y %H:%M hs.'),
        I18n.l(record.credit_end_date, :format => '%A, %e de %B del %Y'),
        record.amount,
        record.credit,
        record.used_credit
      ]
    end
  end

  def get_raw_records
    Payment.where(:user_id => params[:user_id])
  end

end
