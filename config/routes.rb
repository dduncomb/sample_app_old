SampleApp::Application.routes.draw do

# pages controller ---------------------------------------------------------------

# Previously, we used (for example) get “pages/home”, which was inserted into routes.rb
# automatically by the command: rails generate controller Pages home contact
# This maps get requests for URL /pages/home (implicitly) to the home action in the Pages controller

# get "pages/home"
# get "pages/contact"
#	get "pages/about"
#	get "pages/help"

# Now, we introduce named routes as a replacement
# Generally these are referred to in the layout as an argument to the "link_to" helper method

# Consider the about custom route (shown below).  This gives us the named routes
# about_path (url: /about) and about_url (url: http://localhost:3000/about)

match '/contact', :to => 'pages#contact'
match '/about',  :to => 'pages#about'
match '/help',    :to => 'pages#help'

# special case
# this code maps the root URL / to /pages/home, and also gives the URL helpers as follows:
# root_path => '/'
# root_url => 'http://localhost:3000'
root :to => 'pages#home'

#note: the helper link_to now can use named routes, e.g. root_path or contact_path etc.


# users controller ---------------------------------------------------------------

# Again, the controller generation bestowed us the following, which we replaced below
# this time with the users resource + one custom route

#get "users/new"

#When following REST principles, resources are typically referenced using the resource name
#and a unique identifier. What this means in the context of users—which we’re now thinking
#of as a Users resource—is that we should view the user with id 1 by issuing a GET request
#to the URL /users/1. Here the show action is implicit in the type of request—when Rails’ REST
#features are activated, GET requests are automatically handled by the show action.

# to get users/1 to work, for example, add users as a resource

  resources :users do
    member do
      get :following, :followers
    end
  end

# complete list of named routes created by the users resource:

#HTTP request	  URL	          Action	    Named route	      Purpose
#=====================================================================================
#GET	          /users	      index	      users_path	      page to list all users
#GET	          /users/1	    show	      user_path(1)	    page to show user with id 1
#GET	          /users/new	  new	        new_user_path	    page to make a new user (signup)
#POST	          /users	      create	    users_path	      create a new user
#GET	          /users/1/edit	edit	      edit_user_path(1)	page to edit user with id 1
#PUT	          /users/1	    update	    user_path(1)	    update user with id 1
#DELETE	        /users/1	    destroy	    user_path(1)	    delete user with id 1

# and the list of named routes created after the addition of the member method
#HTTP request	  URL	                Action	    Named route
#=====================================================================================
#GET	          /users/1/following  following  following_user_path(1)
#GET	          /users/1/followers  followers  followers_user_path(1)


# custom route for users controller
match '/signup', :to => 'users#new'


# sessions controller ---------------------------------------------------------------

# Again, the controller generation bestowed us the following, which we replaced below
# this time with the sessions resource + two custom routes

#  get "sessions/new"

# RESTful convention uses new for signin page, create to complete the signin, and
# destroy to delete sessions ie signout

# add a sessions resource
resources :sessions, :only => [:new, :create, :destroy]   # limit the actions created

# custom routes for sessions controller
match '/signin',  :to => 'sessions#new'
match '/signout', :to => 'sessions#destroy'


# complete list of named routes created by the sessions resource + custom routes:

# provided by the sessions resource (above) and custom routes (below)
#HTTP request	  URL	          Action	    Named route	      Purpose
#=====================================================================================
#GET            /signin	      new	        signin_path	      page for a new session (signin)
#POST	          /sessions	    create	    sessions_path	    create a new session
#DELETE	        /signout	    destroy	    signout_path	    delete a session (sign out)


# add a microposts resource
resources :microposts, :only => [:create, :destroy]


# complete list of named routes created by the microposts resource
#HTTP request	  URL	          Action	    Named route	      Purpose
#=====================================================================================
#POST	          /microposts   create	    microposts_path	    create a new micropost
#DELETE	        /microposts/1 destroy	    microposts_path(1)  delete micropost with id 1


resources :relationships, :only => [:create, :destroy]

# complete list of named routes created by the microposts resource
#HTTP request	  URL	              Action	    Named route	            Purpose
#=====================================================================================
#POST	          /relationships    create	    relationships_path	    create a new relationship
#DELETE	        /relationships/1  destroy	    relationships_path(1)   delete relationship with id 1


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
