class ClientsController < ApplicationController
  def index
    authorize! :access, :client

    @shifts = Shift.accessible_by(current_ability).order("day")
    @events = current_user.inscriptions
  end
end