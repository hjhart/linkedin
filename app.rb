require 'active_record'
require 'sqlite3'
require 'logger'
require 'pry'
require "selenium-webdriver"
require 'csv'
require 'cgi'
require 'awesome_print'

ActiveRecord::Base.logger = Logger.new('log/debug.log')
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])

class User < ActiveRecord::Base
end