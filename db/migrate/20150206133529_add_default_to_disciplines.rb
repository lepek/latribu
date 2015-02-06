class AddDefaultToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :default, :boolean
  end
end
