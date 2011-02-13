class Userdrink
  include DataMapper::Resource
  property :id,     Serial
  property :location,       String
  property :count,       Integer
  belongs_to :user
  belongs_to :drink
end