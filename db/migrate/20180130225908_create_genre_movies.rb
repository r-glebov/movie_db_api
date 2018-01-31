class CreateGenreMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :genre_movies do |t|
      t.references :movie, foreign_key: true, index: true
      t.references :genre, foreign_key: true, index: true

      t.timestamps
    end
  end
end
