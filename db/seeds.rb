# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.create(:name => 'Admin') unless Role.where(:name => 'Admin').count > 0
Role.create(:name => 'Cliente') unless Role.where(:name => 'Client').count > 0

User.create(
    :first_name => 'Federico',
    :last_name => 'Adell',
    :phone => '123234345',
    :email => 'fedex6_@hotmail.com',
    :password => 'federico',
    :password_confirmation => 'federico',
    :role_id => 1
) unless User.where(:email => 'fedex6_@hotmail.com').count > 0

Instructor.create(
    :first_name => 'Federico',
    :last_name => 'Adell'
) unless Instructor.where(:first_name => 'Federico', :last_name => 'Adell').count > 0

Instructor.create(
    :first_name => 'Andres',
    :last_name => 'Torrens'
) unless Instructor.where(:first_name => 'Andres', :last_name => 'Torrens').count > 0

Instructor.create(
    :first_name => 'Pablo',
    :last_name => 'Fabucci'
) unless Instructor.where(:first_name => 'Pablo', :last_name => 'Fabucci').count > 0

Instructor.create(
    :first_name => 'Magdalena',
    :last_name => 'del Pazo'
) unless Instructor.where(:first_name => 'Mani', :last_name => 'del Pazo').count > 0

Instructor.create(
    :first_name => 'Antonela',
    :last_name => 'Tosti'
) unless Instructor.where(:first_name => 'Antonela', :last_name => 'Tosti').count > 0

Instructor.create(
    first_name: "German",
    last_name: "Verdolini"
) unless Instructor.where(first_name: "German", last_name: "Verdolini").count > 0

Instructor.create(
    first_name: "Zoraida",
    last_name: "Gordillo"
) unless Instructor.where(first_name: "Zoraida", last_name: "Gordillo").count > 0

unconventional = Discipline.find_or_create_by(:name => 'Unconventional Training')
unconventional.update_attributes(:default => true)

Discipline.find_or_create_by(:name => 'Advanced Level')

strength = Discipline.find_by_name('Strenght Training')
strength.update_attributes(:name => 'Strength Training') if strength
strength = Discipline.find_or_create_by(:name => 'Strength Training')
strength.update_attributes(:default => true)

mobility = Discipline.find_or_create_by(:name => 'Mobility')
mobility.update_attributes(:default => true)

oly = Discipline.find_or_create_by(:name => 'Oly')


User.find_each do |user|
  user.disciplines << unconventional unless user.disciplines.include?(unconventional)
  user.disciplines << strength unless user.disciplines.include?(strength)
  user.disciplines << mobility unless user.disciplines.include?(mobility)
  user.disciplines << oly unless user.disciplines.include?(oly)

end
