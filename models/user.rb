class User
  include DataMapper::Resource
  property :id,          Serial
  property :username,        String
  property :email,       String
  property :password,        String
  property :twitter_id,        String
  property :facebook_id,        String
  property :created_at,  DateTime
  property :started_drinking,  DateTime
  property :stoped_drinking,  DateTime
  property :drinking,       Boolean
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target
  has n, :userdrinks

  validates_presence_of :email
  validates_uniqueness_of :username,:if=>:username_used?,:message=>"103"
  validates_uniqueness_of :email, :if=>:email_used?,:message=>"104"
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message=>"108"

  def email_used?
    user=User.first(:email =>self.email)
    if user
     true
    else
      false
    end
  end

  def username_used?
    user=User.first(:username =>self.username)
    if user
     true
    else
      false
    end
  end


end