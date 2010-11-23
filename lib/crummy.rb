module Crummy
  if defined?(Rails::Railtie)
    require 'crummy/railtie'
  else
    require 'crummy/action_controller'
    require 'crummy/action_view'
    ActionController::Base.send :include,  Crummy::ControllerMethods 
    ActionView::Base.send :include, Crummy::ViewMethods
  end	  
end
