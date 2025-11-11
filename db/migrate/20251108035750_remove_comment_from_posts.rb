class RemoveCommentFromPosts < ActiveRecord::Migration[7.2]
  def change
    remove_column :posts, :comment, :text
  end
end
