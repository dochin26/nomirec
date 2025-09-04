class AddBodyImageToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :body_image, :string
  end
end
