Rails.application.routes.draw do

  # ADMIN PAGES
  # We want to keep admin information seperated as an added level of security
  resources :specialties,
            :controller => "admin_facing/specialties",
            :except     => [:show]

  # PUBLIC/USER PAGES
  # We want to keep admin information seperated as an added level of security

  resources :favorite_counselors,
            :only => [:create, :destroy, :index]

  resources :credit_cards,
            :except => [:edit, :show],
            :path => "payments" do
  end

  resources :counseling_sessions do
    resources :ratings
  end

  resources :counselors do
  	member do
  		get :availability
  	end
  end

  devise_for :users, :controllers => {:registrations => "users/registrations"}

  get 'dashboard' => 'users/pages#dashboard', as: :user_dashboard
  root "pages#home"

end
