Rails.application.routes.draw do
  post '/', to: 'leaders#create'
  post '/leaders_by_time', to: 'leaders#leaders_by_time'
  get '/validate', to: 'leaders#validate'
  get '/index', to: 'leaders#index'
end
