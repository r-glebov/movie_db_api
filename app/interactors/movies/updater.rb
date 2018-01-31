module Movies
  class Updater
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
      @repository ||= Movies::Repository.new
    end
  end
end
