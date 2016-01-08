class PastShiftsController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: PastShiftDatatable.new(view_context) }
    end
  end

  def show
    @shift_date = Chronic.parse(URI.decode(params[:id]))
    @inscriptions = Inscription.where(shift_date: @shift_date).preload(:user)
    @rookies = Rooky.where(shift_date: @shift_date)
  end

end
