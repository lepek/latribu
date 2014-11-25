class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :rememberable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable

  belongs_to :role
  has_many :payments
  has_many :inscriptions
  has_many :shifts, through: :inscriptions
  has_many :user_disciplines
  has_many :disciplines, through: :user_disciplines

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :role

  acts_as_paranoid

  before_validation :set_role
  before_create :set_credit
  after_create :set_discipline
  before_destroy :remove_payments

  CLIENT_ROLE = 'Cliente'
  ADMIN_ROLE = 'Admin'

  scope :clients, -> { where(:role_id => Role.find_by_name(CLIENT_ROLE).id) }

  scope :to_reset, -> { where('reset_credit = 1') }

  attr_accessor :full_name
  after_initialize :full_name

  def attributes
    super.merge({'full_name' => self.full_name})
  end

  ##
  # @return All the inscriptions for classes in the future for this user
  #
  def next_inscriptions
    @next_inscriptions ||= self.inscriptions.where('shift_date >= ?', Chronic.parse("now") )
  end

  def full_name
    self.full_name = "#{self.first_name} #{self.last_name}" if self.has_attribute?(:first_name) && self.has_attribute?(:last_name)
  end

  def full_name_email
    "#{self.first_name} #{self.last_name} (#{self.email})"
  end

  def admin?
    self.role.name == ADMIN_ROLE
  end

  def reset_credit?
    self.reset_credit
  end

  ##
  # @return [Boolean] If the user is a pretty new user without credits or inscriptions
  #
  def is_not_new?
    self.admin? || self.credit > 0 || self.inscriptions.any?
  end

  def calculate_future_credit(month_year)
    self.payments.select('credit-used_credit AS future_credit').where("reset_date IS NULL AND month_year > '#{month_year}'").map(&:future_credit).sum
  end

  def self.reset_credits(month_year = Chronic.parse("1 this month"))
    User.to_reset.find_each do |user|
      future_credit = 0
      if user.credit > 0
        future_credit = user.calculate_future_credit(month_year)
        future_credit = user.credit if future_credit > user.credit # Fix because the first reset was forced directly in the user model
      end
      user.update_attributes({:credit => future_credit})
      user.payments.where("reset_date IS NULL AND month_year <= '#{month_year}'").update_all({:reset_date => Chronic.parse("now")})
    end
  end

  def active_for_authentication?
    enable?
  end

  def inactive_message
    enable? ? super : "Tu cuenta de usuario fue suspendida temporalmente. Contactate con la administración."
  end

private

  def last_month
    Chronic.parse("last month").strftime('%B %Y').downcase
  end

  def current_month
    Chronic.parse("now").strftime('%B %Y').downcase
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

  def set_discipline
    begin
      self.disciplines << Discipline.find(1) if !self.admin? && self.disciplines.empty?
    rescue ActiveRecord::RecordNotFound
    end
  end

end
