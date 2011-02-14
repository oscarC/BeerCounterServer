require 'server'
DataMapper.auto_migrate!
run Sinatra::Application