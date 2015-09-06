class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit
  after_destroy :remove_credit

  validates_presence_of :month_year, :amount, :credit, :user

  acts_as_paranoid

  def add_credit
    self.user.increment!(:credit, self.credit)
  end

  def remove_credit
    self.user.decrement!(:credit, self.credit)
  end

  def self.filter_by_dates(date_from, date_to)
    if date_from.present? && date_to.present?
      from = Chronic.parse(date_from, :endian_precedence => [:little, :middle])
      to = Chronic.parse(date_to, :endian_precedence => [:little, :middle])
      Payment.joins(:user).where(created_at: from..to)
    else
      Payment.joins(:user).all
    end

  end

end
