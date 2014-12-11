Rails.application.routes.draw do
  resources :counselors

  devise_for :users, :controllers => {:registrations => "users/registrations"}
  
  root "counselors#index"
end
