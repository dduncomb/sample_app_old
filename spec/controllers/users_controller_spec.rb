require 'spec_helper'

describe UsersController do
	render_views

	describe "GET 'show'" do
		
		before(:each) do
			@user = Factory(:user)  # factory girl gem used here to populate @user; see spec/factories.rb
		end
		
		it "should be successful" do
			get :show, :id => @user       # get show action with id = @user.id (rails idiom shortcut here)
                                    # recall that id attribute automatically exists in db schema
                                    # and that the Factory method creates a user according to factories.rb
                                    # and returns the user object with its automatically allocated id
			response.should be_success
		end
		
		it "should find the right user" do
			get :show, :id => @user
			assigns(:user).should == @user      # assigns method takes symbol and returns corresponding
                                          # instance variable in controller action - here, the
                                          # @user variable in the show action of the Users controller.

                                          # Basically, we're saying show the factory user object,
                                          # then compare the @user object in the show action of the
                                          # users controller with this factory user object
		end
		
		it "should have the right title" do
			get :show, :id => @user             # ...and again, the @user.id idiom here, and in the following...
			response.should have_selector("title", :content => @user.name)
		end
		
		it "should include the user's name" do      # check h1 tag for user's name
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.name)
		end
		
		it "should have a profile image" do       # check nested img tag for class gravatar
			get :show, :id => @user
			response.should have_selector("h1>img", :class => "gravatar")
		end

    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content) # span tag with CSS class "content"
      response.should have_selector("span.content", :content => mp2.content)
    end

    it "should paginate microposts" do
      35.times { Factory(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector('div.pagination')
    end

    it "should display the micropost count" do
      10.times { Factory(:micropost, :user => @user, :content => "foo") }
      get :show, :id => @user
      response.should have_selector("td.sidebar",
                                    :content => @user.microposts.count.to_s)
    end

    describe "when signed in as another user" do
      it "should be successful" do
        test_sign_in(Factory(:user, :email => Factory.next(:email)))
        get :show, :id => @user
        response.should be_success
      end
    end

	end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end    
  end

	describe "POST 'create'" do
		
		describe "failure" do
		
			before(:each) do
				@attr = { :name => "", :email => "", :password => "",
								:password_confirmation => "" }
			end
			
			it "should not create a user" do
				lambda do
					post :create, :user => @attr         # hit the create action with an HTTP post request
				end.should_not change(User, :count)    # change method returns no. of users in db
			end
			
			it "should have the right title" do
				post :create, :user => @attr
				response.should have_selector("title", :content => "Sign up")
			end
			
			it "should render the 'new' page" do
				post :create, :user => @attr
				response.should render_template('new')
			end		
		end
		
		describe "success" do
			before(:each) do
				@attr = { :name => "New User", :email => "user@example.com",
								:password => "foobar", :password_confirmation => "foobar" }								
			end
			
			it "should create a user" do
				lambda do
					post :create, :user => @attr
				end.should change(User, :count).by(1)
			end
			
			it "should redirect to the user show page" do
				post :create, :user => @attr
				response.should redirect_to(user_path(assigns(:user)))
			end
						
			it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end

      it "should sign the user in" do
        post :create, :user => @attr    # remember, RESTful convention is new action shows signin page
                                        # while create action (here) does the signing in
        controller.should be_signed_in
      end

		end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)      # needed as the edit page is protected from unauthorized access
    end

    it "should be successful" do
      get :edit, :id => @user         # the edit action needs the id in the url...
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user             # remember, idiom actually represents @user.id
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,    # a for anchor tag
                                         :content => "change")
    end




  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }              # this is the update
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr    # note additional param :user - this is the update
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }  # this is the update
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr

        # the following method reloads the @user var from the (test) db w/ @user.reload
        # and then verifies the user's name and email match the attributes in @attr hash
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]

        # the below code is an alternative
        # effectively it uses the assigns method to get the user object from the controller
        # then compares it with the factory user object created in this spec

        #user = assigns(:user)
        #@user.reload
        #@user.name.should == user.name
        #@user.email.should == user.email
        #@user.encrypted_password.should == user.encrypted_password
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => { }       # need bare hash to satisfy route, but otherwise useless
        response.should redirect_to(signin_path)
      end

    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net") # mod factories.rb user email
        test_sign_in(wrong_user)
      end

      #
      it "should require matching users for 'edit'" do
        get :edit, :id => @user                # attempt get action when logged in as wrong_user
        response.should redirect_to(root_path)
      end

      it "should requirematching users for 'update'" do
        put :update, :id => @user, :user => {} # attempt put action when logged in as wrong_user
        response.should redirect_to(root_path)
      end

    end

  end

  describe "GET 'index'" do

    describe "for non-singed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user)) # alt. syntax - cf above wrong_user variable
        second = Factory(:user, :email => "another@example.com")    # mod factories.rb user email
        third = Factory(:user, :email => "another@example.net")     # mod factories.rb user email

        @users = [@user, second, third]    # first three users, then push 30 more...
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))   # mod factories.rb user email
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        # previously we had only 3 users (@user, second, third)
        # now that we have 33 (an additional 30 pushed onto @users), we limit to testing the first 3
        # (old code commented out below)

        #@users.each do |user|
        #  response.should have_selector("li", :content => user.name)
        #end
        @users[0..2].each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination") # dig into page source/firebug to make this test
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end

      it "should have delete links for admins" do
        @user.toggle!(:admin)
        other_user = User.all.second
        get :index
        response.should have_selector("a", :href => user_path(other_user),
                                           :content => "delete")
      end

      it "should not have delete links for non-admins" do
        other_user = User.all.second
        get :index
        response.should_not have_selector("a", :href => user_path(other_user),
                                           :content => "delete")
      end

    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
     end

    describe "as an admin user" do
      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true) # user factories not bound by rules
                                                                              # of attr_accessible so we can pass
        test_sign_in(@admin)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end

      it "should not be able to destroy itself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
      end
    end

  end

  describe "follow pages" do

    describe "when not signed in" do

      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end

      it "should show user following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user),
                                           :content => @other_user.name)
      end

      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user),
                                           :content => @user.name)
      end
    end
  end
end
