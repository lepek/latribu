class ClientsController < ApplicationController
  def index
    @shifts = Shift.accessible_by(current_ability).order("day")
  end
end