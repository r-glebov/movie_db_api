class BaseRepository
  def self.model(klass = nil)
    @model ||= klass
  end

  def find(id)
    model.find_by_id(id)
  end

  def find_all(filters_opts = {}, pagination = {}, &block)
    return model.es_search(filters_opts.to_h, pagination.to_h) if es_search?(&block)
    model.all
  end

  private

  def model
    self.class.model
  end

  def es_search?(&_block)
    option = (yield if block_given?) || {}
    option.fetch(:es_search, false)
  end
end
