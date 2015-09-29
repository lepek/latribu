class ShiftsController < ApplicationController
  authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: ShiftDatatable.new(view_context) }
    end
  end

  def new
    @shift = Shift.new
  end

  def create
    deleted_shifts = Shift.only_deleted.where(start_time: shift_params[:start_time], week_day: shift_params[:week_day])
    if deleted_shifts.present?
      @shift = deleted_shifts.first.restore
      @shift.assign_attributes(shift_params)
    else
      @shift = Shift.new(shift_params)
    end
    if @shift.save
      redirect_to shifts_url, success: 'Nueva Clase creada.'
    else
      render action: "new"
    end
  end

  def show
    @shift = Shift.with_discipline_and_instructor.with_shift_dates.where(id: params[:id]).first
  end

  def edit
    @shift = Shift.find(params[:id])
  end

  def update
    @shift = Shift.find(params[:id])
    if @shift.update_attributes(shift_params)
      redirect_to shifts_url, success: 'Clase actualizada.'
    else
      render action: "edit"
    end
  end

  def destroy
    @shift = Shift.with_shift_dates.where(id: params[:id]).first
    if @shift.destroy
      flash[:success] = "La Clase del #{@shift.day_and_time} fue eliminada correctamente."
    else
      flash[:error] = @shift.errors.to_a.join("<br />")
    end
    redirect_to shifts_url
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


  private

    def format_date_for_alerts
      "<b>#{I18n.l(@shift.next_fixed_shift, :format => '%A, %e de %B %H:%M hs.')}</b>"
    end

    def shift_params
      params[:shift][:start_time] = Time.zone.local(
          params[:shift]['start_time(1i)'],
          params[:shift]['start_time(2i)'],
          params[:shift]['start_time(3i)'],
          params[:shift]['start_time(4i)'],
          params[:shift]['start_time(5i)']
      ).to_s(:time) if params[:shift]['start_time(4i)'].present?
      params[:shift][:end_time] = Time.zone.local(
          params[:shift]['end_time(1i)'],
          params[:shift]['end_time(2i)'],
          params[:shift]['end_time(3i)'],
          params[:shift]['end_time(4i)'],
          params[:shift]['end_time(5i)']
      ).to_s(:time) if params[:shift]['end_time(4i)'].present?
      params.require(:shift).permit(:week_day, :start_time, :end_time, :max_attendants, :open_inscription, :close_inscription, :instructor_id, :discipline_id)
    end

end
