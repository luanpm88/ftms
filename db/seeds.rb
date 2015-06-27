# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ContactType.create(name: "Student")
ContactType.create(name: "Agent")

User.create(:email => "admin@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Super",:last_name => "Admin")

Role.create(name: "admin")
Role.create(name: "user")

# Default role for user
User.all.each do |user|
    user.add_role Role.where(name: "user").first
end

# Default Role for Admin
admin = User.where(:email => "admin@ftmsglobal.edu.vn").first
admin.add_role Role.where(name: "admin").first
