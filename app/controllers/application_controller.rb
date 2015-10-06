class ApplicationController < ActionController::Base

  ADMIN_CONTROLLERS = ['disciplines', 'payments', 'rookies', 'shifts', 'stats', 'users']

  add_flash_types :error, :success

  layout :set_layout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: -> { controller_name == 'sessions' && action_name == 'destroy' }

  before_filter :authenticate_user!, :unless => :devise_controller?
  before_filter :authorize_admin_actions, if: -> { current_user.present? }
  before_filter :configure_permitted_parameters, :if => :devise_controller?
  before_filter :messages

  impersonates :user

  def after_sign_in_path_for(user)
    if current_user.admin?
      next_class = Shift.get_next_class
      next_class.present? ? shift_path(next_class) : shifts_path
    else
      inscriptions_path
    end
  end

  private

  def authorize_admin_actions
    raise CanCan::AccessDenied if ADMIN_CONTROLLERS.include?(controller_name) && !current_user.admin?
  end

  def messages
    if current_user.present? && !current_user.admin? && current_user.credit == 0
      flash[:warning] = "No podrás incribirte a ningún turno por no tener créditos. Comunicate con La Tribu para poder volver a entrenar."
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :phone, :profession]
    devise_parameter_sanitizer.for(:account_update) << [:first_name, :last_name, :phone, :profession]
  end

  def set_layout
    current_user.present? ? 'application' : 'guest'
  end

end
