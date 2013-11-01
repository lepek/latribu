class AddInstructorRefToUsers < ActiveRecord::Migration
  def change
    add_reference :shifts, :instructor, index: true
  end
end
