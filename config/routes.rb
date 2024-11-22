Rails.application.routes.draw do
  post '/scrapes', to: 'scrapes#create'
  post '/scrapes/completed', to: 'scrapes#completed'
  post '/scrapes/notify', to: 'scrapes#notify'
end
