Rails.application.routes.draw do

  root to: 'users#welcome'

  get '/register', to: 'users#new'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/team_schedule', to: 'rosters#show_teams'
  post '/rosters/:id', to: 'rosters#create'

  resources :rosters
  resources :users, only: [:create, :edit, :show, :update]

end
