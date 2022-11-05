# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

students = [{:first_name => 'Kiana', :last_name => 'Erickson', :user_name => 'kberickson'},
          {:first_name => 'Joslin', :last_name => 'Some', :user_name => 'jsome'},
          {:first_name => 'Evan', :last_name => 'Brewer', :user_name => 'ebrewer'},
          {:first_name => 'Ben', :last_name => 'Desollar', :user_name => 'bdesollar'},
          {:first_name => 'Adnane', :last_name => 'Ezouhri', :user_name => 'aezouhri'},
          {:first_name => 'Christian', :last_name => 'Baseme', :user_name => 'cbaseme'},
  	 ]
profiles = [{:student_id=>1,:gre=> 33, :toefl => 109, :interested_major => "Mechanical Engineering", :term => "spring", :year =>"2022" } ,
            {:student_id=>4,:gre=> 23, :toefl => 10, :interested_major => "Electrical Engineering", :term => "spring", :year =>"2022" },
            {:student_id=>1,:gre=> 33, :toefl => 109, :interested_major => "Computer Engineering", :term => "spring", :year =>"2022" },
            ]
students.each do |student|
  Student.create!(student)
end

profiles.each do |profile|
  Profile.create!(profile)
end
