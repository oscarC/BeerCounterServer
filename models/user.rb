class User
  include DataMapper::Resource
  property :id,          Serial
  property :nickname,        String
  property :email,       String
  property :password,        String
  property :twitter_id,        String
  property :facebook_id,        String
  property :created_at,  DateTime
<<<<<<< HEAD
  property :drinking,        Boolean, :required => true, :default => false
  has n, :userdrinks, :through => Resource
=======
  property :started_drinking,  DateTime
  property :stoped_drinking,  DateTime
  property :drinking,       Boolean
>>>>>>> 8b0c4badb5075f5f3747f1734c3e108daba14ce0
  has n, :friendships, :child_key => [:source_id]
  has n, :friends, self, :through => :friendships, :via => :target
  has n, :userdrinks

   validates_presence_of :email
   validates_presence_of :password
   validates_uniqueness_of :nickname,:if=>:nickname_used?
   validates_uniqueness_of :email, :if =>:email_used?
   validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def email_used?
    user=User.first(:email =>self.email)
    if user
     true
    else
      false
    end
  end

  def nickname_used?
    user=User.first(:nickname =>self.nickname)
    if user
     true
    else
      false
    end
  end


end