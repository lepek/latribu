class AdminsController < ApplicationController
  def index
    authorize! :access, :admin

    @shifts = Shift.accessible_by(current_ability).order("day")
    @users = User.accessible_by(current_ability).order("last_name")
    @payments = Payment.accessible_by(current_ability).order("created_at")
  end
end
