class InscriptionsController < ApplicationController

  def attended
    @inscription = Inscription.find(params[:id])
    if params.has_key?("user_attended#{@inscription.id}") and !!params["user_attended#{@inscription.id}".to_sym] == true
      @inscription.update_attributes({:attended => true})
    else
      @inscription.update_attributes({:attended => false})
    end
    render status: :ok, json: {}
  end

end
