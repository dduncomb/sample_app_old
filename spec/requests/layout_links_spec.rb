require 'spec_helper'

describe "LayoutLinks" do                     # integration test for testing routing, link navigation
	it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a Help page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

  it "should have a signup page at '/signup'" do                    # signup handled by users controller
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end  	

  it "should have a signin page at '/signin'" do
    get '/signin'
    response.should have_selector('title', :content => "Sign in")
  end

# this integration test so far tests the routing, but doesn't actually
# check that the links on the layout go to the right pages.
# visit and click_link fix this!   these are webrat methods

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Help"
    response.should have_selector('title', :content => "Help")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Sign up now!"
    response.should have_selector('title', :content => "Sign up")
  end

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path,
                                         :content => "Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = Factory(:user)
      visit signin_path                               # test_sign_in method in spec_helper does not work
      fill_in :email,    :with => @user.email         # inside integration tests, so visit and submit
      fill_in :password, :with => @user.password      # valid email/password pair like this
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user), # recall idiom: shortcut for user_path(@user.id)
                                         :content => "Profile")
    end

  end


end
