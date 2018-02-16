class BaseUpdater
  include Interactor
  include Dry::Monads
  include Dry::Monads::Do.for(:call)

  delegate :id, :params, to: :context

  def call
    yield update(yield record)
  end

  protected

  def self.repository(klass = nil)
    @repository ||= klass
  end

  private

  def record
    record = repository.find(id)
    if record.present?
      Success(record)
    else
      Failure(context.fail!(type: :not_found, message: 'Resource with given ID does not exist.'))
    end
  end

  def update(record)
    if record.update(params)
      Success(context.instance = record)
    else
      Failure(context.fail!(type: :invalid, message: record.errors.messages))
    end
  end

  def repository
    self.class.repository.new
  end
end
