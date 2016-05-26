class Pack < ActiveRecord::Base
  has_many :pack_shifts
  has_many :shifts, through: :pack_shifts
end