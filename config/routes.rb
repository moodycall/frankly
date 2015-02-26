Rails.application.routes.draw do

  # ADMIN PAGES
  # We want to keep admin information seperated as an added level of security
  constraints(:subdomain => 'admin') do
    
    resources :payouts,
              :controller => "admin_facing/payouts" do

      collection do
        put :bulk_transfer
        get :history
      end
    end

    resources :specialties,
              :controller => "admin_facing/specialties"

    resources :prompts,
              :controller => "admin_facing/prompts"

    resources :counseling_sessions,
              :as         => :admin_counseling_session_overviews,
              :controller => "admin_facing/counseling_sessions",
              :only       => [:index]

    resources :counselors,
              :as         => :admin_counselor_overviews,
              :controller => "admin_facing/counselors",
              :only       => [:index]

  end

  # PUBLIC/USER PAGES
  # We want to keep admin information seperated as an added level of security

  resources :favorite_counselors,
            :only => [:create, :destroy, :index]

  resources :credit_cards,
            :except => [:edit, :show, :destroy],
            :path => "payments" do
    member do
      get :deactivate
    end
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
