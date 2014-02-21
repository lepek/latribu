class ClientsController < ApplicationController
  def index
    authorize! :access, :client

    if current_user.is_new?
      @shifts = Shift.accessible_by(current_ability).eager_load(:instructor)
      @events = current_user.inscriptions.eager_load(:shift => :discipline)
    end
  end
end