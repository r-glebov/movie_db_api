class BaseUpdater
  include Interactor
  include Dry::Monads::Result::Mixin

  delegate :id, :params, to: :context

  def call
    updated?.right? ? updated?.value : context.fail!(updated?.failure)
  end

  protected

  def self.repository(klass = nil)
    @repository ||= klass
  end

  private

  def instance
    @instance ||= begin
      result = repository.find(id)
      if result.present?
        Success(result)
      else
        Failure(type: :not_found, message: 'Resource with given ID does not exist.')
      end
    end
  end

  def updated?
    @updated ||= begin
      instance.bind do |value|
        if value.update(params)
          Success(context.instance = instance.value)
        else
          Failure(type: :invalid, message: value.errors.messages)
        end
      end
    end
  end

  def repository
    @repository ||= self.class.repository.new
  end
end
