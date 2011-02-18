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


get '/PopulateDB' do
  DataMapper.auto_migrate!
	user = User.create(:drinking=>true,:username => 'oscart',:email=>'oscart@k.com',:password=>'123',:facebook_id=>'100002095840607',
	        :friends => [{:username=>'mayo',:email=>'mayo@k.com',:password=>'123'},
	                     {:username=>'maira',:email=>'maira@k.com',:password=>'123'}])
	user.save
  drink = Drink.create(:name => 'Aguila')
  drink.save
  drink = Drink.create(:name => 'Aguila Light')
  drink.save
  drink = Drink.create(:name => 'Poker')
  drink.save
  Userdrink.create(:location=>"Mundo Cerveza",:count=>"5",:started_at=>Time.now,:drinking=>true,:user=>user,:drink=>Drink.get(1))
  Userdrink.create(:location=>"Sede Juniorista",:count=>"15",:started_at=>Time.now,:drinking=>true,:user=>User.get(2),:drink=>Drink.get(2))
  Userdrink.create(:location=>"La Troja",:count=>"5",:started_at=>Time.now,:drinking=>true,:user=>User.get(2),:drink=>Drink.get(3))



  "Done"	
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
