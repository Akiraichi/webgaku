Rails.application.routes.draw do
  root "topics#index"
  resources :about
end
