
  resources :issue_causes do
    collection do 
      get 'autocomplete'
      get 'bulk_edit'
      post 'bulk_update'
      get 'context_menu'
    end
  end
