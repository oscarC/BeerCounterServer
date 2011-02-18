post '/User/authenticate' do
  unless requires_authorization!
    if params['password'] != nil
      user = User.first(:email =>params['username'],:password =>params['password']) ||
             User.first(:username =>params['username'],:password =>params['password'])         
      if user
        {"error_code"=>"0","user"=>user}.to_json
      else
        ## User not found
        {"error_code"=>"102"}.to_json
      end
    else 
      if params['facebook_id'] != nil
        user = User.first(:facebook_id =>params['facebook_id'])
        if user
          {"error_code"=>"0","user"=>user}.to_json
        else
          ## User with facebook id doesn't exist
          {"error_code"=>"105"}.to_json
        end
      else
        if params['twitter_id'] != nil
          user = User.first(:twitter_id =>params['twitter_id'])
          if user
            {"error_code"=>"0","user"=>user}.to_json
          else
            ## User with twitter id doesn't exist
            {"error_code"=>"101"}.to_json
          end
        else
          ## User not found
          {"error_code"=>"110"}.to_json
        end  
      end
    end
  end
end

post '/User/signup' do
  unless requires_authorization!
    user = User.new
    user.username = params['username']
    user.email = params['email']
    user.password = params['password']
    user.facebook_id = params['facebook_id']
    user.twitter_id = params['twitter_id']
    if user.save
      {"error_code"=>"0","user"=>user}.to_json
    else
      ## User couldn't be registered
      {"error_code"=>"100","reasons"=>user.errors}.to_json
    end
  end
end

post '/User/drinking' do
  unless requires_authorization!
    user = User.first(:id=>params['user_id'])
    if user
      user.drinking = (params['drinking'] == "true" ? true : false)
      if user.save
        {"error_code"=>"0"}.to_json
      else
        ## User couldn't be updated
        {"error_code"=>"106"}.to_json
      end
    else
      ## User not found
      {"error_code"=>"102"}.to_json
    end
  end
end

##

post '/UserDrink/counter' do
  unless requires_authorization!
    user=User.get(params[:user_id])
    if user
      drink = Drink.get(params[:drink_id])
      if drink
        userdrink=Userdrink.first(:user=>user,:drink=>drink)
        userdrink.count=userdrink.count+1
        userdrink.save
        {"response"=>{"status"=>"true","error_code"=>"0"}}.to_json
      else
      ## Drink not found
      {"response"=>{"status"=>"false","error_code"=>"201"}}.to_json
      end
    else
     ## User not found
    {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
    end
  end
end

#########

post '/User/Follow' do
  unless requires_authorization!
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
        {"response"=>{"status"=>"false","error_code"=>"107"}}.to_json
      end
    else
      ## User not found
      {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
    end
  end
end

get '/GetUser' do
 unless requires_authorization!
    user=User.first(:email=>params[:username])||User.first(:username=>params[:username])
     if user
       user.to_json
     else
      ## User not found
      {"response"=>{"status"=>"false","error_code"=>"102"}}.to_json
     end
 end
end

get '/Friends/feeds' do
  unless requires_authorization!
    user = User.get(params[:user_id])
    if user
      friendsfeeds = []
      user.friends.each do |friend|
        userdrinks=Userdrink.all(:user=>friend)
        if userdrinks.size > 0
          userdrinks.each do |userdrink|
            friendsfeeds.push({:drink_name=>Drink.get(userdrink.drink_id).name,:location=>userdrink.location,:count=>userdrink.count,:username=>User.get(userdrink.id).username})
          end
        end
      end
      if friendsfeeds.size > 0
        friendsfeeds.to_json
      else
        {}.to_json
      end
    else
      {}.to_json
    end
  end
end




