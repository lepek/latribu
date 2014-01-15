require 'datatables/controller_mixin'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Datatables::ControllerMixin

  before_filter :set_time_zone
  before_filter :authenticate_user!, :unless => :devise_controller?
  before_filter :configure_permitted_parameters, :if => :devise_controller?
  before_filter :messages

  # Fix to make Cancan work with Rails 4 and string paramters
  # https://github.com/ryanb/cancan/issues/835#issuecomment-18663815
  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def after_sign_in_path_for(user)
    if current_user.admin?
      admins_path
    else
      clients_path
    end
  end

protected

  def messages
    unless current_user.nil?
      unless current_user.admin?
        if current_user.credit == 0
          flash[:warning] = "No podrás incribirte a ningún turno por no tener créditos. Comunicate con Nahual para poder volver a entrenar."
        end
        time_gap_to_reset = (Chronic.parse("5th this month").to_date - Chronic.parse("now").to_date).to_i
        if current_user.credit > 0 && time_gap_to_reset > 0 && time_gap_to_reset < 9
          flash[:info] = "A partir del <b>#{I18n.localize(Chronic.parse("8th this month"), :format => '%A,%e de %B')}</b> no podrán usarse los créditos del mes anterior."
        end
      end
    end
  end

  def set_time_zone
    Chronic.time_class = Time.zone
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :phone]
  end

end
