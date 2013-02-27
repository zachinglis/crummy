class ApplicationController < ActionController::Base
  add_crumb("Homepage") { |instance| instance.send :root_url }
  add_crumb("Customer Dashboard", '/')
  
  protect_from_forgery
end
