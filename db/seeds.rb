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

USERS = [
    {first_name: 'martin', last_name: 'bianculli'},
    {first_name: 'ines del carmen', last_name: 'la torre'},
    {first_name: 'fernando', last_name: 'vicini'},
    {first_name: 'nicolas', last_name: 'amorelli'},
    {first_name: 'guillermo', last_name: 'davoli'},
    {first_name: 'georgina', last_name: 'neyra'},
    {first_name: 'iván', last_name: 'trevisán'},
    {first_name: 'elisabet', last_name: 'trevisan'}
]

USERS.each do |user_data|
  users = User.where(user_data)
  if users.count > 1
    puts "Duplicates user #{user_data}"
  elsif users.count == 1
    users.first.update_attributes({:reset_credit => false})
  end
end

unconventional_training = Discipline.find_or_create_by(:name => 'Unconventional Training')
Discipline.find_or_create_by(:name => 'Advanced Training') unless Discipline.where(:name => 'Advanced Training').count > 0
Discipline.find_or_create_by(:name => 'Fuerza') unless Discipline.where(:name => 'Fuerza').count > 0

User.find_each do |user|
  user.disciplines << unconventional_training if user.disciplines.empty?
end
