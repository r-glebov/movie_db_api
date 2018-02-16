class BaseCreator
  include Interactor
  include Dry::Monads
  include Dry::Monads::Do.for(:call)

  delegate :params, to: :context

  def call
    yield save(record)
  end

  protected

  def self.model(klass = nil)
    @model ||= klass
  end

  private

  def record
    self.class.model.new(params)
  end

  def save(record)
    if record.save
      Success(context.instance = record)
    else
      Failure(context.fail!(type: :invalid, message: record.errors.messages))
    end
  end
end
