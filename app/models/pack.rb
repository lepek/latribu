class Pack < ActiveRecord::Base
  has_many :pack_shifts, dependent: :delete_all
  has_many :shifts, through: :pack_shifts
end