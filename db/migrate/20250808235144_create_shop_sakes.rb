class CreateShopSakes < ActiveRecord::Migration[7.2]
  def change
    create_table :shop_sakes do |t|
      t.references :shop, null: false, foreign_key: true
      t.references :sake, null: false, foreign_key: true

      t.timestamps
    end
    add_index :shop_sakes, [:shop_id, :sake_id], unique: true
  end
end
