class AdminsController < ApplicationController
  def index
    authorize! :access, :admin

    @shifts = Shift.accessible_by(current_ability).order("day")
    @users = User.accessible_by(current_ability).clients.order("last_name")
    @payments = Payment.accessible_by(current_ability).where(:created_at =>
      Payment.accessible_by(current_ability).select(:user_id, 'MAX(created_at) as created_at').group(:user_id).map(&:created_at)
    ).order("created_at DESC")
  end
end
