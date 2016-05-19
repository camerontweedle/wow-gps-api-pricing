require 'test_helper'

class ListingRealmAuctionsTest < ActionDispatch::IntegrationTest
  setup do
    @realm1 = setup_realm('1', 'us')
    @realm2 = setup_realm('2', 'us')
    @realm3 = setup_realm('3', 'eu')
    @auctions = []
    travel 1.day
    setup_auctions(@realm1, @realm2, @realm3)
    travel_back
  end

  test 'list all auctions, based on realm' do
    get '/api/auctions/realm/us/test-realm-1', {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 20, json(response.body)[:auctions].size
  end

  test 'list all auctions, based on realm and period' do
    get '/api/auctions/realm/us/test-realm-1?period=48', {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 4, json(response.body)[:auctions].size
  end
end
