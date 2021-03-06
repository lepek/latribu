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
  belongs_to :pack

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :phone
  validates_presence_of :role

  before_validation :set_role
  before_create :set_credit
  after_create :set_discipline
  before_destroy :remove_future_inscriptions

  CLIENT_ROLE = 'Cliente'
  ADMIN_ROLE = 'Admin'

  scope :clients, -> { where(:role_id => Role.find_by_name(CLIENT_ROLE).id) }
  scope :to_reset, -> { clients.where('reset_credit = 1') }

  def pending_messages
    Message.where(
      "start_date <= ? AND end_date >= ? AND ( show_all = true OR show_credit_less >= ? #{show_no_certificate} )",
      Chronic.parse('now').strftime('%Y-%m-%d'), Chronic.parse('now').strftime('%Y-%m-%d'), self.credit
    ).pluck(:message)
  end

  def full_name
    "#{last_name}, #{first_name}" if has_attribute?(:first_name) && has_attribute?(:last_name)
  end

  def to_s
    full_name || super
  end

  def name
    "#{first_name} #{last_name} (#{email})"
  end

  def admin?
    role.name == ADMIN_ROLE
  end

  ##
  # @return [Boolean] If the user is a pretty new user without credits or inscriptions
  #
  def is_not_new?
    admin? || credit > 0 || inscriptions.any?
  end

  def calculate_future_credit(month_year)
    return 0 unless credit > 0
    future_credit = payments.select('credit - used_credit AS future_credit').where("reset_date IS NULL AND month_year > '#{month_year}'").map(&:future_credit).sum
    # Fix because the first reset was forced directly in the user model
    return future_credit > credit ? credit : future_credit
  end

  def self.reset_credits(month_year)
    month_year = month_year.present? ? Chronic.parse(month_year.to_s) : nil
    raise ArgumentError, 'A date to reset must be provided' if month_year.nil?
    month_year = month_year.strftime('%Y-%m-%d %H:%M')
    User.transaction do
      User.to_reset.find_each do |user|
        future_credit = 0
        if user.credit > 0
          future_credit = user.calculate_future_credit(month_year)
          future_credit = user.credit if future_credit > user.credit # Fix because the first reset was forced directly in the user model
        end
        user.update(credit: future_credit)
        user.payments.where("reset_date IS NULL AND month_year <= '#{month_year}'").update_all({:reset_date => Chronic.parse("now")})
      end
    end
  end

  def active_for_authentication?
    enable?
  end

  def inactive_message
    enable? ? super : "Tu cuenta de usuario fue suspendida temporalmente. Contactate con la administración."
  end

  def update_credits!
    self.payments.where(
        "reset_date IS NULL AND
        credit_end_date != '0000-00-00' AND
        credit_end_date < '#{Chronic.parse("now").strftime('%Y-%m-%d')}'"
    ).update_all(reset_date: Chronic.parse("now"))
    self.credit = payments.select('credit - used_credit AS future_credit')
                      .where("reset_date IS NULL AND credit_start_date <= '#{Chronic.parse("now").strftime('%Y-%m-%d')}'")
                      .map(&:future_credit).sum
    self.save!
  end

  def last_credit_end_date
    return nil unless self.credit > 0
    self.payments.where(reset_date: nil).where('credit > 0').order(credit_end_date: :desc).limit(1).pluck(:credit_end_date).try(:first)
  end

private

  def show_no_certificate
    return 'OR show_no_certificate = true' unless self.certificate?
  end

  def last_month
    Chronic.parse("last month").strftime('%B %Y').downcase
  end

  def current_month
    Chronic.parse("now").strftime('%B %Y').downcase
  end

  def remove_future_inscriptions
    inscriptions.where("shift_date > '#{Chronic.parse("now")}'").destroy_all
  end

  def set_role
    self.role ||= Role.find_by_name(CLIENT_ROLE)
  end

  def set_credit
    self.credit ||= 0
  end

  def set_discipline
    default_disciplines = Discipline.where(:default => true)
    self.disciplines = default_disciplines if default_disciplines.present? && !admin? && disciplines.empty?
  end

end
