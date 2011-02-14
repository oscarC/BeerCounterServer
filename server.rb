require 'rubygems'
require 'dm-core'
require 'sinatra'
require "yaml"
require 'json'
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

get '/Welcome' do
	"Welcome"
end

get '/PopulateDB' do
  DataMapper.auto_migrate!
	user = User.create(:nickname => 'oscart',:email=>'oscart@k.com',:password=>'123',
	        :friends => [{:nickname=>'mayo',:email=>'mayo@k.com',:password=>'123'},
	                     {:nickname=>'maira',:email=>'maira@k.com',:password=>'123'}])
	user.save
  drink = Drink.create(:name => 'Aguila')
  drink.save
  drink = Drink.create(:name => 'Aguila Light')
  drink.save
  drink = Drink.create(:name => 'Poker')
  drink.save
  "Done"	
end

post '/login' do
  unless requires_authorization!
    if params['token']!="" && params['type_connection']!=""&&params['user_id']!=""
       user=User.get(params['user_id'])
      if user
        user.twitter_id=params['token']if params['type_connection']=="twitter"
        user.facebook_id=params['token']if params['type_connection']=="twitter"
       else
        "false"
      end
    else
      "false"
    end
  end
end

post '/User/authenticate' do
  unless requires_authorization!
    user = User.first(:email =>params['email'],:password =>params['password'])
    if user
      {"error_code"=>"0","user"=>user.to_json}.to_json
    else
      {"error_code"=>"104"}.to_json
    end
  end
end

post '/User/signup' do
  unless requires_authorization!
    user = User.new
    user.nickname = params['nickname']
    user.email = params['email']
    user.password = params['password']
    if user.save
      {"error_code"=>"0"}.to_json
    else
      {"error_code"=>"100"}.to_json
    end
  end
end

post '/User/drinking' do
  unless requires_authorization!
    if params['user_id'] != ""
      user = User.get(params['user_id'])
      if user
        user.drinking = params['drinking']
        if user.save
          {"error_code"=>"0"}.to_json
        else
          {"error_code"=>"130"}.to_json
        end
      else
        {"error_code"=>"131"}.to_json
      end
    end
  end
end

post '/Drink/new' do
  unless requires_authorization!
    if params['name']!=""&&params['description']!=""
      drink = Drink.new
      drink.name=params['name']
      drink.description=params['description']
      if drink.save
        "true"
      else
        "false"
      end
    else
      "false"
    end
  end
end

###########################################

get '/UserDrink/new' do
  unless requires_authorization!
    user  = User.new
    drink = Drink.new
    drink.name = "Aguila 1"
    drink.description = "Example"
    user.nickname = "Junior"
    user.drinks << drink
    if user.save
      "true"
    else
      "402"
    end
  end
end



get '/User/list' do
  @users = User.all
  @users.first.nickname
end


get '/Drink/list' do
  @drinks = Drink.all
  @drinks.to_json
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



