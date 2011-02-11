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



post '/Authenticate' do
  unless requires_authorization!
    if params['email']!="" && params['password']!=""
      user=User.first(:email =>params['email'],:password =>params['password'])
      if user
        user.to_json
      else
        {}.to_json
      end
    else
      {}.to_json
    end
  end
end


post '/Signup' do
  unless requires_authorization!
    user = User.new
    user.nickname=params['nickname']
    user.email=params['email']
    user.password=params['password']
    if user.save
    {"registration"=>{"status"=>"true","error_code"=>"0"}}.to_json
    else
     {"registration"=>{"status"=>"false","error_code"=>"100"}}.to_json
    end
  end
end

# get an user friends
get '/Friends/:id.json' do
 unless requires_authorization!
  if params[:id]!=""
    user=User.get(params[:id])
    if user
      user.to_json
    else
      {}.json
    end
  else
   {}.json
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
    drink.name="Aguila 1"
    drink.description="Example"
    user.nickname="Junior"
    user.drinks<<drink
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
  @drinks.first.name
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



