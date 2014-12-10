Rails.application.routes.draw do
  resources :counselors

  devise_for :users
  
  root "counselors#index"
end
