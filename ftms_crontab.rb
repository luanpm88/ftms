require 'active_record'
require 'yaml'
DIR = File.expand_path(File.dirname(__FILE__))
environment = "production"

# Change the following to reflect your database settings
# config = YAML.load_file(DIR+'/config/database.yml')["production"]
config = YAML.load_file(DIR+'/config/database.yml')[environment]

puts DIR+'/config/database.yml'

ActiveRecord::Base.establish_connection(
  adapter: config["adapter"],
  encoding: config["encoding"],
  database: config["database"],
  pool: 5,
  username: config["username"],
  password: config["password"]
)

#Item class
require DIR+'/app/models/system.rb'
require DIR+'/app/models/setting.rb'

System.backup({database: true, file: true, dir: DIR+"/", environment: environment})