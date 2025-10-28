Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users, controllers: {
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  root "static_pages#index"
  resources :posts, only: %i[index new show edit create update destroy]
  get "location", to: "locations#show"
end
