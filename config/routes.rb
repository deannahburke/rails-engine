Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
    get "/merchants/find", to: "search#merchant_search"
    get "/items/find_all", to: "search#items_search"
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: :merchant_items
      end
      resources :items, only: [:index, :show, :create, :update, :destroy] do
        resources :merchant, only: [:index],
        controller: :item_merchant
      end
    end
  end
end
