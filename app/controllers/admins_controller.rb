class AdminsController < ApplicationController

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to clients_url
  end

  def index
    authorize! :access, :admin

    @shifts = Shift.accessible_by(current_ability)
    @shift = Shift.accessible_by(current_ability).get_next_class
    @stats = Stat.accessible_by(current_ability).credit_and_inscriptions
    @rookies = Rooky.accessible_by(current_ability).pending

  end

end
