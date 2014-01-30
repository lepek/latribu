class Rooky < ActiveRecord::Base
  belongs_to :shift

  validates_presence_of :full_name

  def self.pending
    self.where('shift_date >= ? ', Chronic.parse('one hour ago'))
  end
end
