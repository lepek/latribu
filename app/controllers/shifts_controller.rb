class ShiftsController < ApplicationController
  authorize_resource

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
    deleted_shifts = Shift.only_deleted.where(start_time: shift_params[:start_time], day: shift_params[:day])
    if deleted_shifts.count > 0
      @shift = deleted_shifts.first
      @shift.restore
      @shift.update(shift_params)
    else
      @shift = Shift.new(shift_params)
    end
    respond_to do |format|
      if @shift.save
        format.html { redirect_to root_url, success: 'Nueva Clase creada.' }
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
    @shift = Shift.eager_load(:instructor, :discipline).find(params[:id])

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
        format.html { redirect_to root_url, success: 'Clase actualizada.' }
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
      if @shift.needs_confirmation?
        format.html { redirect_to clients_path({:shift_id => @shift.id}) }
      elsif @shift.enroll_next_shift(current_user)
        format.html { redirect_to clients_path, success: "Te anotaste a la clase del #{format_date_for_alerts} Tenes hasta las #{last_cancel_time} para liberar la clase" }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { redirect_to clients_path, error: @shift.errors.full_messages.to_sentence }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def indiscriminate_inscription
    @shift = Shift.find(params[:id])
    respond_to do |format|
      if @shift.enroll_next_shift(current_user)
        format.html { redirect_to clients_path, success: "Te anotaste a la clase del #{format_date_for_alerts} Esta clase <b>no puede ser liberada</b>" }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { redirect_to clients_path, error: @shift.errors.full_messages.to_sentence }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel_inscription
    @shift = Shift.find(params[:id])
    respond_to do |format|
      if @shift.cancel_next_shift(current_user)
        format.html { redirect_to clients_path, success: "Liberaste la clase del #{format_date_for_alerts}" }
        format.json { render json: @shift, status: :created, location: @shift }
      else
        format.html { redirect_to clients_path, error: @shift.errors.full_messages.to_sentence }
        format.json { render json: @shift.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def format_date_for_alerts
      "<b>#{I18n.l(@shift.next_fixed_shift, :format => '%A, %e de %B %H:%M hs.')}</b>"
    end

    def last_cancel_time
      "<b>#{I18n.l(Chronic.parse("#{@shift.cancel_inscription} hours ago", :now => @shift.next_fixed_shift), :format => '%H:%M hs.')}</b>"
    end

    def shift_params
      params[:shift][:week_day] = Shift::WEEK_DAYS.key(params[:shift][:week_day]).to_i unless params[:shift].blank? || (1..7).include?(params[:shift][:week_day])
      params.require(:shift).permit(:week_day, :start_time, :end_time, :max_attendants, :open_inscription, :close_inscription, :cancel_inscription, :instructor_id, :discipline_id)
    end

end
