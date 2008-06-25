module Crummy
  module ControllerMethods
    module ClassMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      # Works like a before_filter so +:only+ and +except+ both work.
      def add_crumb(name, url = nil, options = {})
        raise ArgumentError, "Cannot pass url and use block" if url && block_given?
        before_filter(options) do |instance|
          url = yield instance if block_given?
          # FIXME: url = instance.url_for(name) if name.respond_to?("to_param") && url.nil?
          instance.add_crumb(name, url)
        end
      end
    end

    module InstanceMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      def add_crumb(name, url='')
        crumbs.push [name, url]
      end

      # Lists the crumbs as an array
      def crumbs
        get_or_set_ivar "@_crumbs", []
      end

      def get_or_set_ivar(var, value) # :nodoc:
        instance_variable_set var, instance_variable_get(var) || value
      end
      private :get_or_set_ivar
    end

    def self.included(receiver) # :nodoc:
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
  
  module ViewMethods
    # List the crumbs as an array
    def crumbs
      @_crumbs ||= [] # Give me something to push to
    end
    
    # Add a crumb to the +crumbs+ array
    def add_crumb(name, url='')
      crumbs.push [name, url]
    end
    
    # Render the list of crumbs
    #
    #   render_crumbs         #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #
    # The only argument is for the seperator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(seperator=" &raquo; ")
      crumbs.collect do |crumb|
        crumb_to_html crumb
      end * seperator
    end
    
    def crumb_to_html(crumb)
      name, url = crumb
      url ? link_to(name, url) : name
    end
  end
end
