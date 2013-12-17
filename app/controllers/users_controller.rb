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

end
