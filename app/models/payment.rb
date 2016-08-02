class Payment < ActiveRecord::Base
  belongs_to :user

  before_update :clean_reset_date
  before_destroy :validate_no_used_credit

  after_commit :update_credit

  validates_presence_of :month_year, :amount, :credit, :user, :credit_start_date, :credit_end_date
  validates_numericality_of :credit, greater_than_or_equal_to: ->(p) { p.used_credit.to_i }
  validate :valid_date_range_required

  audited

  def self.filter_by_dates(date_from, date_to)
    if date_from.present? && date_to.present?
      from = Chronic.parse(date_from, :endian_precedence => [:little, :middle])
      to = Chronic.parse(date_to, :endian_precedence => [:little, :middle])
      Payment.joins(:user).where(created_at: from..to)
    else
      Payment.joins(:user)
    end
  end

  def self.total_payments(date_from, date_to)
    self.filter_by_dates(date_from, date_to).select('SUM(amount) as total_payments').first.total_payments rescue 0
  end


private

  def clean_reset_date
    self.reset_date = nil
  end

  def update_credit
    self.user.update_credits!
  end

  def valid_date_range_required
    errors.add(:base, "La fecha de vencimiento de créditos debe ser mayor que la fecha de comienzo de validez de los créditos") if (credit_start_date > credit_end_date)
  end

  def validate_no_used_credit
    if (used_credit.to_i != 0)
      errors.add(:base, "El Pago no puede ser borrado porque ya se han usado créditos del mismo")
      return false
    end
  end


end
