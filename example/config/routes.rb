CrummyTest::Application.routes.draw do
  resources :posts

  root to: 'pages#index'
end
