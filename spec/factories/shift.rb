FactoryGirl.define do
  factory :shift do
    week_day 2
    start_time "12:00"
    end_time "13:00"
    max_attendants "12"
    open_inscription "24"
    close_inscription "0"
    cancel_inscription "2"
    instructor { Instructor.find_by_last_name('Adell') }
    discipline { Discipline.find_by_name('Unconventional Training') }
  end
end