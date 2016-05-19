class AuctionSerializer < ActiveModel::Serializer
  attributes :id, :auc, :item, :owner, :bid, :buyout, :quantity, :time_left, :original_realm, :realm_id, :pet_species_id, :pet_breed_id, :pet_level, :pet_quality_id, :created_at
end
