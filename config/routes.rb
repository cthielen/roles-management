DSSRM::Application.routes.draw do
  get "site/index"

  get "site/contact"
  
  get "site/logout"

  resources :applications do
    resources :roles
  end

  resources :groups

  resources :people do
    collection do
      get 'new_from_ldap'
      post 'new_from_ldap'
    end
  end

  root :to => "site#index"

  namespace "api" do
    resources :people, :groups
    resources :applications do
      resources :roles
    end
  end
end
