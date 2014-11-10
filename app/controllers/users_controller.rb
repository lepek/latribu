class UsersController < ApplicationController
  authorize_resource

  def index
    @users = User.accessible_by(current_ability).clients.order("last_name")
    render 'users/_tab', :layout => false
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      flash[:success] = "El cliente #{@user.full_name} fue eliminado correctamente."
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
        format.html { redirect_to root_url, success: 'Usuario actualizado.' }
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
    month_year = Chronic.parse("1 this month")
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

private

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :phone, :email, :password, :password_confirmation, :reset_credit, :discipline_ids => [])
  end

end
