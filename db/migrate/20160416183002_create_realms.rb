class CreateRealms < ActiveRecord::Migration
  def change
    create_table :realms do |t|
      t.string :name
      t.string :slug
      t.string :region
      t.string :realm_type
      t.string :population
      t.string :source_realm
      t.text :auction_url
      t.datetime :last_modified
      t.string :status

      t.timestamps null: false
    end
  end
end
