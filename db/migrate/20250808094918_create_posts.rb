class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user
      t.references :shop
      t.text :comment, null: false

      t.timestamps
    end
  end
end
