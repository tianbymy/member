Member::Application.routes.draw do
  match "/users/register" => "users#new"
  resources :users do
    post "update_password"
    put "update_password"

    collection do
      get "change_password"
      get "edit_user"
      get "edit"
      get "forgot_password"
      get 'reset_password'
      post "search"
      post "update_info"
      get "set_new_password"

      post "send_reset_password_email"
      get "lock"
      delete "destroy"
      get 'reset_password'
      put "update_info"
    end
  end
  match '/logout' => 'application#logout'
  root :to => 'users#new'
end
