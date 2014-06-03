class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit
  after_destroy :remove_credit

  validates_presence_of :month_year, :amount, :credit, :user

  acts_as_paranoid

  MONTHS = {
      :january => 'enero',
      :february => 'febrero',
      :march => 'marzo',
      :april => 'abril',
      :may => 'mayo',
      :june => 'junio',
      :july => 'julio',
      :august => 'agosto',
      :september => 'septiembre',
      :october => 'octubre',
      :november => 'noviembre',
      :december => 'diciembre'
  }

  def self.months
    MONTHS
  end

  def add_credit
    self.user.increment!(:credit, self.credit)
  end

  def remove_credit
    self.user.decrement!(:credit, self.credit)
  end
end
