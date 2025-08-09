class CreateShopFoods < ActiveRecord::Migration[7.2]
  def change
    create_table :shop_foods do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :food, null: false, foreign_key: true

      t.timestamps
    end
    add_index :shop_foods, [ :shop_id, :food_id ], unique: true
  end
end
