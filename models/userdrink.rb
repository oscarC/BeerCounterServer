class Userdrink
  include DataMapper::Resource
  property :id,     Serial
  property :location,       String
  property :location_id,       Integer
  property :count,       Integer
  property :started_at,  DateTime
  property :drinking,       Boolean
  belongs_to :drink
  belongs_to :user

end