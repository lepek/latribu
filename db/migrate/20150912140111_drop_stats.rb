class DropStats < ActiveRecord::Migration
  def change
    drop_table :stats
  end
end
