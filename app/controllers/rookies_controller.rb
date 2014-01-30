class RookiesController < ApplicationController

  # GET /rookies/new_in_shift
  def new_in_shift
    @rooky = Rooky.new
    @shift = Shift.find(params[:shift_id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rooky }
    end
  end

  # POST /rookies
  # POST /rookies.json
  def create
    @rooky = Rooky.new(rooky_params)
    @shift = Shift.find(params[:rooky][:shift_id])
    respond_to do |format|
      if @shift.enroll_next_shift_rooky(@rooky)
        format.html { redirect_to root_url, notice: "#{@rooky.full_name} fue inscripto/a en una clase de prueba" }
        format.json { render json: @rooky, status: :created, location: @rooky }
      else
        format.html { render action: "new_in_shift" }
        format.json { render json: @rooky.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @rooky = Rooky.find(params[:id])

    if @rooky.destroy
      flash[:success] = "La inscripción de #{@rooky.full_name} fue eliminada correctamente."
    else
      flash[:error] = @rooky.errors.to_a.join("<br />")
    end
    redirect_to root_path(:anchor => 'rookies')
  end

private

  def rooky_params
    params.require(:rooky).permit(:full_name, :phone, :email, :shift_id, :notes)
  end

end
