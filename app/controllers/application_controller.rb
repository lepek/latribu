class ApplicationController < ActionController::Base
  add_flash_types :error, :success

  layout :set_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'destroy' }

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

  impersonates :user

  def after_sign_in_path_for(user)
    if current_user.admin?
      admins_path
    else
      inscriptions_path
    end
  end

  private

  def messages
    if current_user.present? && !current_user.admin? && current_user.credit == 0
      flash[:warning] = "No podrás incribirte a ningún turno por no tener créditos. Comunicate con La Tribu para poder volver a entrenar."
    end
  end

  def set_time_zone
    Chronic.time_class = Time.zone
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :phone, :profession]
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name, :phone, :profession]
  end

  def set_layout
    current_user.present? ? 'application' : 'guest'
  end

end
