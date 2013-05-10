Member::Application.routes.draw do
  match "/users/register" => "users#new"
  resources :users do
    collection do
      get "change_password"
      get "forgot_password"
      post "send_reset_password_email"
    end
    member do
      put "update_password"
      get "set_new_password"
      get 'reset_password'
    end
  end
match '/logout' => 'application#logout'
end
