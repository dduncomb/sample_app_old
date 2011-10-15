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

  has_many :microposts, :dependent => :destroy

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

	def feed
    # This is preliminary.  See Chapter 12 for the full implementation
    # the question mark here ensures that id is properly escaped before inclusion in
    # underlying SQL query to prevent SQL injection attack (even though an integer in this case)
    Micropost.where("user_id = ?", id)
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


