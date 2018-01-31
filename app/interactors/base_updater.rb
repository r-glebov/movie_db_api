class BaseUpdater
  include Interactor

  delegate :id, :params, to: :context

  def call
    if instance.blank?
      context.fail!(type: :not_found, message: 'Resource with given ID does not exist.')
    elsif !updated?
      context.fail!(type: :invalid, message: instance.errors)
    else
      context.instance = instance
    end
  end

  def self.repository(klass = nil)
    @repository ||= klass
  end

  protected

  def valid?
    instance.valid?
  end

  def save!
    instance.save!
  end

  def instance
    @instance ||= repository.find(id)
  end

  def updated?
    instance.update(params)
  end

  def repository
    @repository ||= self.class.repository.new
  end
end
