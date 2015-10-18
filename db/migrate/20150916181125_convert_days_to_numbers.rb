class ConvertDaysToNumbers < ActiveRecord::Migration
  DAYS = {
    sunday: 1,
    monday: 2,
    tuesday: 3,
    wednesday: 4,
    thursday: 5,
    friday: 6,
    saturday: 7
  }

  def up
    DAYS.each do |key, value|
      Shift.with_deleted.where(day: key).update_all(day: value)
    end

    change_column :shifts, :day, :integer
    rename_column :shifts, :day, :week_day
  end

  def down
    DAYS.each do |key, value|
      Shift.where(week_day: value).update_all(day: key)
    end

    change_column :shifts, :week_day, :string
    rename_column :shifts, :week_day, :day
  end
end
