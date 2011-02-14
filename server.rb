require 'rubygems'
require 'dm-core'
require 'sinatra'
require "yaml"
require 'json'
require 'time'
require 'logger'
require 'dm-core'
require 'dm-validations'
require 'dm-sqlite-adapter'
require 'dm-migrations'
require 'dm-serializer'
require 'models/user'
require 'models/drink'
require 'models/userdrink'
require 'models/friendship'
### config ######
AppConfig=YAML::load File.new("config.yml").read
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/beer.db")
  DataMapper::Logger.new($stdout, :debug)

#  DataMapper.setup(:default, {
#    :adapter  => 'mysql',
#    :host     => 'localhost',
#    :username => 'root' ,
#    :password => '',
#    :database => 'sinatra_development'})

end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://beer.db')

#  DataMapper.setup(:default, {
#    :adapter  => 'mysql',
#    :host     => 'localhost',
#    :username => 'user' ,
#    :password => 'pass',
#    :database => 'sinatra_production'})

end

def requires_authorization!
  unless authorized?
    response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
    throw(:halt, [401, "Not authorized\n"])
  end
end

def authorized?
  @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  @auth.provided? && @auth.basic? && @auth.credentials == [ AppConfig['credentials']['user'], AppConfig['credentials']['password']]
end



load File.join(File.dirname(__FILE__), 'controllers', 'user_controller.rb')
load File.join(File.dirname(__FILE__), 'controllers', 'drink_controller.rb')
load File.join(File.dirname(__FILE__), 'controllers', 'signin_controller.rb')