Rails.application.routes.draw do
  root "topics#index"
  resources :about, :contact, :gallery, :service
  get 'about/downloadpdf/download' => 'about#downloadpdf'

  get 'contact' => 'contact#index' 
  get 'contact/confirm' => redirect("/contact")
  get 'contact/thanks' => redirect("/contact")
  ##### 問い合わせ確認画面
  post 'contact/confirm' => 'contact#confirm'
  ##### 問い合わせ完了画面
  post 'contact/thanks' => 'contact#thanks'

  ##LINEBot
  post '/callback' => 'linebot#callback'
end
