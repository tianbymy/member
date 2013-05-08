Member::Application.routes.draw do
  match "/users/register" => "users#new"
  resources :users,:only => [:create,:edit,:update] do
    collection do
      get "change_password"
      get "forgot_password"
      post "reset_password"
    end
    member do
      put "update_password"
      get "set_new_password"
    end
  end

end
