class PaymentsController < ApplicationController
  authorize_resource

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

  def new
    @user = User.find(params[:user_id])
    @payment = @user.payments.build
  end

  # POST /payments
  # POST /payments.json
  def create
    params = payment_params
    month = params.delete(:month)
    year = params.delete(:year)
    params = params.merge( {:month_year => Chronic.parse("1 #{month} #{year}")} )
    @payment = Payment.new(params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to root_url, notice: 'Nuevo Pago creado.' }
        format.json { render json: @payment, status: :created, location: @payment }
      else
        format.html { render action: "new" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
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
    redirect_to root_path(:anchor => 'payment')
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id, :amount, :credit, :month, :year)
  end

end
