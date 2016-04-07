class Message < ActiveRecord::Base
  validates_presence_of :message, :start_date, :end_date
end
