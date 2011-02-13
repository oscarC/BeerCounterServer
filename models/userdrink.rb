class Userdrink
  include DataMapper::Resource
  property :id,     Serial
  property :location,       String
  property :count,       Integer
  property :status,       Boolean
  property :created_at,  DateTime
  property :stoped_at,  DateTime
  belongs_to :user
  belongs_to :drink
end