class ApplicationController < ActionController::Base
  protect_from_forgery

  # signin functions must be available in both controllers and views
  # instead of creating new module, we use SessionsHelper module
  # Helpers are automatically included in Rails views, so to use in controllers
  # we include the module into the Application controller
  include SessionsHelper
end
