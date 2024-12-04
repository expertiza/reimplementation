class ApplicationController < ActionController::API
  include JwtToken

  # added today
  include Permissions
end
