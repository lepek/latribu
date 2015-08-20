class UsersController < ApplicationController
  authorize_resource

  def index
    @users = User.accessible_by(current_ability).clients.order("last_name")
    render 'users/_tab', :layout => false
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      flash[:success] = "El usuario <b>#{@user.full_name}</b> fue eliminado correctamente."
    else
      flash[:error] = @user.errors.to_a.join("<br />")
    end
    redirect_to root_path(:anchor => 'users')
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    params = user_params
    params.delete('password') && params.delete('password_confirmation') if params[:password].blank?
    respond_to do |format|
      if @user.update_attributes(params)
        format.html { redirect_to root_url, success: "Usuario <b>#{@user.full_name}</b> actualizado." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
    #@credits_to_reset = Payment.select('credit-used_credit AS spare_credit').where("reset_date IS NULL AND month_year <= '#{month_year}'").map(&:spare_credit).sum
    @last_reset_date = Payment.select('MAX(reset_date) AS reset_date').try(:first).try(:reset_date)
  end

  def reset_search
    data = []
    @month = params[:month]
    @year = params[:year]
    month_year = Chronic.parse("1 #{@month} #{@year}")
    User.to_reset.find_each do |user|
      future_credit = 0
      if user.credit > 0
        future_credit = user.calculate_future_credit(month_year)
        future_credit = user.credit if future_credit > user.credit # Fix because the first reset was forced directly in the user model
      end
      data << {:full_name => user.full_name, :current_credit => user.credit, :future_credit => future_credit}
    end
    render status: :ok, json: { "aaData" => data }
  end

  def reset
    @month = params[:month]
    @year = params[:year]
    month_year = Chronic.parse("1 #{@month} #{@year}")
    User.reset_credits(month_year)
    redirect_to credits_users_path
  end

  def certificate
    @user = User.find(params[:id])
    if params.has_key?("user_certificate#{@user.id}") and !!params["user_certificate#{@user.id}".to_sym] == true
      @user.update_attributes({:certificate => true})
    else
      @user.update_attributes({:certificate => false})
    end
    render status: :ok, json: {}
  end

  def set_reset
    User.update_all(reset_credit: true)
    redirect_to root_path(:anchor => 'users'), success: "Todos los usuarios están habilitados para ser reseteados."
  end

private

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :phone, :email, :password, :password_confirmation, :enable, :reset_credit, :certificate, :profession, :discipline_ids => [])
  end

end
