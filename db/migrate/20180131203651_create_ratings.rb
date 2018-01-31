class CreateRatings < ActiveRecord::Migration[5.1]
  def change
    create_table :ratings do |t|
      t.references :movie, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.integer :score, default: 0

      t.timestamps
    end
  end
end
