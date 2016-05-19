Rails.application.routes.draw do
  namespace :api do
    get "/auctions/items/:item_id" => "item_auctions#index"
    get "/auctions/realm/:region/:slug" => "realm_auctions#index"
  end
end
