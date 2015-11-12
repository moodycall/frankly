Rails.application.routes.draw do

  # ADMIN PAGES
  # We want to keep admin information seperated as an added level of security
  constraints(:subdomain => 'admin') do
    
    resources :payouts,
              :controller => "admin_facing/payouts" do

      collection do
        put :bulk_transfer
        get :upcoming
      end
    end

    resources :specialties,
              :controller => "admin_facing/specialties" do
                
      collection do
        post :setDefault
      end
    end

    resources :prompts,
              :controller => "admin_facing/prompts"

    resources :counseling_sessions,
              :as         => :admin_counseling_session_overviews,
              :controller => "admin_facing/counseling_sessions",
              :only       => [:index] do

      collection do
        get :upcoming
      end
    end

    resources :counselors,
              :as         => :admin_counselor_overviews,
              :controller => "admin_facing/counselors",
              :only       => [:index, :getCounselors] do
      
      collection do
        post :getCounselors
      end
    end
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

    member do
      get :cancel
    end
  end

  resources :payouts do
  
  end

  resources :counselors do
  	member do
  		get :availability
      get :certifications
      get :licenses
      get :education
      get :payouts
      get :upcoming
      put :update_bank
      put :remove_degree
      put :remove_certification
      put :remove_license
  	end
  end

  devise_for :users, :controllers => {:registrations => "users/registrations", confirmations: 'users/confirmations'}

  get 'dashboard' => 'users/pages#dashboard', as: :user_dashboard
  get 'session-history' => 'users/pages#session_history', as: :user_session_history
  root "pages#home"

end
