# rubocop:disable Metrics/ClassLength
class SearchQueryService
  attr_reader :query

  def initialize
    @query = EsQuery.new
  end

  def self.call
    builder = new
    yield(builder)
    builder.call
  end

  def call
    base_query
      .merge(query.size)
      .merge(query.pagination)
      .merge(query.aggregations)
  end

  def prepare_query_filter(filters_opts = {})
    query.query_filter = query_filter(filters_opts)
  end

  def prepare_filters(filter_fields, filters_opts = {})
    query.filters = filters(filter_fields, filters_opts)
  end

  def prepare_size(facets: false)
    query.size = facets ? { size: 0 } : { size: MAX_RESULTS }
  end

  def prepare_pagination(pagination)
    query.pagination = {
      from: START_INDEX.call(pagination),
      size: pagination[:per_page]
    }
  end

  def prepare_aggregations(type: 'keyword')
    query.aggregations = AGGREGATIONS.call(type)
  end

  private

  START_INDEX = ->(pagination) { (pagination[:page].to_i - 1) * pagination[:per_page].to_i }
  MAX_RESULTS = 10_000
  SLOP_MATCH_PHRASE_LEVEL = 3
  MATCH_ALL_QUERY = {
    match_all: {}
  }.freeze
  AGGREGATIONS = ->(_type) do
    {
      aggs: {
        agg_keyword_filter: {
          nested: {
            path: 'keyword_filters'
          },
          aggs: {
            filter_name: {
              terms: {
                size: MAX_RESULTS,
                field: 'keyword_filters.filter_name'
              },
              aggs: {
                filter_value: {
                  terms: {
                    size: MAX_RESULTS,
                    field: 'keyword_filters.filter_value'
                  }
                }
              }
            }
          }
        },
        agg_integer_filter: {
          nested: {
            path: 'integer_filters'
          },
          aggs: {
            filter_name: {
              terms: {
                size: MAX_RESULTS,
                field: 'integer_filters.filter_name'
              },
              aggs: {
                filter_value: {
                  terms: {
                    size: MAX_RESULTS,
                    field: 'integer_filters.filter_value'
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  def base_query
    {
      query: {
        bool: {
          must: query.query_filter,
          filter: query.filters
        }
      }
    }
  end

  def query_filter(filters_opts)
    return MATCH_ALL_QUERY if filters_opts['query'].blank?
    {
      multi_match: {
        query: filters_opts['query'],
        slop: SLOP_MATCH_PHRASE_LEVEL,
        type: 'phrase_prefix',
        fields: %w[title]
      }
    }
  end

  def filters(filter_fields, filters_opts)
    filters_opts.map do |filter_name, filter_values|
      next unless filter_fields.include?(filter_name)
      {
        bool: {
          should: subtype_filters(filter_name, filter_values)
        }
      }
    end.compact
  end

  def subtype_filters(filter_name, filter_values)
    type = filter_name == 'rating' ? 'integer' : 'keyword'
    filter_values.split(',').map do |filter_value|
      {
        nested: {
          path: "#{type}_filters",
          query: {
            bool: {
              filter: [
                { term: { "#{type}_filters.filter_name": filter_name } },
                { term: { "#{type}_filters.filter_value": filter_value } }
              ]
            }
          }
        }
      }
    end
  end
end
# rubocop:enable Metrics/ClassLength

EsQuery = Struct.new(:query_filter, :filters, :size, :pagination, :aggregations) do
  def initialize(*)
    super
    self.size = {}
    self.pagination = {}
    self.aggregations = {}
  end
end
