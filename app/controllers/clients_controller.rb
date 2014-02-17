class ClientsController < ApplicationController
  def index
    authorize! :access, :client

    @shifts = Shift.accessible_by(current_ability).eager_load(:instructor)
    @events = current_user.inscriptions.eager_load(:shift => :discipline)
  end
end