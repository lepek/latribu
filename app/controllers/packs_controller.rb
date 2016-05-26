class PacksController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: PackDatatable.new(view_context) }
    end
  end

  def new
    @pack = Pack.new
  end

  def create
    binding.pry
    @pack = Pack.new(pack_params)
    if @pack.save
      redirect_to packs_path, success: "Nuevo Pack de clases creado."
    else
      render :new
    end
  end

  def edit
    @pack = Pack.find(params[:id])
  end

  def update
    @pack = Pack.find(params[:id])
    @pack.update_attributes!(pack_params)
    redirect_to packs_path, success: "El Pack de clases ha sido modificado."
  end

  def destroy
    @pack = Pack.find(params[:id])
    @pack.destroy
    redirect_to packs_path, success: "El Pack de clases ha sido borrado."
  end

  def pack_params
    params.require(:pack).permit(:name, :enabled, shift_ids: [])
  end

end