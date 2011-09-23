class ApplicationController < ActionController::Base
  protect_from_forgery


  # by default, helpers (including sessions_helper.rb) are available only in views
  # however, we want access to signed_in? method in the sessions helper in
  # different controllers. We could include the sessionsHelper module in a specific
  # controller - say, sessions_controller - but as these controllers inherit from
  # this controller (application_controller.rb), we can simply place the include here

  include SessionsHelper
end
