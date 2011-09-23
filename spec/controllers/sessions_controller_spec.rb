require 'spec_helper'

describe SessionsController do
  render_views          # required by e.g. have_selector tag

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign in")
    end

  end

  describe "POST 'create'" do

    describe "invalid signin" do
      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end

      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end

      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Sign in")
      end

      it "should have a flash.now message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end

    end

    describe "with valid email and password" do

      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user   # the controller variable is available inside Rails tests
        controller.should be_signed_in    # equiv. to controller.signed_in?.should be_true: our own signed_in? method!
      end

      it "should redirect to the user show page" do
        post :create, :session => @attr
        response.should redirect_to(user_path(@user))
      end

    end


  end

  describe "DELETE 'destroy'" do

    it "should sign a user out" do
      test_sign_in(Factory(:user))        # sign in a user inside of a test defined in spec_helper.rb
      delete :destroy       # send HTTP request DELETE, action destroy (actually no real DELETE in HTTP, done by javascript)
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end

end
