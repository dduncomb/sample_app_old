# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Micropost < ActiveRecord::Base
  attr_accessible :content    # only content (and not user_id) attribute needs to be editable thru the web

  belongs_to :user

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'microposts.created_at DESC' # get ordering test in user_spec.rb to pass

  # i suspect this method is so-named because it is a class method and can be read as
  # "microposts from users followed by <given_user>"


  # this first implementation works, note the following:

  # - uses the special ruby idiom (&:id) as argument to the map method to prevent need for passing block
  # - the id accessor is called on each following User object, and mapped to a single array which
  #   is then transformed to a string consisting of array elements separated by a comma
  # - this value is then fed into the where ActiveRecord method.  Somewhat confusingly, the (optional)
  #   Micropost prefix that would tell us this is actually a class method of Micropost is omitted

=begin

  def self.from_users_followed_by(user)
    followed_ids = user.following.map(&:id).join(", ")
    where("user_id IN (#{followed_ids}) OR user_id = ?", user)
  end

=end

  # the first implementation however does not scale.

  # The concept of a scope in Rails restricts database selects based on certain conditions.
  # Here we take advantage of this using a closure - a function bundled with a piece of data
  # (a user, in this case):

  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

    # This is an auxiliary method for the above closure
    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.

    # note 1: the first line from the initial implementation above inserts a string into the
    # ActiveRecord where method - this is now replaced by a subquery for efficiency!
    # The equivalent SQL statement (tail the log file if you must) for user 1 would
    # look something like this:

=begin

    SELECT * FROM microposts
    WHERE user_id IN (SELECT followed_id FROM relationships
                      WHERE follower_id = 1)
          OR user_id = 1

=end

    # note 2: the %() notation facilitates multiline string interpolation

    # note 3: the ActiveRecord where method here replaces the "?" with an equivalent syntax
    # which is more convenient when the same variable is inserted in more than one place
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships
                       WHERE follower_id = :user_id)
      where("user_id IN(#{followed_ids}) OR user_id = :user_id",
            { :user_id => user })
    end

end



