class UserDiscipline < ActiveRecord::Base
  belongs_to :user
  belongs_to :discipline
end