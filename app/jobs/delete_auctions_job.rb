class DeleteAuctionsJob < ActiveJob::Base
  queue_as :delete

  after_perform do
    self.class.set(wait: 55.minutes).perform_later
  end

  def perform(*args)
    # uses the 'auction_delete_timeframe' ENV variable, set via /config/application.yml
    Auction.beyondTimeframe(ENV['auction_delete_timeframe']).delete_all
  end
end
