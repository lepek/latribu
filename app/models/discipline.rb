class Discipline < ActiveRecord::Base
  has_many :shifts

  has_many :user_disciplines
  has_many :users, through: :user_disciplines

  validates_presence_of :name
  validates_presence_of :color
  validates_presence_of :font_color

  before_validation :set_default_colors

  private

  def set_default_colors
    self.color = '#fafafa' if self.color.blank?
    self.font_color = '#000105' if self.font_color.blank?
  end

end
