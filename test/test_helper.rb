ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def json(body)
    JSON.parse(body, symbolize_names: true)
  end

  def setup_realm(num = '', region)
    Realm.create!(:name => "Test Realm #{num}", :slug => "test-realm-#{num}", :region => "#{region}", :realm_type => "pve", :population => "medium",
                            :source_realm => "test-realm-#{num}", :auction_url => "https://test-realm-#{num}-url.com", :last_modified => Time.now, :status => "enabled")
  end

  def setup_auctions(realm1, realm2, realm3)
    10.times do |i|
      travel -1.day
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 1, owner: "Owner#{i}", original_realm: "#{realm1.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm1.id)
      )
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 2, owner: "Owner#{i}", original_realm: "#{realm1.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm1.id)
      )
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 1, owner: "Owner#{i}", original_realm: "#{realm2.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm2.id)
      )
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 2, owner: "Owner#{i}", original_realm: "#{realm2.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm2.id)
      )
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 1, owner: "Owner#{i}", original_realm: "#{realm3.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm3.id)
      )
      @auctions.push(
        Auction.create!(auc: rand(1..100000), item: 2, owner: "Owner#{i}", original_realm: "#{realm3.slug}", bid: i.to_i * 100000,
          buyout: i.to_i * 200000, quantity: i.to_i + 1, time_left: "LONG", rand: 0, seed: 0, context: 0, realm_id: realm3.id)
      )
    end
  end
end
