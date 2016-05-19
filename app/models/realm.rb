class Realm < ActiveRecord::Base
  has_many :auctions

  def getRealmURL
    json = JSON.parse(open("https://#{self.region}.api.battle.net/wow/auction/data/#{self.slug}?locale=en_US&apikey=#{ENV['blizzard_api_key']}").read, symbolize_names: true)
    self.auction_url = json[:files][0][:url]
    self.save
  end
end
