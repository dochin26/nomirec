Rails.application.routes.draw do
  devise_for :users
  root "static_pages#index"
  resources :posts, only: %i[index new show edit create update destroy]
end
