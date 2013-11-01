class AddDisciplineRefToShifts < ActiveRecord::Migration
  def change
    add_reference :shifts, :discipline, index: true
  end
end
