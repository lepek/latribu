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


  def self.reset_credits(mode = :hot)
    if defined?(Rails) && (Rails.env == 'development')
      Rails.logger = Logger.new(STDOUT)
    end
    logger = Rails.logger
    User.clients.each do |user|
      if user.credit > 0 && user.reset_credit?
        credits_unused = user.last_month_credits - user.last_month_credits_used
        if credits_unused > 0
          if user.credit - credits_unused < 0
            logger.info user.id.to_s + " - " + user.full_name
            logger.info "Creditos del ultimo mes: #{user.last_month_credits}"
            logger.info "Creditos usados #{user.last_month_credits_used}"
            logger.info "Creditos no usado: #{credits_unused}"
            logger.info "Credito actual: #{user.credit}"
            logger.info "Credito modificado: #{user.credit - credits_unused}"
            logger.info "====================================================="
          else
            user.credit -= credits_unused
          end
        end

      end
      user.last_reset_date = Chronic.parse("now")
      user.save! if mode == :hot
    end
  end

  ##
  # @return All the inscriptions for classes in the future for this user
  #
  def next_inscriptions
    @next_inscriptions ||= self.inscriptions.where('shift_date >= ?', Chronic.parse("now") )
  end

  def last_month_credits
    self.payments.where(:month => Chronic.parse("last month").strftime('%B').downcase).map(&:credit).sum
  end

  def last_month_credits_used
    self.inscriptions.where(:created_at => self.last_reset_date..Chronic.parse("now")).count
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
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
