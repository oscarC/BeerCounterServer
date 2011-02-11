class Userdrink
  include DataMapper::Resource
  property :id,          Serial
  property :location,        String
  property :location_name,        String
  property :count,        Integer
  property :date,        DateTime
  property :status,        Boolean, :required => true, :default => false
  belongs_to :user
  belongs_to :drink
end