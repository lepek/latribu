class RookiesController < ApplicationController

  def new_in_shift
    @rooky = Rooky.new
    @shift = Shift.with_shift_dates.where(id: params[:shift_id]).first
  end

  def create
    @rooky = Rooky.new(rooky_params)
    @shift = Shift.with_shift_dates.where(id: params[:rooky][:shift_id]).first
    if @shift.enroll_next_shift_rooky(@rooky)
      redirect_to shifts_url, notice: "#{@rooky.full_name} fue inscripto/a en una clase de prueba"
    else
      render action: "new_in_shift"
    end
  end

  def destroy
    @rooky = Rooky.find(params[:id])
    @shift = @rooky.shift
    if @rooky.destroy
      @shift.cancel_inscription_rooky
      flash[:success] = "La inscripción de #{@rooky.full_name} fue eliminada correctamente."
    else
      flash[:error] = @rooky.errors.to_a.join("<br />")
    end
    redirect_to root_path(:anchor => 'rookies')
  end

  def attended
    @rooky = Rooky.find(params[:id])
    if params.has_key?("rooky_attended#{@rooky.id}") and !!params["rooky_attended#{@rooky.id}".to_sym] == true
      @rooky.update_attributes({:attended => true})
    else
      @rooky.update_attributes({:attended => false})
    end
    render status: :ok, json: {}
  end

private

  def rooky_params
    params.require(:rooky).permit(:full_name, :phone, :email, :shift_id, :notes)
  end

end
