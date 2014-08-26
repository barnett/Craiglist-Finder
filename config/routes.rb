Rails.application.routes.draw do

  get 'home/landing'

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" } do
    get 'login', 'sessions#new'
    post 'logout', 'sessions#destroy'
  end

  resources :rooms
  resources :users, only: :update

  root 'home#landing'

  match "/delayed-job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

end
