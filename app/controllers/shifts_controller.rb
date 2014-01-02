class ShiftsController < ApplicationController
  load_and_authorize_resource

  # GET /shifts/new
  # GET /shifts/new.json
  def new
    @shift = Shift.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shift }
    end
  end

  # POST /shifts
  # POST /shifts.json
  def create
    @shift = Shift.new(shift_params)
    respond_to do |format|
      if @shift.save
        format.html { redirect_to root_url, notice: 'Nueva Clase creada.' }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { render action: "new" }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /shifts/1
  # GET /shifts/1.json
  def show
    @shift = Shift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shift }
    end
  end

  # GET /shifts/1/edit
  def edit
    @shift = Shift.find(params[:id])
  end

  # PUT /shifts/1
  # PUT /shifts/1.json
  def update
    @shift = Shift.find(params[:id])
    respond_to do |format|
      if @shift.update_attributes(shift_params)
        format.html { redirect_to root_url, notice: 'Clase actualizada.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shifts/1
  # DELETE /shifts/1.json
  def destroy
    @shift = Shift.find(params[:id])

    if @shift.destroy
      flash[:success] = "La Clase del #{@shift.day_and_time} fue eliminada correctamente."
    else
      flash[:error] = @shift.errors.to_a.join("<br />")
    end
    redirect_to root_path(:anchor => 'shifts')
  end

  # GET /shifts/1/inscription
  # GET /shifts/1/inscription.json
  def inscription
    @shift = Shift.find(params[:id])
    respond_to do |format|
      if @shift.enroll_next_shift(current_user)
        format.html { redirect_to clients_path, notice: 'Anotado a la clase.' }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { redirect_to clients_path }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel_inscription
    @shift = Shift.find(params[:id])
    respond_to do |format|
      if @shift.cancel_next_shift(current_user)
        format.html { redirect_to clients_path, notice: 'Clase liberada.' }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { redirect_to clients_path }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def shift_params
      params.require(:shift).permit(:day, :start_time, :max_attendants, :open_inscription, :close_inscription, :instructor_id, :discipline_id)
    end

end
