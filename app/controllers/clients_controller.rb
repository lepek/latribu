class ClientsController < ApplicationController
  def index
    authorize! :access, :client

    @shifts = Shift.accessible_by(current_ability).includes(:instructor)
    @events = current_user.inscriptions.includes(:shift => :discipline)
  end
end