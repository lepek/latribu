class PaymentsController < ApplicationController

  def index
    respond_to do |format|
      format.html

      format.json {
        if params[:user_id].present?
          render json: UserPaymentDatatable.new(view_context)
        else
          render json: PaymentDatatable.new(view_context)
        end
      }

      format.xlsx {
        @payments = Payment.filter_by_dates(params[:date_from], params[:date_to])
        render xlsx: 'excel', filename: "la_tribu-pagos-#{Date.today.strftime}.xlsx"
      }
    end
  end

  def edit
    @payment = Payment.find(params[:id])
    @user = @payment.user
  end

  def update
    @payment = Payment.find(params[:id])
    @user = @payment.user
    params = payment_params
    month = params.delete(:month)
    year = params.delete(:year)
    if @payment.update_attributes({
        month_year: Chronic.parse("1 #{month} #{year}"),
        credit_start_date: params[:credit_start_date],
        credit_end_date: params[:credit_end_date],
        amount:  params[:amount],
        credit: params[:credit],
      })
      redirect_to new_user_payment_path(@payment.user_id), notice: "El Pago de #{@payment.user.full_name} fue modificado correctamente."
    else
      flash[:error] = @payment.errors.to_a.join("<br />")
      render action: "edit"
    end

  end

  def total_payments
    total = Payment.total_payments(params[:date_from], params[:date_to])
    render json: { total: ActionController::Base.helpers.number_to_currency(total) }
  end

  def new
    @user = User.find(params[:user_id])
    @payment = @user.payments.build
  end

  def create
    params = payment_params
    @user = User.find(params[:user_id])
    month = params.delete(:month)
    year = params.delete(:year)
    params = params.merge( {:month_year => Chronic.parse("1 #{month} #{year}")} )
    @payment = Payment.new(params)
    if @payment.save
      redirect_to new_user_payment_url(@user), notice: 'Nuevo Pago creado.'
    else
      flash[:error] = @payment.errors.to_a.join("<br />")
      render action: "new"
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment = Payment.find(params[:id])
    if @payment.destroy
      flash[:success] = "El Pago de #{@payment.user.full_name} fue eliminado correctamente."
    else
      flash[:error] = @payment.errors.to_a.join("<br />")
    end
    redirect_to new_user_payment_path(@payment.user_id)
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id, :amount, :credit, :month, :year, :credit_start_date, :credit_end_date)
  end

end
