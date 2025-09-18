class ChangeLongitudeToShopPlaces < ActiveRecord::Migration[7.2]
  def change
    change_column :shop_places, :longitude, :float
  end
end
