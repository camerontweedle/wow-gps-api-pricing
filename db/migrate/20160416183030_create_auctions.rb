class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.integer :auc, :limit => 8
      t.integer :item
      t.string :owner
      t.string :original_realm
      t.integer :bid, :limit => 8
      t.integer :buyout, :limit => 8
      t.integer :quantity
      t.string :time_left
      t.integer :rand
      t.integer :seed, :limit => 8
      t.integer :context
      t.integer :pet_species_id
      t.integer :pet_breed_id
      t.integer :pet_level
      t.integer :pet_quality_id
      t.integer :realm_id
      #  t.array :bonusLists #N/A for now
      #  t.array :modifiers #N/A for now

      t.timestamps null: false

      t.index [:auc, :realm_id], :unique => true
    end

    add_foreign_key :auctions, :realms
  end
end
