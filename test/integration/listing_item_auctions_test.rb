require 'test_helper'

class ListingItemAuctionsTest < ActionDispatch::IntegrationTest
  setup do
    @realm1 = setup_realm('1', 'us')
    @realm2 = setup_realm('2', 'us')
    @realm3 = setup_realm('3', 'eu')
    @auctions = []
    travel 1.day
    setup_auctions(@realm1, @realm2, @realm3)
    travel_back
  end

  test 'lists all auctions, based on item ID' do
    get "/api/auctions/items/1", {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 30, json(response.body)[:auctions].size
  end

  test 'lists all auctions, based on item ID and realm' do
    get '/api/auctions/items/1?region=us&realm=test-realm-1', {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 10, json(response.body)[:auctions].size
  end

  test 'lists all auctions, based on item ID and region' do
    get '/api/auctions/items/1?region=us', {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 20, json(response.body)[:auctions].size
  end

  test 'lists all auctions, based on item ID and period' do
    get '/api/auctions/items/1?period=48', {}, { 'Accept' => 'application/json' }

    assert_equal 200, response.status
    assert_equal Mime::JSON, response.content_type

    assert_equal 6, json(response.body)[:auctions].size
  end
end
