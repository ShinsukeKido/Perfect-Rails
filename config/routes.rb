Rails.application.routes.draw do
  resource :user, only: :destroy do
    get 'retire'
  end

  resources :events do
    resources :tickets, only: [:create, :destroy]
  end
  root 'welcome#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/logout' => 'sessions#destroy', as: :logout
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
