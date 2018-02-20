module RepositoryContainer
  extend Dry::Container::Mixin

  register('movies_repository')  { Movies::Repository.new  }
  register('genres_repository')  { Genres::Repository.new  }
  register('users_repository')   { Users::Repository.new   }
  register('ratings_repository') { Ratings::Repository.new }
end
