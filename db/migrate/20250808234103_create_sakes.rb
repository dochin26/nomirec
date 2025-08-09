class CreateSakes < ActiveRecord::Migration[7.2]
  def change
    create_table :sakes do |t|
      t.string :name

      t.timestamps
    end
    add_index :sakes, :name, unique: true
  end
end
