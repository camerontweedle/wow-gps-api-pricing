module Api
  class ItemAuctionsController < ApplicationController
    def index
      if params[:region] && params[:realm]
        auctions = Auction.byItem(params[:item_id]).byRealm(Realm.where(:region => params[:region], :slug => params[:realm]).first)
      elsif params[:region]
        auctions = Auction.byItem(params[:item_id]).byRegion(params[:region])
      else
        auctions = Auction.byItem(params[:item_id])
      end

      auctions = auctions.byPeriod(params[:period]) if params[:period]

      respond_to do |format|
        format.json { render json: auctions, each_serializer: ::AuctionSerializer, status: 200, :root => 'auctions' }
      end
    end
  end
end
