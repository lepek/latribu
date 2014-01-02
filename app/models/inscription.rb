class Inscription < ActiveRecord::Base
  belongs_to :shift
  belongs_to :user

  after_destroy :add_credit
  after_create :remove_credit

  ##
  # Refund the credit when an inscriptions is deleted
  #
  def add_credit
    self.user.credit += 1
    self.user.save
  end

  ##
  # One inscription cost one credit and we account it here
  #
  def remove_credit
    self.user.credit -= 1
    self.user.save
  end

  ##
  # For the calendar
  #
  def start_time
    self.shift_date
  end

end
