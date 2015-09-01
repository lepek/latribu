class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit
  after_destroy :remove_credit

  validates_presence_of :month_year, :amount, :credit, :user

  acts_as_paranoid

  def self.months
    MONTHS
  end

  def add_credit
    self.user.increment!(:credit, self.credit)
  end

  def remove_credit
    self.user.decrement!(:credit, self.credit)
  end

  def user_full_name
    self.user.full_name
  end

end
