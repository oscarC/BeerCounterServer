get '/Drink/list' do
  unless requires_authorization!
  @drinks = Drink.all
  @drinks.to_json
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
        {"response"=>{"status"=>"true","error_code"=>"200"}}.to_json
      end
    else
      {"response"=>{"status"=>"true","error_code"=>"1"}}.to_json
    end
  end
end