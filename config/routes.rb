Rails.application.routes.draw do
  post '/', to: 'leaders#create'
  get '/validate', to: 'leaders#validate'
  get '/index', to: 'leaders#index'
end
