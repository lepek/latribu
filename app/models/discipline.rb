class Discipline < ActiveRecord::Base
  has_many :shifts

  has_many :user_disciplines
  has_many :users, through: :user_disciplines
end
