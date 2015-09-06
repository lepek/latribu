class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit
  after_destroy :remove_credit

  validates_presence_of :month_year, :amount, :credit, :user

  acts_as_paranoid

  attr_accessor :created_at_formatted, :month_year_formatted
  after_initialize :add_formatted_fields

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

  def attributes
    super.merge({'created_at_formatted' => self.created_at_formatted, 'month_year_formatted' => self.month_year_formatted})
  end

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
    self.user.try(:full_name)
  end

private

  def add_formatted_fields
    self.created_at_formatted = I18n.l(self.created_at, :format => '%A, %e de %B del %Y %H:%M hs.') if self.has_attribute?(:created_at) && !self.created_at.nil?
    self.month_year_formatted = I18n.l(self.month_year, :format => '%B/%Y').capitalize if self.has_attribute?(:month_year) && !self.month_year.nil?
  end
end
