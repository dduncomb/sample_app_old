# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#
class User < ActiveRecord::Base
	attr_accessor :password   # virtual attribute - no corresponding table column in db
	attr_accessible :name, :email, :password, :password_confirmation # name, email have columns in db
                        # password is a virtual attribute explicitly created (above)
                        # password_confirmation is a virtual attribute implicitly created
                        # with validates :password :confirmation => true call

                        # these four values are used to instantiate class in spec tests

                        # note that encrypted_password is introduced as a db column with the migration
                        # add_password_to_users.rb, however we do not want it updated directly
                        # and thus it is not supplied as parameter to attr_accessible

  has_many :microposts, :dependent => :destroy          # destroy microposts when user is destroyed
  has_many :relationships, :foreign_key => "follower_id",  # foreign key needs to be explicit
                                                          # when convention <class_id> not used
                                                          # (e.g. user_id in microposts table)
                           :dependent => :destroy         # destroy rships when user is destroyed

  # here the has_many association does not actually refer to a model!
  # in this case, we specify the association to be through another model (relationships)instead.

  # instead of convention has_many :followeds, we change to the more natural has_many :following
  # but pay the price with the additional :source specification

  # also with this addition, the user model now responds to method :following
  has_many :following, :through => :relationships, :source => :followed


  # now we exploit the underlying assymetry between followers and following to simulate a
  # reverse_relationships table by passing followed_id as the foreign key and also
  # by explicitly referring to class name Relationship (otherwise rails looks for a
  # ReverseRelationship class - which doesn't exist)

  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy

  # note that here, source is optional as rails will automatically look for foreign key
  # follower_id in this case
  has_many :followers, :through => :reverse_relationships, :source => :follower


	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	
	validates :name, :presence => true,
									 :length  => { :maximum => 50 }
	validates :email, :presence => true,
										:format  => { :with => email_regex },
										:uniqueness => { :case_sensitive => false }
	
	# Automatically create the virtual attribute 'password_confirmation'
	validates :password, :presence		 => true,
											 :confirmation => true,   #
											 :length			 => { :within => 6..40 }

  # register callback
	before_save :encrypt_password
	
	# Return true if the user's password matches the submitted password
	def has_password?(submitted_password)
		# Compare encrypted_password in db with the encrypted version of
		# submitted_password (recall, encrypted_password, like salt, can be accessed directly from db like this)
		encrypted_password == encrypt(submitted_password)
	end

  def feed
    # This is preliminary.  See Chapter 12 for the full implementation

    #  self.microposts will not generalize here - so use alternative syntax
    #  to make a Micropost find...the where method makes an SQL call to the database
    # for the micropost active record with the given parameter
    #
    # the question mark here ensures that id is properly escaped before inclusion in
    # underlying SQL query to prevent SQL injection attack (even though an integer in this case)
    Micropost.where("user_id = ?", id)
  end

	def self.authenticate(email, submitted_password)
		user = find_by_email(email)
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
  end

  # the following method is called in sessions_helper.rb
  # After a user signs in (with method sign_in in SessionsHelper), the setter method
  # current_user() sets the current user.  Subsequent calls to getter method current_user
  # (the first time) will call user_from_remember_token() method, which in turn calls
  # User.authenticate_with_salt(*remember_token) passing the user id and salt read from the cookie.

  # The values passed from the cookie, id and salt, are used here in this method to find the user
  # then returns the user iff the salt stored in the cookie is correct for that user
  # ie it reads "user exists" AND "user.salt == cookie_salt"

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil   # compare this ternary operator with authenticate method
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)   # followed_id is in attr_accessible and
                                                        # was created when the relationship model
                                                        # was generated
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end


	private
		
		def encrypt_password
      # in this context, self required for salt and encrypted_password
      # - otherwise local variable created; however password parameter to encrypt()
      # does not require self (it is optional) as this refers to more global (virtual) attribute
			self.salt = make_salt if new_record?        # salt column in db updated here if new activerecord
			self.encrypted_password = encrypt(password) # encrypted_password column in db updated here

		end
		
		def encrypt(string)
			secure_hash("#{salt}--#{string}")     # no self.salt required - global (db) attribute used
		end
	
		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")			
		end
		
		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
		
end


