require 'spec_helper'

describe "FriendlyForwardings" do

  it "should forward to the requested page after signin" do
    user = Factory(:user)
    # we haven't logged on yet we call up edit user page
    # the user's intended destination is stored in deny_access helper method in sessions_helper.rb
    visit edit_user_path(user)
    # The test automatically follows the redirect to the signin page
    # ie testing that the response.should redirect_to some URL won't work
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button
    # The test follows the redirect again, this time to users/edit (ie the original intention)
    response.should render_template('users/edit')
  end

end
