class BaseCreator
  include Interactor
  include Dry::Monads::Result::Mixin

  delegate :params, to: :context

  def call
    saved?.right? ? saved?.value : context.fail!(saved?.failure)
  end

  protected

  def self.model(klass = nil)
    @model ||= klass
  end

  private

  def instance
    @instance ||= self.class.model.new(params)
  end

  def valid?
    Success(instance).bind do |value|
      if value.valid?
        Success(value)
      else
        Failure(type: :invalid, message: value.errors.messages)
      end
    end
  end

  def saved?
    @saved ||= begin
      valid?.bind do |value|
        if value.save
          Success(context.instance = instance)
        else
          Failure(type: :invalid, message: value.errors.messages)
        end
      end
    end
  end
end
