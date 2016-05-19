module Api
  class RealmAuctionsController < ApplicationController
    def index
      auctions = Auction.byRealm(Realm.where(:region => params[:region], :slug => params[:slug]).first)
      auctions = auctions.byPeriod(params[:period]) if params[:period]

      respond_to do |format|
        format.json { render json: auctions, each_serializer: ::AuctionSerializer, status: 200, :root => 'auctions' }
      end
    end
  end
end
