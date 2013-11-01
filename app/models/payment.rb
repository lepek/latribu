class Payment < ActiveRecord::Base
  belongs_to :user

  after_create :add_credit

  after_destroy :remove_credit

  def add_credit
    self.user.credit += self.credit
    self.user.save
  end

  def remove_credit
    self.user.credit -= self.credit
    self.user.save
  end
end
