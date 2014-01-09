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

  acts_as_paranoid

  before_validation :set_role
  before_create :set_credit
  before_destroy :remove_payments

  CLIENT_ROLE = 'Cliente'
  ADMIN_ROLE = 'Admin'

  CREDITS_RESET_DAY = "5th"

  scope :clients, -> { where(:role_id => Role.find_by_name(CLIENT_ROLE).id) }

  def last_month_credits
    self.payments.where(:month => Chronic.parse("last month").strftime('%B').downcase).map(&:credit).sum
  end

  def last_month_credits_used
    self.inscriptions.where(:created_at => Chronic.parse("#{CREDITS_RESET_DAY} #{last_month}")..Chronic.parse("#{CREDITS_RESET_DAY}")).count
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def admin?
    self.role.name == ADMIN_ROLE
  end

private

  def last_month
    Chronic.parse("last month").strftime('%B %Y').downcase
  end

  def remove_payments
    self.inscriptions.destroy_all
    self.payments.destroy_all
  end

  def set_role
    self.role ||= Role.find_by_name(CLIENT_ROLE)
  end

  def set_credit
    self.credit ||= 0
  end

end
