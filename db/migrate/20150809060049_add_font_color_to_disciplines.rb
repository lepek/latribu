class AddFontColorToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :font_color, :string
  end
end
