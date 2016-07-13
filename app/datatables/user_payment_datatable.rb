class UserPaymentDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :link_to, :edit_payment_path, :payment_path


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
      open_bold_tag, close_bold_tag = '', ''
      unless record.reset_date
        open_bold_tag, close_bold_tag = '<strong>', '</strong>'
      end
      [
        open_bold_tag + I18n.l(record.created_at, :format => '%A, %e de %B del %Y %H:%M hs.') + close_bold_tag,
        open_bold_tag + I18n.l(record.credit_end_date, :format => '%A, %e de %B del %Y') + close_bold_tag,
        open_bold_tag + record.amount.to_s + close_bold_tag,
        open_bold_tag + record.credit.to_s + close_bold_tag,
        open_bold_tag + record.used_credit.to_s + close_bold_tag,
        link_to('Editar', edit_payment_path(record), class: "btn btn-default") + ' ' + maybe_show_delete_button(record)
      ]
    end
  end

  def get_raw_records
    Payment.where(:user_id => params[:user_id])
  end

  def maybe_show_delete_button(record)
    if record.used_credit == 0
      return link_to('Borrar', payment_path(record), class: "btn btn-default", data: { confirm: "¿Está seguro que desea eliminar el pago?" }, method: :delete)
    end
  end

end
