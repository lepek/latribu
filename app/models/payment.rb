class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit
  after_destroy :remove_credit

  validates_presence_of :month, :amount, :credit, :user

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
    self.user.credit += self.credit
    self.user.save!
  end

  def remove_credit
    self.user.credit -= self.credit
    self.user.save!
  end
end
