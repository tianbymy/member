Member::Application.routes.draw do
  match "/users/register" => "users#new"
  resources :users do
    collection do
      get "change_password"
      get "edit_user"
      get "forgot_password"
      post "search"
      get "set_new_password"
      post "send_reset_password_email"
    end
    member do
      get "lock"
      put "update_password"
      get 'reset_password'
      post "update"
      post "update_password"
    end
  end
  root :to => 'users#new'
end
