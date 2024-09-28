class CreateBoards < ActiveRecord::Migration[7.2]
  def change
    create_table :boards do |t|
      t.integer :height, null: false
      t.integer :width, null: false
      t.point :life_locations, array: true, null: false
      t.integer :max_iterations, null: false, default: 100
      t.string :status, null: false, default: "initialized"
      t.timestamps
    end
  end
end
