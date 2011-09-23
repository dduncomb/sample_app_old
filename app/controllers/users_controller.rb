class UsersController < ApplicationController
	
	def show
		@user = User.find(params[:id])
		@title = @user.name
	end
  
  def new                           # form_for helper in new.html.erb expects @user to be populated
  	@user = User.new                # user object (active record object), used w/ form_for helper
  	@title = "Sign up"
  end

	def create                       # the users resource (in routes.rb) ensures a POST request
                                   # to /users is handled by the create action (RESTful named route)
		@user = User.new(params[:user])
		if @user.save
      sign_in @user                # auto sign-in after successful create
			flash[:success] = "Welcome to the Sample App!" # flash is global; this is rendered in app layout
			redirect_to @user			
		else                          # do not pass go! do not collect $200! Back to sign up page...
			@title = "Sign up"
      @user.password = ''
      @user.password_confirmation = ''
			render 'new'
		end
	end

end
