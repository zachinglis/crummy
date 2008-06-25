module Crummy
  module ControllerMethods
    module ClassMethods
      def add_crumb(name, url = nil, options = {})
        raise ArgumentError, "Cannot pass url and use block" if url && block_given?
        before_filter(options) do |instance|
          url = yield instance if block_given?
          url = instance.send(:url_for, name) if name.respond_to?("to_param") && url.nil?
          instance.add_crumb(name, url)
        end
      end
    end

    module InstanceMethods
      def add_crumb(name, url='')
        crumbs.push [name, url]
      end

      def crumbs
        get_or_set_ivar "@_crumbs", []
      end

      # :nodoc:
      def get_or_set_ivar(var, value)
        instance_variable_set var, instance_variable_get(var) || value
      end
      private :get_or_set_ivar
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
  
  module ViewMethods
    def crumbs
      @_crumbs || []
    end
    
    def render_crumbs
      crumbs.collect do |crumb|
        crumb_to_html crumb
      end
    end
    
    def crumb_to_html(crumb)
      name, url = crumb
      url ? link_to(name, url) : name
    end
  end
end

# class EventsController < ApplicationController
#   add_crumb "Home", '/' # really in application.rb
#   add_crumb @events
#   add_crumb "Events" { |instance| instance.events_path }
# 
#   def index
#   end
#   
#   def show
#     add_crumb @event.display_name, @event
#   end
# end
# 
# Home > Events > Some Event
