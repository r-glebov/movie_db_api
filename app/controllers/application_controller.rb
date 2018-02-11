class ApplicationController < ActionController::API
  include TokenAuthenticable
  ActionController::Parameters.permit_all_parameters = true
end
