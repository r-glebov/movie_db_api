module Movies
  class Destroyer
    include Interactor

    delegate :id, to: :context

    def call
      if instance.blank?
        context.fail!(type: :not_found, message: 'Resource with given ID does not exist.')
      elsif !instance.destroy
        context.fail!(type: :unprocessable_entity, message: "Entity (#{id}) could not be destroyed.")
      else
        context.instance = instance
      end
    end

    def instance
      @instance ||= repository.find(id)
    end

    def repository
      @repository ||= Movies::Repository.new
    end
  end
end
