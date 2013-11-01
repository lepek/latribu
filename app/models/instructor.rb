class Instructor < ActiveRecord::Base
  has_many :shifts

  def full_name
    "#{first_name} #{last_name}"
  end
end
