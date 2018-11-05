Rails.application.routes.draw do
  root "topics#index"
  resources :about, :contact, :gallery, :service
end
