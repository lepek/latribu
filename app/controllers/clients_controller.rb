class ClientsController < ApplicationController
  def index
    authorize! :access, :client

    if current_user.is_not_new?
      @shifts = Shift.accessible_by(current_ability).eager_load(:instructor, :discipline)
      @events = current_user.inscriptions.joins(:shift => :discipline)
    end

    if params[:shift_id].present?
      @shift = Shift.find(params[:shift_id])
      @shift = nil unless @shift.needs_confirmation?
    end

  end
end