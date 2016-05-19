class RealmStatusJob < ActiveJob::Base
  queue_as :default

  after_perform do
    Sidekiq::Queue.new.clear
    self.class.set(wait: 30.minutes).perform_later
  end

  def perform(*args)
    realms = Realm.where("slug = source_realm AND status = 'enabled'").each do |realm|
      uri = URI(realm.auction_url)
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request_head(uri.path)
      date = DateTime.parse(response['Last-Modified'])
      if realm.last_modified && date > realm.last_modified || realm.last_modified.nil?
        BlizzardApiJob.perform_later(realm.id, date.to_s)
      end
    end
  end
end
