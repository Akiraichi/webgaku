Rails.application.routes.draw do
  root "topics#index"
  resources :about, :contact, :gallery, :service
  get 'about/downloadpdf/download' => 'about#downloadpdf'
end
