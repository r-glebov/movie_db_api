class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.text :description, default: ''
      t.float :rating, default: 0
      t.references :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
