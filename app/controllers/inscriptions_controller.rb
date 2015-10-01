class InscriptionsController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: Shift.with_discipline_and_instructor.with_shift_dates.as_json({user: current_user}) }
    end
  end

  def create
    @shift = Shift.with_shift_dates.where(id: params[:id]).first
    if @shift.enroll_next_shift(current_user)
      render json: current_user.reload, status: :created
    else
      render json: @shift.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @shift = Shift.with_shift_dates.where(id: params[:id]).first
    if @shift.cancel_next_shift(current_user)
      render json: current_user.reload, status: :created
    else
      render json: @shift.errors, status: :unprocessable_entity
    end
  end

  def attended
    raise CanCan::AccessDenied unless current_user.admin?
    @inscription = Inscription.find(params[:id])
    if params.has_key?("user_attended#{@inscription.id}") and !!params["user_attended#{@inscription.id}".to_sym] == true
      @inscription.update_attributes({:attended => true})
    else
      @inscription.update_attributes({:attended => false})
    end
    head status: :ok
  end

end
