class UsersController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(view_context) }
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:success] = "El usuario <b>#{@user.full_name}</b> fue eliminado correctamente."
    else
      flash[:error] = @user.errors.to_a.join("<br />")
    end
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    params = user_params
    params.delete('password') && params.delete('password_confirmation') if params[:password].blank?
    if @user.update_attributes(params)
      redirect_to users_path, success: "Usuario <b>#{@user.full_name}</b> actualizado."
    else
      render action: "edit"
    end
  end

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to root_path
  end

  def credits
    @last_reset_date = Payment.select('MAX(reset_date) AS reset_date').try(:first).try(:reset_date)
  end

  def reset_search
    date = params[:month_year].present? ? Chronic.parse("1/#{params[:month_year]} 00:00", :endian_precedence => [:little, :middle]) : nil
    render json: UserResetCreditDatatable.new(view_context, { date: date })
  end

  def reset
    if params[:month_year].present?
      date = Chronic.parse("1/#{params[:month_year]} 00:00", :endian_precedence => [:little, :middle])
      User.reset_credits(date)
      flash[:success] = 'Créditos reseteados'
    else
      flash[:error] = 'Debe seleccionar una fecha para realizar el reseteo de créditos'
    end
    redirect_to credits_users_path
  end

  def certificate
    @user = User.find(params[:id])
    if params.has_key?("user_certificate#{@user.id}") and !!params["user_certificate#{@user.id}".to_sym] == true
      @user.update_attributes({:certificate => true})
    else
      @user.update_attributes({:certificate => false})
    end
    head status: :ok
  end

  def set_reset
    User.update_all(reset_credit: true)
    redirect_to users_path, success: "Todos los usuarios están habilitados para ser reseteados."
  end

private

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :phone, :email, :password, :password_confirmation, :enable, :reset_credit, :certificate, :profession, :discipline_ids => [])
  end

end
