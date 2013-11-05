class Inscription < ActiveRecord::Base
  belongs_to :shift
  belongs_to :user

  after_destroy :add_credit

  after_create :remove_credit

  def add_credit
    self.user.credit += 1
    self.user.save
  end

  def remove_credit
    self.user.credit -= 1
    self.user.save
  end

  ## For calendar
  def start_time
    self.shift_date
  end

end
