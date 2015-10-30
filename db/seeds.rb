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
User.create(name: "Accountant", :email => "accountant@ftmsglobal.edu.vn", :password => "aA456321@", :password_confirmation => "aA456321@",:first_name => "",:last_name => "")

Role.create(name: "admin")
Role.create(name: "user")
Role.create(name: "manager")
Role.create(name: "sales_admin")
Role.create(name: "education_consultant")
Role.create(name: "accountant")
Role.create(name: "storage_manager")


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

user = User.where(:email => "accountant@ftmsglobal.edu.vn").first
user.add_role Role.where(name: "accountant").first

# All settings
Setting.create(name: "currency_code", value: "VNĐ")
# Setting.create(name: "backup_database", value: "ftms_production")
Setting.create(name: "backup_dir", value: "/media/sdb1/ftms-backup")
# Setting.create(name: "backup_cron_time", value: "* */12 * * *")
Setting.create(name: "backup_revision_count", value: "100")
Setting.create(name: "dropbox_backup_revision_count", value: "10")



Autotask.create(name: "book_out_of_date", time_interval: 43200)