class UsersController < ApplicationController

  # before filter arranges for a  particular method to be called before the given actions
  # actions index, edit, update, destroy require user to be signed in
  before_filter :authenticate, :only => [:index, :edit, :update, :destroy]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def index
    @title = "All users"
    # replace User.all. note that params[:page] is generated automatically by will_paginate in index.html.erb
    # @users = User.all
    @users = User.paginate(:page => params[:page])   # return WillPaginate::Collection for will_paginate in index.html.erb
  end

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

  def edit
    # @user = User.find(params[:id])  # this is now refactored into the before filter "correct_user"
    @title = "Edit user"
  end

  def update
    # @user = User.find(params[:id])  # this is now refactored into the before filter "correct_user"
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end

  end

  def destroy
    User.find(params[:id]).destroy        # lookup the id assoc. w/ HTTP request to DELETE /users/x
    flash[:success] = "User destroyed"
    redirect_to users_path
  end

  private

    def authenticate
      deny_access unless signed_in?
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?      # go back to root if non-admin attempts deletion
    end

end
