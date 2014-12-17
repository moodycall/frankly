Rails.application.routes.draw do
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
  
  root "counselors#index"
end
