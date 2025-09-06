class CreateShopPlaces < ActiveRecord::Migration[7.2]
  def change
    create_table :shop_places do |t|
      t.references :shop, null: false, foreign_key: true
      t.integer :latitude
      t.integer :longitude
      t.string :address

      t.timestamps
    end
  end
end
