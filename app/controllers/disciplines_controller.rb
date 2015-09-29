class DisciplinesController < ApplicationController
  authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: DisciplineDatatable.new(view_context) }
    end
  end

  def edit
    @discipline = Discipline.find(params[:id])
  end

  def update
    @discipline = Discipline.find(params[:id])
    @discipline.update_attributes!(discipline_params)
    redirect_to disciplines_path, success: "#{@discipline.name} a sido modificada."

  end

  def enable_all
    discipline = Discipline.find(params[:id])
    User.find_each do |user|
      user.disciplines << discipline unless user.disciplines.include?(discipline)
    end
    redirect_to disciplines_path, success: "Todos los usuarios pueden inscribirse a #{discipline.name}"

  end

  def disable_all
    discipline = Discipline.find(params[:id])
    User.find_each do |user|
      user.disciplines.delete(discipline) if user.disciplines.include?(discipline)
    end
    redirect_to disciplines_path, success: "Ningún usuario puede inscribirse a #{discipline.name}"
  end

  def destroy
    discipline = Discipline.find(params[:id])
    if discipline.shifts.count > 0
      redirect_to disciplines_path, error: "#{discipline.name} no puede ser borrada porque es usada para clases."
    elsif discipline.users.count > 0
      redirect_to disciplines_path, error: "#{discipline.name} no puede ser borrada porque es usada por usuarios."
    else
      discipline.destroy
      redirect_to disciplines_path, success: "#{discipline.name} fue borrada."

    end
  end

  def discipline_params
    params.require(:discipline).permit(:name, :default, :color, :font_color)
  end

end