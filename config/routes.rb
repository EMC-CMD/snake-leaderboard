Rails.application.routes.draw do
  post '/', to: 'leaders#create'
  get '/index', to: 'leaders#index'
end
