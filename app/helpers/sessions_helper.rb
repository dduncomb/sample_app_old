module SessionsHelper

  def sign_in(user)
    # this is the cookies utility supplied by Rails
    # we can use cookies as if it were a hash

    #The assignment value on the right-hand side is an array consisting of a
    #unique identifier (i.e., the user’s id) and a secure value used to create a
    #digital signature to prevent the kind of attacks described in Section 7.2.
    #
    #In particular, since we went to the trouble of creating a secure salt, we
    #can re-use that value here to sign the remember token. Under the hood,
    #using permanent causes Rails to set the expiration to 20.years.from_now, and
    #signed makes the cookie secure, so that the user’s id is never exposed in the browser.

    cookies.permanent.signed[:remember_token] = [user.id, user.salt]

    # the purpose of this next line is to create current_user, accessible in both controllers
    # and views, which will allow e.g. both <%= current_user.name %> and redirect_to current_user
    current_user = user


  end

  def current_user=(user)        # special setter method syntax
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token       # optimization technique to avoid repeated calls
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    cookies.delete(:remember_token)      # delete the (by default) 20 year cookie
    current_user = nil
  end


  private

    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)   # splat operator needed (remember_token method returns 2
                                                     # element array and authenticate_with_salt method
                                                     # in user model expects 2 args )
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]      # returns an array of two elements (user id and salt)
                                                         # the remember token is placed as a cookie on the
                                                         # user's browser above in sign_in method, with
                                                         # user id and salt (to defeat malicious attacks)
    end



end
