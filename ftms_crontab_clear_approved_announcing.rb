require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))
# Change the following to reflect your database settings
# config = YAML.load_file(DIR+'/config/database.yml')["production"]
config = YAML.load_file(DIR+'/config/database.yml')["production"]

@connection = ActiveRecord::Base.establish_connection(
  adapter: config["adapter"],
  encoding: config["encoding"],
  database: config["database"],
  pool: 5,
  username: config["username"],
  password: config["password"]
)

sql = "UPDATE contacts SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved contact announcing is cleared!"

sql = "UPDATE courses SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved course announcing is cleared!"

sql = "UPDATE course_types SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved course_type announcing is cleared!"

sql = "UPDATE subjects SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved subject announcing is cleared!"

sql = "UPDATE phrases SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved phrase announcing is cleared!"

sql = "UPDATE course_registers SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved course register announcing is cleared!"

sql = "UPDATE transfers SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved transfer announcing is cleared!"

sql = "UPDATE books SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved book announcing is cleared!"

sql = "UPDATE books SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved book announcing is cleared!"

sql = "UPDATE stock_types SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved stock_type announcing is cleared!"

sql = "UPDATE discount_programs SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved discount program announcing is cleared!"

sql = "UPDATE bank_accounts SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved bank account program announcing is cleared!"

sql = "UPDATE seminars SET annoucing_user_ids=null"
@result = @connection.connection.execute(sql);
puts "approved seminar program announcing is cleared!"









