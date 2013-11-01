class AddRefsToInscription < ActiveRecord::Migration
  def change
    add_reference :inscriptions, :user, index: true
    add_reference :inscriptions, :shift, index: true
  end
end
