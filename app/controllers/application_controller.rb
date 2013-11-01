require 'datatables/controller_mixin'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include Datatables::ControllerMixin

  before_filter :set_time_zone
  before_filter :authenticate_user!, :unless => :devise_controller?

  # Fix to make Cancan work with Rails 4 and string paramters
  # https://github.com/ryanb/cancan/issues/835#issuecomment-18663815
  before_filter do
    resource = controller_path.singularize.gsub('/', '_').to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def set_time_zone
    Chronic.time_class = Time.zone
  end

  def after_sign_in_path_for(user)
    if current_user.admin?
      admins_path
    else
      clients_path
    end
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name, :phone]
    end

end
