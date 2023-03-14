Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :roles
      resources :users
      resources :assignments
      resources :questions do
        collection do
          get :view
          post :add_new_questions
        end
      end
      resources :questionnaires, except: [:index] do
        collection do
          get :view
          post 'copy/:id', to: 'questionnaires#copy', as: 'copy'
          post 'update/:id', to: 'questionnaires#update', as: 'update'
          delete 'delete/:id', to: 'questionnaires#delete', as: 'delete'
          post 'toggle_access/:id', to: 'questionnaires#toggle_access', as: 'toggle_access'
        end
      end
    end
  end


end
