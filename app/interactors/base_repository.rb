class BaseRepository
  def self.model(klass = nil)
    @model ||= klass
  end

  def find(id)
    model.find_by_id(id)
  end

  def find_all
    model.all
  end

  private

  def model
    self.class.model
  end
end
