unless Rails.env.test?
  Movie.__elasticsearch__.create_index!(force: true) unless Movie.__elasticsearch__.index_exists?
end

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: Rails.env.test? ? 'http://localhost:9250' : ENV['ES_URL']
)
