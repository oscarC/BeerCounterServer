class User
  include DataMapper::Resource
  property :id,          Serial
  property :nickname,        String
  property :email,       String
  property :password,        String
  property :twitter_id,        String
  property :facebook_id,        String
  property :created_at,  DateTime
  has n, :userdrinks, :through => Resource
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target

#
#  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
#  :message => "Email is invalid, please enter correct email.",
#  :allow_nil => true,
#  :if => :email

end


