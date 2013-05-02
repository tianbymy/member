Member::Application.routes.draw do
  match "/users/register" => "users#new"
  resources :users,:only => [:create,:edit,:update] do
    collection do
      get "change_password"
      put "update_password"
    end
  end

end
