Movie.__elasticsearch__.create_index!(force: true) unless Movie.__elasticsearch__.index_exists?
