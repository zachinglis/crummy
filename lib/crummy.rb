module Crummy
  module ControllerMethods
    module ClassMethods
      # Add a crumb to the crumbs array.
      #
      #   add_crumb("Home", "/")
      #   add_crumb("Business") { |instance| instance.business_path }
      #
      # Works like a before_filter so +:only+ and +except+ both work.
      def add_crumb(name, *args)
        options = args.extract_options!
        url = args.first
        raise ArgumentError, "Need more arguments" unless name or options[:record] or block_given?
        raise ArgumentError, "Cannot pass url and use block" if url && block_given?
        before_filter(options) do |instance|
          url = yield instance if block_given?
          url = instance.send url if url.is_a? Symbol
          record = instance.instance_variable_get("@#{name}") unless url or block_given?
          if record and record.respond_to? :to_param
            name, url = record.to_s, instance.url_for(record)
          end
        
          # FIXME: url = instance.url_for(name) if name.respond_to?("to_param") && url.nil?
          # FIXME: Add ||= for the name, url above
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
      def add_crumb(name, url=nil)
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
    def add_crumb(name, url=nil)
      crumbs.push [name, url]
    end
    
    # Render the list of crumbs as either html or xml
    #
    # Takes 3 options:
    # The output format. Can either be xml or html. Default :html
    #   :format => (:html|:xml) 
    # The seperator text. It does not assume you want spaces on either side so you must specify. Default +&raquo;+ for :html and +crumb+ for xml
    #   :seperator => string  
    # Render links in the output. Default +true+
    #   :link => boolean        
    # 
    #   Examples:
    #   render_crumbs                     #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs :seperator => ' | ' #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs :format => :xml     #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   
    # The only argument is for the seperator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(options = {})
      options[:format] = :html if options[:format] == nil
      if options[:seperator] == nil
        options[:seperator] = " &raquo; " if options[:format] == :html 
        options[:seperator] = "crumb" if options[:format] == :xml 
      end
      options[:links] = true if options[:links] == nil
      case options[:format]
      when :html
        crumbs.collect do |crumb|
          crumb_to_html crumb, options[:links]
        end * options[:seperator]
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml crumb, options[:links], options[:seperator]
        end * ''
      else
        raise "Unknown breadcrumb output format"
      end
    end
    
    def crumb_to_html(crumb, links)
      name, url = crumb
      url && links ? link_to(name, url) : name
    end
    
    def crumb_to_xml(crumb, links, seperator)
      name, url = crumb
      url && links ? "<#{seperator} href=\"#{url}\">#{name}</#{seperator}>" : "<#{seperator}>#{name}</#{seperator}>"
    end
    
  end
end