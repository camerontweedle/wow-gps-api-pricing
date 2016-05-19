class BlizzardApiJob < ActiveJob::Base
  queue_as :auctions

  def perform(realm_id, last_modified, *args)
    realm = Realm.find(realm_id)
    json = JSON.parse(open(realm.auction_url).read, symbolize_names: true)
    sql = []
    json[:auctions].each do |auc|
      auc[:petSpeciesId]  ||= 0 unless auc[:petSpeciesId]
      auc[:petBreedId]    ||= 0 unless auc[:petBreedId]
      auc[:petQualityId]  ||= 0 unless auc[:petQualityId]
      auc[:petLevel]      ||= 0 unless auc[:petLevel]
      sql << "INSERT INTO auctions (auc, item, owner, original_realm, bid, buyout, quantity, time_left, rand, seed, context, pet_species_id, pet_breed_id, pet_level, pet_quality_id, realm_id, created_at, updated_at)
              VALUES (#{auc[:auc]}, #{auc[:item]}, '#{auc[:owner]}', '#{auc[:ownerRealm]}', #{auc[:bid]}, #{auc[:buyout]}, #{auc[:quantity]}, '#{auc[:timeLeft]}', #{auc[:rand]}, #{auc[:seed]}, #{auc[:context]}, #{auc[:petSpeciesId]}, #{auc[:petBreedId]}, #{auc[:petLevel]}, #{auc[:petQualityId]}, #{realm_id}, '#{DateTime.now.utc}', '#{DateTime.now.utc}')
              ON CONFLICT (auc, realm_id) DO UPDATE SET time_left = '#{auc[:timeLeft]}', updated_at = '#{DateTime.now.utc}'"
    end
    
    Auction.connection.execute(sql.join(';'))
    realm.last_modified = DateTime.parse(last_modified)
    realm.save
  end
end
