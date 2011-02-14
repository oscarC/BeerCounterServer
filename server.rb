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


post '/User/signup' do
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


post '/Drink/new' do
  unless requires_authorization!
    if params['name']!=""&&params['description']!=""
      drink = Drink.new
      drink.name=params[:name]
      drink.description=params[:description]
      drink.picture_url=params[:picture_url]
      if drink.save
       {"response"=>{"status"=>"true","error_code"=>"0"}}.to_json
      else
        {"response"=>{"status"=>"true","error_code"=>"104"}}.to_json
      end
    else
      {"response"=>{"status"=>"true","error_code"=>"100"}}.to_json
    end
  end
end

##
post '/UserDrink/counter' do
  unless requires_authorization!
    user=User.get(params[:user_id])
    if user
      drink =Drink.get(params[:drink_id])
      if drink
        userdrink=Userdrink.first(:user=>user,:drink=>drink)
        userdrink.count=userdrink.count+1
        userdrink.save
        {"response"=>{"status"=>"true","error_code"=>"0"}}.to_json
      else
      ## Drink not found
      {"response"=>{"status"=>"false","error_code"=>"104"}}.to_json
      end
    else
     ## User not found
    {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
    end
  end
end


#########
post '/User/drinking' do
  unless requires_authorization!
    user=User.get(params[:user_id])
    if user
      drink =Drink.get(params[:drink_id])
      if drink
        userdrink=Userdrink.first(:user=>user,:drink=>drink)
        userdrink==params[:drinking]
        user.drinking=params[:drinking]
        user.stoped_at=Time.now if params[:drinking]=="false"
        user.started_at=Time.now if params[:drinking]=="true"
        user.save
        userdrink.save
        {"response"=>{"status"=>"true","error_code"=>"0"}}.to_json
      else
      ## Drink not found
      {"response"=>{"status"=>"false","error_code"=>"104"}}.to_json
      end
    else
     ## User not found
    {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
    end
  end
end


get '/GetUser' do
 unless requires_authorization!
    user=User.first(:email=>params[:username])||User.first(:nickname=>params[:username])
     if user
       user.to_json
     else
      ## User not found
      {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
     end
 end
end


post '/User/Follow' do
 unless requires_authorization!
  if params[:user_id]!=""&&params[:folower_id]!=""
    user=User.get(params[:user_id])
    if user
      follower=User.get(params[:folower_id])
      if follower
        user.friends<<follower
        user.save
        ## follower added
        {"response"=>{"status"=>"true","error_code"=>"0"}}.to_json
      else
        ## User not found
        {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
      end

    else
      ## User not found
      {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
    end
  else
    #params errors
    {"response"=>{"status"=>"false","error_code"=>"101"}}.to_json
  end
 end
end


get '/Drink/list' do
  unless requires_authorization!
  @drinks = Drink.all
  @drinks.to_json
  end
end


get '/welcome' do
  "Welcome"
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



