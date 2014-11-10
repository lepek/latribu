class Ability
  include CanCan::Ability

  def initialize(user)
    @user = (user || User.new) # in case of guest
    set_permissions_for_any_role
    unless @user.role.nil?
      if @user.role.name == 'Admin'
        set_permissions_for_admin
      elsif @user.role.name == 'Cliente'
        set_permissions_for_cliente
      end
    end
  end

  private

  def set_permissions_for_any_role
    can [:read, :update], User, :id => @user.id
  end

  def set_permissions_for_cliente
    can :manage, Inscription, :user_id => @user.id
    can :read, [Shift, Instructor, Discipline]
    can :read, Payment, :user_id => @user.id
    can [:inscription, :cancel_inscription, :indiscriminate_inscription], Shift
    can :access, :client
    can :stop_impersonating, User
  end

  def set_permissions_for_admin
    can :manage, [User, Shift, Instructor, Discipline, Payment, Stat, Rooky]
    can :access, :admin
  end

end
