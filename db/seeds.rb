# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ContactType.create(name: "Student")
ContactType.create(name: "Lecturer")
ContactType.create(name: "Inquiry")

User.create(:email => "admin@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Super",:last_name => "Admin")
User.create(:email => "manager@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "System",:last_name => "Manager")

Role.create(name: "admin")
Role.create(name: "user")
Role.create(name: "manager")

# Default role for user
User.all.each do |user|
    user.add_role Role.where(name: "user").first if !user.has_role?("admin")
end

# Default Role for Admin
user = User.where(:email => "admin@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "admin").first

user = User.where(:email => "manager@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "manager").first

ContactTag.create(name: "No Tag", description: "No Tag")
ContactTag.create(name: "Follow Up", description: "Likely to study")
ContactTag.create(name: "Potential", description: "Not sure whether to study")
ContactTag.create(name: "No More Follow Up", description: "Not want to study any more")
