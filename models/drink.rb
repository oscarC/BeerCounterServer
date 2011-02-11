class Drink
  include DataMapper::Resource
  property :id,          Serial
  property :name,        String
  property :description,        String
  property :picture_url,        String
#  has n, :userdrinks, :through => Resource
end


