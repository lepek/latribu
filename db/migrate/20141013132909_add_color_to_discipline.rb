class AddColorToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :color, :string
  end
end
