class CreateIterations < ActiveRecord::Migration[7.2]
  def change
    create_table :iterations do |t|
      t.belongs_to :board, null: false, foreign_key: true
      t.point :life_locations, array: true, null: false
      t.belongs_to :original_iteration, null: true, foreign_key: { to_table: :iterations }
      t.boolean :is_final, null: false, default: false
      t.timestamps
    end
  end
end
