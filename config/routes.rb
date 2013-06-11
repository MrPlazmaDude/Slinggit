SlinggitWebapp::Application.routes.draw do
  #ajax methods
  match 'users/set_no_thanks', :to => 'users#set_no_thanks', via: :get
  match 'users/reset_page_session', :to => 'users#reset_page_session', via: :get
  match 'users/verify_email_availability', :to => 'users#verify_email_availability', via: :post
  match 'users/verify_username_availability', :to => 'users#verify_username_availability', via: :post
  match 'users/update_email_and_send_verification', :to => 'users#update_email_and_send_verification', via: :put
  match '/edit_email_for_verification', :to => 'users#edit_user_email_for_verification', :as => 'prep_for_reverification'
  match 'networks/set_primary_account', :to => 'networks#set_primary_account', via: :post
  # CMK -> I really don't like this design, need to come back and refactor this.
  match 'posts/filtered_list', :to => 'posts#filtered_list'

  match 'users/email_preferences', :to => 'users#email_preferences'
  match 'users/enter_new_password/(:id)', :to => 'users#enter_new_password#id'
  match 'users/password_reset', :to => 'users#password_reset'
  match 'users/reactivate(/:id)', :to => 'users#reactivate#id', via: :get
  match 'users/destroy', :to => 'users#destroy', via: :delete
  match 'users/delete_account', :to => 'users#delete_account', via: :get
  match 'users/verify_email(/:id)', :to => 'users#verify_email#id'
  match 'users/new(/:id)', :to => 'users#new#id'
  match 'users/watching', :to => 'users#watching', as: "users_watching", via: :get
  match 'users/archived', to: 'users#archived', as: "users_archived", via: :get
  match 'networks/delete_account', :to => 'networks#delete_account', via: :post
  match 'networks/add_api_account(/:id)', :to => 'networks#add_api_account#id', via: :get
  match 'networks/twitter_callback', :to => 'networks#twitter_callback', via: :get
  match 'networks/facebook_callback', :to => 'networks#facebook_callback', via: :get
  match 'sessions/sign_out_of_device', :to => 'sessions#sign_out_of_device', via: :post
  match 'posts/results/(:id)', :to => 'posts#results#id', via: :get
  match 'posts/delete_post', :to => 'posts#delete_post'
  match 'posts/report_abuse(/:id)', :to => 'posts#report_abuse#id'
  match 'posts/repost(/:id)', :to => 'posts#repost#id'
  match 'posts/edit_field(/:id)', :to => 'posts#edit_field#id'
  match 'additional_photos/add', :to => 'additional_photos#add', :via => :post

  match 'watchedposts/interested', :to => 'watchedposts#interested'
  match 'watchedposts/uninterested', :to => 'watchedposts#uninterested'

  match 'messages/delete(/:id)', :to => 'messages#delete#id'
  match 'messages/delete_all', :to => 'messages#delete_all'
  match 'messages/new(/:id)', :to => 'messages#new#id'
  match 'messages/reply(/:id)', :to => 'messages#reply#id'
  match 'messages/sent', :to => 'messages#sent'

  resources :users
  resources :messages
  resources :sessions, only: [:new, :create, :destroy, :index]
  resources :posts, only: [:new, :create, :destroy, :edit, :show, :update]
  resources :networks, only: [:index, :create, :destroy]
  resources :watchedposts

  match '/twitter_callback', :to => 'twittersessions#callback', :as => 'callback'
  match '/facebook_callback', :to => 'facebooksessions#callback', :as => 'facebook_callback'
  match '/twitter_signup_callback', :to => 'users#twitter_signup_callback'
  match '/reauthorize_twitter', to: 'twittersessions#reauthorize'
  match '/create_reauthorization', to: 'twittersessions#create_reauthorization'
  match '/reauthorize_callback', to: 'twittersessions#reauthorize_callback'

  resources :twittersessions
  resource :facebooksessions

  root to: 'static_pages#home'

  match '/signup', to: 'users#new'
  match '/request_invitation', to: 'users#request_invitation', :as => 'request_invitation'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/about', to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/help', to: 'static_pages#help'
  match '/suspended_account', to: 'static_pages#suspended_account'
  match '/deleted_account', to: 'static_pages#deleted_account'
  match '/reactivate_account', to: 'static_pages#reactivate_account'
  match '/terms_of_service', to: 'static_pages#terms_of_service'

  resources :additional_photos
  # Nested route for comments.  I'm a bit worried that I'm defining resource :posts twice,
  # the other above, but couldn't find documentation on how to combine the two so that posts
  # can keep the only contraint.  Not entirely sure I'll need this yet.
  resources :posts do
    resources :comments
  end
  match 'comments/delete(/:id)', :to => 'comments#delete#id'

  ##MOBILE CONTROLLER##
  match 'mobile' => 'mobile#index'
  match 'mobile(/:action)(/:id)', :to => 'mobile#action#id'

  ##ADMIN CONTROLLER##
  match 'admin' => 'admin#index', :as => :admin_dashboard
  # CMK: added this for more convenient redirect with user destroy/suspend/reenable actions
  match 'admin/users' => 'admin#view_users', :as => :admin_users
  match 'admin/users(/:id)' => 'admin#view_user#id', :as => :admin_user
  match 'admin/posts' => 'admin#view_posts', :as => :admin_posts
  match 'admin/post(/:id)', to: 'admin#view_post#id', :as => :admin_post
  match 'admin/comments' => 'admin#view_comments', :as => :admin_comments
  match 'admin/comment(/:id)', to: 'admin#view_comment#id', :as => :admin_comment
  match 'admin/view_database', to: 'admin#view_database', as: :admin_database
  match 'admin/problem_reports', to: 'admin#problem_reports', as: :admin_problem_reports
  match 'admin(/:action(/:id))' => 'admin#action#id'

  ##TEST CONTROLLER##
  match 'test' => 'test#index'
  match 'test(/:action)(/:id)', :to => 'test#action#id'

  ##BACKEND CONTROLLER##
  match 'backend/daily_jobs', :to => 'backend#daily_jobs'

  ##SITE MODES##
  match '/maintenence', to: 'static_pages#maintenence', :as => 'maintenence'
  match '/over_capacity', to: 'static_pages#over_capacity', :as => 'over_capacity'

  match '*path', :to => 'application#redirect'
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
