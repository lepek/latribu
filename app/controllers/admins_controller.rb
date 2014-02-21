class AdminsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to clients_url
  end

  def index
    authorize! :access, :admin

    @shifts = Shift.accessible_by(current_ability)
    @users = User.accessible_by(current_ability).clients.order("last_name")
    @payments = Payment.accessible_by(current_ability).where('payments.created_at in (?)',
      Payment.accessible_by(current_ability).select(:user_id, 'MAX(created_at) as created_at').group(:user_id).map(&:created_at)
    ).includes(:user).order("payments.created_at DESC")
    @shift = Shift.accessible_by(current_ability).get_next_class
    @stats = Stat.accessible_by(current_ability).credit_and_inscriptions
    @rookies = Rooky.accessible_by(current_ability).pending

  end

end
