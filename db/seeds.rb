# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ContactType.create(name: "Student", display_order: 1)
ContactType.create(name: "Inquiry", display_order: 2)
ContactType.create(name: "Lecturer", display_order: 3)

User.create(name: "Super Admin", :email => "admin@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "Super",:last_name => "Admin")
User.create(name: "Manager", :email => "manager@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "System",:last_name => "Manager")
User.create(name: "Education Consultant", :email => "education_consultant@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "",:last_name => "")
User.create(name: "Sales Admin", :email => "sales_admin@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "",:last_name => "")

Role.create(name: "admin")
Role.create(name: "user")
Role.create(name: "manager")
Role.create(name: "sales_admin")
Role.create(name: "education_consultant")
Role.create(name: "accountant")


# Default role for user
User.all.each do |user|
    user.add_role Role.where(name: "user").first if !user.has_role?("admin")
end

# Default Role for Admin
user = User.where(:email => "admin@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "admin").first

user = User.where(:email => "manager@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "manager").first

user = User.where(:email => "education_consultant@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "education_consultant").first

user = User.where(:email => "sales_admin@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "sales_admin").first

ct = ContactTag.create(name: "No Tag", description: "No Tag", status: "[active]")
ct.save_draft(User.first)
ct = ContactTag.create(name: "Follow Up", description: "Likely to study", status: "[active]")
ct.save_draft(User.first)
ct = ContactTag.create(name: "Potential", description: "Not sure whether to study", status: "[active]")
ct.save_draft(User.first)
ct = ContactTag.create(name: "No More Follow Up", description: "Not want to study any more", status: "[active]")
ct.save_draft(User.first)

Setting.create(name: "currency_code", value: "VNĐ")
