Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users, controllers: {
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  root "static_pages#index"
  get "mypage", to: "my_pages#show"
  resources :posts, only: %i[index new show edit create update destroy] do
    collection do
      get "autocomplete"
    end
  end
  resources :shops, only: %i[index show edit create update destroy] do
    resources :likes, only: %i[create destroy]
  end
  get "location", to: "locations#show"
end
