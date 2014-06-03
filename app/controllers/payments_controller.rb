class PaymentsController < ApplicationController
  load_and_authorize_resource

  def user_payments
    @payments = Payment.select('id, amount, month_year, credit, created_at, NULL AS created_at_formatted').where(:user_id => params[:user_id]).to_a.map(&:serializable_hash)
    @payments.each do |p|
      p['created_at_formatted'] = I18n.l(p['created_at'], :format => '%A, %e de %B %H:%M hs.')
      p['month'] = I18n.l(p['month_year'], :format => '%B').capitalize
    end
    respond_to do |format|
      format.json { render json: "{\"aaData\": #{@payments.to_json}}" }
    end
  end

  # GET /payments/new
  # GET /payments/new.json
  def new
    @payment = Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment }
    end
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
