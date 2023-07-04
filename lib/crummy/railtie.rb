require 'crummy'
require 'rails'

module Crummy
  class Railtie < Rails::Railtie
    initializer 'crummy.action_controller' do |_app|
      if defined?(ActionController)
        require 'crummy/action_controller'
        ActionController::Base.send :include, Crummy::ControllerMethods
      end
    end

    initializer 'crummy.action_view' do |_app|
      require 'crummy/action_view'
      ActionView::Base.send :include, Crummy::ViewMethods
    end
  end
end
