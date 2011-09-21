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
end
