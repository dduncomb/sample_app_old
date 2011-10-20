class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    # raise params.inspect
    @user = User.find(params[:relationship][:followed_id]) # nested hash retrieval - uncomment line above
    current_user.follow!(@user)
    # redirect_to @user # not needed with Ajax, instead call respond_to (no relation to Rspec)...
    respond_to do |format|
      format.html { redirect_to @user }     # if html request this line is executed...
      format.js        # ... else if its a javascript request, this line gets exeucuted
                       #  by default, format.js calls create.js.erb in this context
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    # redirect_to @user # not needed with Ajax, instead call respond_to (no relation to Rspec)...
    respond_to do |format|
      format.html { redirect_to @user }       # if html request this line is executed...
      format.js           #  ... else if its a javascript request, this line gets exeucuted
                          #  by default, format.js calls create.js.erb in this context
    end
  end
end