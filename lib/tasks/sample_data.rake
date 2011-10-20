require 'faker'

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  admin = User.create!(:name => "Example User",
                       :email => "example@railstutorial.org",
                       :password => "foobar",
                       :password_confirmation => "foobar")

  # the user model purposely does not include admin in attr_accessible
  # otherwise a user may send a PUT request e.g. put /users/17?admin=1
  # For that reason we cannot pass it thru as an argument in call to create! above
  admin.toggle!(:admin)

  99.times do |n|
    name = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    User.create!(:name => name,
                 :email => email,
                 :password => password,
                 :password_confirmation => password)
  end

  def make_microposts
    User.all(:limit => 6).each do |user|
      50.times do
        user.microposts.create!(:content => Faker::Lorem.sentence(5))
      end
    end
  end

  def make_relationships

    # arrange for first user to follow the next 50 users, then have users with
    # ids 4 thru 41 follow that user back
    users = User.all
    user = users.first
    following = users[1..50]
    followers = users[3..40]
    following.each { |followed| user.follow!(followed) }
    followers.each { |follower| follower.follow!(user)}
  end

end


