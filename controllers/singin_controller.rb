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
