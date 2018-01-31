module Movies
  class Repository
    def find(id)
      Movie.find_by_id(id)
    end

    def find_all
      Movie.all
    end
  end
end
