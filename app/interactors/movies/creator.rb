module Movies
  class Creator
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

    def instance
      @instance ||= Movie.new(params)
    end

    def valid?
      instance.valid?
    end

    def save!
      instance.save!
    end
  end
end
