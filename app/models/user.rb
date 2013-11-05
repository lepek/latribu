class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  belongs_to :role
  has_many :payments
  has_many :inscriptions
  has_many :shifts, through: :inscriptions


  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :role

  before_validation :set_role

  before_create :set_credit

  CLIENT_ROLE = 'Cliente'
  ADMIN_ROLE = 'Admin'

  scope :clients, -> { where(:role_id => Role.find_by_name(CLIENT_ROLE).id) }

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def admin?
    self.role.name == ADMIN_ROLE
  end

  private

    def set_role
      self.role ||= Role.find_by_name(CLIENT_ROLE)
    end

    def set_credit
      self.credit = 0
    end

end
