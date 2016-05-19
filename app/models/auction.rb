class Auction < ActiveRecord::Base
  belongs_to :realm

  scope :byItem, -> (itemId) { where(:item => itemId) }
  scope :byRegion, -> (region) { where(:realm_id => Realm.select(:id).where(:region => region)) }
  scope :byRealm, -> (realm) { where("realm_id = ?", realm.id) }
  scope :byPeriod, -> (period) { where("created_at >= ?", (Time.now.utc - period.to_i.hours).to_datetime) }
  scope :beyondTimeframe, -> (expiry_date) { where("created_at <= ?", (Time.now.utc - expiry_date.to_i.hours).to_datetime) }
end
