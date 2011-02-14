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
      {"error_code"=>"0","user"=>user}.to_json
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


get '/User/list' do
  user = User.get(1)
  user.friends.count
  
end




