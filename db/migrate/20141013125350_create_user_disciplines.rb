class CreateUserDisciplines < ActiveRecord::Migration
  def change
    create_table :user_disciplines do |t|
      t.references :user, index: true
      t.references :discipline, index: true
    end
  end
end
