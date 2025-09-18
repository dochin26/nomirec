class ChangeLatitudeToShopPlaces < ActiveRecord::Migration[7.2]
  def change
    change_column :shop_places, :latitude, :float
  end
end
