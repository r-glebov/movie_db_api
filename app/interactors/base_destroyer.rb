class BaseDestroyer
  include Interactor
  include Dry::Monads::Result::Mixin

  delegate :id, to: :context

  def call
    destroyed?.right? ? destroyed?.value : context.fail!(destroyed?.failure)
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

  def destroyed?
    @destroyed ||= begin
      instance.bind do |value|
        if value.destroy
          Success(context.instance = instance.value)
        else
          Failure(type: :unprocessable_entity, message: value.errors.messages)
        end
      end
    end
  end

  def repository
    @repository ||= self.class.repository.new
  end
end
