module Searchable
  extend ActiveSupport::Concern

  NONE_KEY = 'None'.freeze

  included do
    include Elasticsearch::Model

    after_commit on: [:create]  { __elasticsearch__.index_document }
    after_commit on: [:update]  { __elasticsearch__.update_document }
    after_commit on: [:destroy] { __elasticsearch__.delete_document }

    setup_mapping
  end

  class_methods do
    def setup_mapping
      settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
          indexes :title, type: 'text', analyzer: 'english', boost: 3
          indexes :keyword_filters, type: 'nested' do
            indexes :filter_name, type: 'keyword'
            indexes :filter_value, type: 'keyword'
          end
          indexes :integer_filters, type: 'nested' do
            indexes :filter_name, type: 'keyword'
            indexes :filter_value, type: 'integer'
          end
        end
      end
    end

    def es_search(filters_opts = {}, pagination = {})
      response = search_response(search_query(filters_opts, pagination))
      {
        facets:    facets(response),
        documents: response.results,
        stats:     stats(response).merge(pagination)
      }
    end

    def search_response(query)
      __elasticsearch__.search(query)
    end

    def search_query(filters_opts = {}, pagination = {})
      SearchQueryService.call do |builder|
        builder.prepare_query_filter(filters_opts)
        builder.prepare_filters(facets_fields, filters_opts)
        builder.prepare_aggregations
        builder.prepare_pagination(pagination) if pagination.present?
      end
    end

    def facets(response)
      return {} if response.aggregations.blank?
      result = Hash.new { |k, v| k[v] = {} }
      %w[keyword integer].each do |type|
        response.aggregations.send("agg_#{type}_filter").filter_name.buckets.each do |bucket|
          bucket.filter_value.buckets.each do |sub_bucket|
            next unless facets_fields.include?(bucket[:key])
            sub_bucket_key = sub_bucket[:key].blank? ? NONE_KEY : sub_bucket[:key]
            result[bucket[:key]][sub_bucket_key] = sub_bucket[:doc_count]
          end
        end
      end
      result
    end

    def stats(response)
      {
        total_entries: response.results.total
      }
    end
  end

  def record
    @record ||= repository.find(id)
  end
end
