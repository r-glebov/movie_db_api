ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'elasticsearch/extensions/test/cluster'

ActiveRecord::Migration.maintain_test_schema!

ENV['TEST_CLUSTER_NODES'] = '1'

RSpec.configure do |config|
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: %r{spec\/api}

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before :all, elasticsearch: true do
    Elasticsearch::Extensions::Test::Cluster.start(port: 9250, nodes: 1, timeout: 120) unless Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
  end

  config.after :suite do
    Elasticsearch::Extensions::Test::Cluster.stop(port: 9250, nodes: 1) if Elasticsearch::Extensions::Test::Cluster.running?(on: 9250)
  end

  SEARCHABLE_MODELS = [Movie].freeze
  config.around :each, elasticsearch: true do |example|
    SEARCHABLE_MODELS.each do |model|
      model.__elasticsearch__.create_index!(force: true)
      model.__elasticsearch__.refresh_index!
    end

    example.run

    SEARCHABLE_MODELS.each do |model|
      model.__elasticsearch__.client.indices.delete index: model.index_name
    end
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
