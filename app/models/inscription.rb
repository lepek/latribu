class Inscription < ActiveRecord::Base

  belongs_to :shift, -> { unscope(where: :deleted_at) }
  belongs_to :user

  after_destroy :add_credit
  after_create :remove_credit

  validates_uniqueness_of :user_id, :scope => [:shift_date]

  private

  ##
  # Refund the credit when an inscriptions is deleted
  #
  def add_credit
    get_oldest_payment_with_credit_to_return.decrement!(:used_credit)
    self.user.increment!(:credit)
  end

  ##
  # One inscription cost one credit and we account it here
  #
  def remove_credit
    get_oldest_payment_with_credit_to_use.increment!(:used_credit)
    self.user.decrement!(:credit)
  end

  ##
  # Get the oldest payment not reset with credit to use
  #
  def get_oldest_payment_with_credit_to_use
    self.user.payments.where('reset_date IS NULL AND credit > 0 AND used_credit < credit').order('month_year ASC, created_at ASC').first
  end

  ##
  # Get the older payment not reset, with credit used to give a credit back
  # If all the payments are reset, get the newest reset one with used credit
  #
  def get_oldest_payment_with_credit_to_return
    self.user.payments.where('reset_date IS NULL AND credit > 0 AND used_credit > 0 AND used_credit < credit').order('month_year ASC, created_at ASC').first ||
      self.user.payments.where('reset_date IS NULL AND credit > 0 AND used_credit > 0 AND used_credit <= credit').order('month_year ASC, created_at ASC').first ||
      self.user.payments.where('credit > 0 AND used_credit > 0 AND used_credit <= credit').order('month_year ASC, created_at ASC').first
  end

end
