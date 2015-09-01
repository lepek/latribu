class PaymentDatatable < AjaxDatatablesRails::Base

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Payment.created_at', 'User.last_name', 'Payment.amount', 'Payment.credit', 'Payment.month_year']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Payment.created_at', 'User.last_name', 'Payment.amount', 'Payment.credit', 'Payment.month_year']
  end

  private

  def data
    records.map do |record|
      [
        I18n.l(record.created_at, :format => '%A, %e de %B del %Y %H:%M hs.'),
        record.user.full_name,
        record.amount,
        record.credit,
        I18n.l(record.month_year, :format => '%B/%Y').capitalize
      ]
    end
  end

  def get_raw_records
    if params[:date_from].present? && params[:date_to].present?
      from = Chronic.parse(params[:date_from], :endian_precedence => [:little, :middle])
      to = Chronic.parse(params[:date_to], :endian_precedence => [:little, :middle])
      Payment.joins(:user).where(created_at: from..to)
    else
      Payment.joins(:user).all
    end
  end

end
