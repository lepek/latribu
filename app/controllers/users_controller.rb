class UsersController < ApplicationController
  load_and_authorize_resource

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

private

  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :phone, :email, :password, :password_confirmation)
  end

end
