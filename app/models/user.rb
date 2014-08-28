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

  scope :clients, -> { where(:role_id => Role.find_by_name(CLIENT_ROLE).id) }

  attr_accessor :full_name
  after_initialize :full_name


  def self.reset_credits
    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
    end
    logger = Rails.logger
    User.clients.each do |user|
      #user = User.find(154)
      if user.reset_credit?
        user.payments.where("reset_date IS NULL AND month_year < '#{Chronic.parse('1 this month')}'").update_all(:reset_date => Chronic.parse("now"))
        total_credit = user.payments.where('reset_date IS NULL').map(&:credit).sum
        used_credit = user.payments.where('reset_date IS NULL').map(&:used_credit).sum

        logger.info user.id.to_s + " - " + user.full_name
        logger.info "Credito actual: #{user.credit}"
        logger.info "Nuevo credito: #{total_credit - used_credit}"

        user.last_reset_date = Chronic.parse("now")
        user.credit = total_credit - used_credit
        user.save!
      end
    end
  end

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
  def is_new?
    self.admin? || self.credit > 0 || self.inscriptions.any?
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

end
