class ApplicationController < ActionController::API
  Import = Dry::AutoInject(RepositoryContainer)
  include TokenAuthenticable
end
