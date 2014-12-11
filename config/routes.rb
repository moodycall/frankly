Rails.application.routes.draw do
  resources :counselors

  devise_for :users, :controllers => {:registrations => "users/registrations"}
  get 'dashboard' => 'users/pages#dashboard', as: :user_dashboard
  
  root "counselors#index"
end
