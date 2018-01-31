class BaseCreator
  include Interactor

  delegate :params, to: :context

  def call
    if valid?
      save!
      context.instance = instance
    else
      context.fail!(message: instance.errors)
    end
  end

  def self.model(klass = nil)
    @model ||= klass
  end

  protected

  def instance
    @instance ||= self.class.model.new(params)
  end

  def valid?
    instance.valid?
  end

  def save!
    instance.save!
  end
end
