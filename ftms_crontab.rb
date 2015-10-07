require 'active_record'
DIR = File.expand_path(File.dirname(__FILE__))

#Item class
require DIR+'/app/models/system.rb'

System.backup({database: true, file: true, environment: "development"})








